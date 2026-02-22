import Foundation
import FoundationModels
import SwiftData
import Observation

@Observable
@MainActor
final class ChallengeGenerationService {

    // MARK: - State

    private(set) var isGenerating = false
    private(set) var hasFailed = false
    private(set) var isCompleted = false

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

    func prewarm() {
        session.prewarm()
    }

    // MARK: - Generation

    func generateChallenge(title: String, subtitle: String, context: ModelContext) async {
        isGenerating = true
        isCompleted = false
        hasFailed = false
        defer { isGenerating = false }

        let existingSortOrder = topic.contentItems
            .filter { $0.level == level }
            .count

        do {
            let prompt = buildPrompt(title: title)
            let response = try await session.respond(
                to: prompt,
                generating: GeneratedChallenge.self
            )

            let challenge = response.content
            let body = serializeChallengeJSON(challenge)

            let item = ContentItem(
                type: ContentType.challenge.rawValue,
                level: level,
                title: challenge.title,
                subtitle: challenge.subtitle,
                body: body,
                estimatedMinutes: 5,
                sortOrder: existingSortOrder + 1
            )
            item.topic = topic
            context.insert(item)
            try? context.save()

            isCompleted = true

        } catch {
            hasFailed = true
        }
    }

    // MARK: - Prompt

    private static let instructions = Instructions {
        """
        You create practical challenges for a learning app called Rabbit Hole. \
        Challenges are hands-on exercises that help the reader apply what they've learned. \
        They should be doable in 5 minutes, require only thinking and writing (no special tools), \
        and connect directly to the topic. Conversational tone, second-person "you".
        """
    }

    private func buildPrompt(title: String) -> Prompt {
        let levelInfo = Level(rawValue: level)

        return Prompt {
            """
            Main topic: "\(topic.question)"
            Challenge focus: "\(title)"
            Level: \(levelInfo?.label ?? "Newcomer") — \(levelInfo?.description ?? "The basics")

            Generate a practical challenge that helps the reader apply their understanding. \
            The challenge should be directly about: "\(title)". \
            Instructions should be 50–100 words, clear and actionable.
            """
        }
    }

    // MARK: - JSON serialization

    private func serializeChallengeJSON(_ challenge: GeneratedChallenge) -> String {
        let dict: [String: Any] = [
            "instructions": challenge.instructions,
            "completionPrompt": challenge.completionPrompt
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: dict),
              let string = String(data: data, encoding: .utf8) else {
            return "{\"instructions\":\"\",\"completionPrompt\":\"\"}"
        }
        return string
    }
}
