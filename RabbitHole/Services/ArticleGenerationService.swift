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

    /// Generate an article for the main topic question.
    func generateArticle(context: ModelContext) async {
        await generate(context: context, prompt: buildPrompt(followUpQuestion: nil))
    }

    /// Generate an article for a specific follow-up question.
    func generateArticle(for followUpQuestion: String, context: ModelContext) async {
        await generate(context: context, prompt: buildPrompt(followUpQuestion: followUpQuestion))
    }

    // MARK: - Core generation

    private func generate(context: ModelContext, prompt: Prompt) async {
        // Reset state for reuse
        partial = nil
        isGenerating = true
        isCompleted = false
        hasFailed = false
        error = nil
        defer { isGenerating = false }

        let existingSortOrder = topic.contentItems
            .filter { $0.level == level }
            .count

        do {
            let stream = session.streamResponse(
                to: prompt,
                generating: GeneratedArticle.self
            )

            for try await partialResponse in stream {
                self.partial = partialResponse.content
            }

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

    private func buildPrompt(followUpQuestion: String?) -> Prompt {
        let levelInfo = Level(rawValue: level)

        if let followUpQuestion {
            return Prompt {
                """
                Main topic: "\(topic.question)"
                Specific angle to cover: "\(followUpQuestion)"

                Level: \(levelInfo?.label ?? "Newcomer") — \(levelInfo?.description ?? "The basics")

                Write a short article that explores this specific angle in the context \
                of the main topic. The article should help the reader understand this \
                particular aspect while connecting back to the bigger question.

                Requirements:
                - Title: engaging, under 15 words, about this specific angle
                - Subtitle: one sentence hinting at what the reader will learn
                - Body: under 200 words, conversational, no bullet points or headers
                - Start with a concrete scenario, then build to the concept
                - Use "you" to address the reader
                """
            }
        } else {
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
}
