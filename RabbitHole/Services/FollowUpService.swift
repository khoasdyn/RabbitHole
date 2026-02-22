import Foundation
import FoundationModels
import Observation

@Observable
@MainActor
final class FollowUpService {

    // MARK: - State

    private(set) var followUps: [FollowUpQuestion] = []
    private(set) var isGenerating = false
    private(set) var hasFailed = false

    // MARK: - Private

    private let topic: Topic
    private let session: LanguageModelSession

    // MARK: - Init

    init(topic: Topic) {
        self.topic = topic
        self.session = LanguageModelSession(instructions: Self.instructions)
    }

    // MARK: - Generation

    func generateFollowUps() async {
        isGenerating = true
        hasFailed = false
        followUps = []
        defer { isGenerating = false }

        do {
            let prompt = buildPrompt()
            let response = try await session.respond(
                to: prompt,
                generating: GeneratedFollowUps.self
            )
            self.followUps = response.content.questions
        } catch {
            hasFailed = true
        }
    }

    // MARK: - Prompt

    private static let instructions = Instructions {
        """
        You generate follow-up questions for a learning app called Rabbit Hole. \
        Questions should help the reader explore specific angles, causes, consequences, \
        or real-world examples that reveal the answer to a main topic question. \
        Each question should feel like a natural next step in curiosity — \
        specific, conversational, and under 15 words.
        """
    }

    private func buildPrompt() -> Prompt {
        let existingTitles = topic.contentItems
            .filter { $0.contentType == .article }
            .map { $0.title }

        return Prompt {
            """
            Main topic: "\(topic.question)"

            Articles the reader has already seen:
            \(existingTitles.isEmpty ? "None yet" : existingTitles.enumerated().map { "- \($0.offset + 1). \($0.element)" }.joined(separator: "\n"))

            Generate 3–5 follow-up questions that:
            - Dig into specific angles that help answer the main topic
            - Don't repeat what existing articles already cover
            - Are concrete and specific (not vague or generic)
            - Feel like a natural "I wonder about..." moment
            """
        }
    }
}
