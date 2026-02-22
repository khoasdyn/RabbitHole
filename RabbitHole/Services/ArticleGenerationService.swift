import Foundation
import FoundationModels
import SwiftData
import Observation

@Observable
@MainActor
final class ArticleGenerationService {

    // MARK: - State

    private(set) var partial: GeneratedArticle.PartiallyGenerated?
    private(set) var isGenerating = false
    private(set) var hasFailed = false
    private(set) var isCompleted = false
    var error: Error?

    // MARK: - Private

    private let topic: Topic
    private let level: Int
    private let session: LanguageModelSession

    // MARK: - Init

    init(topic: Topic, level: Int = 1) {
        self.topic = topic
        self.level = level
        self.session = LanguageModelSession(instructions: Self.instructions)
    }

    // MARK: - Lifecycle

    func prewarm() {
        session.prewarm()
    }

    func generateArticle(context: ModelContext) async {
        isGenerating = true
        defer { isGenerating = false }

        let existingSortOrder = topic.contentItems
            .filter { $0.level == level }
            .count

        do {
            let prompt = buildPrompt()
            let stream = session.streamResponse(
                to: prompt,
                generating: GeneratedArticle.self
            )

            for try await partialResponse in stream {
                self.partial = partialResponse.content
            }

            // Persist the completed article to SwiftData
            if let partial,
               let title = partial.title,
               let subtitle = partial.subtitle,
               let body = partial.body {

                let item = ContentItem(
                    type: ContentType.article.rawValue,
                    level: level,
                    title: title,
                    subtitle: subtitle,
                    body: body,
                    estimatedMinutes: partial.estimatedMinutes ?? 1,
                    sortOrder: existingSortOrder + 1
                )
                item.topic = topic
                context.insert(item)
                try? context.save()

                isCompleted = true
            } else {
                hasFailed = true
            }

        } catch {
            hasFailed = true
            self.error = error
        }
    }

    // MARK: - Prompt construction

    private static let instructions = Instructions {
        """
        You are a content writer for a learning app called Rabbit Hole. \
        You write engaging, conversational articles that make complex topics accessible. \
        Your style: conversational, story-driven, second-person "you" framing, \
        concrete examples before abstract principles. \
        Write like you're explaining something fascinating to a curious friend. \
        Keep it concise — under 200 words.
        """
    }

    private func buildPrompt() -> Prompt {
        let levelInfo = Level(rawValue: level)

        return Prompt {
            """
            Write a short article for the topic: "\(topic.question)"

            Level: \(levelInfo?.label ?? "Newcomer") — \(levelInfo?.description ?? "The basics")

            Requirements:
            - Title: engaging, under 15 words, conversational
            - Subtitle: one sentence hinting at the angle
            - Body: under 200 words, conversational, no bullet points or headers
            - Start with a concrete scenario, then build to the concept
            - Use "you" to address the reader
            """
        }
    }
}
