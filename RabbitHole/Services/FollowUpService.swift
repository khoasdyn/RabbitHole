import Foundation
import FoundationModels
import Observation

@Observable
@MainActor
final class FollowUpService {

    // MARK: - State

    private(set) var suggestions: [FollowUpSuggestion] = []
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
        suggestions = []
        defer { isGenerating = false }

        do {
            let prompt = buildPrompt()
            let response = try await session.respond(
                to: prompt,
                generating: GeneratedFollowUps.self
            )

            let result = response.content
            var items: [FollowUpSuggestion] = []

            // Article questions first
            for q in result.articleQuestions {
                items.append(FollowUpSuggestion(
                    type: .article,
                    text: q.text,
                    subtitle: nil
                ))
            }

            // Quiz suggestion
            items.append(FollowUpSuggestion(
                type: .quiz,
                text: result.quizTitle,
                subtitle: result.quizSubtitle
            ))

            // Challenge suggestion
            items.append(FollowUpSuggestion(
                type: .challenge,
                text: result.challengeTitle,
                subtitle: result.challengeSubtitle
            ))

            self.suggestions = items

        } catch {
            hasFailed = true
        }
    }

    // MARK: - Prompt

    private static let instructions = Instructions {
        """
        You generate follow-up suggestions for a learning app called Rabbit Hole. \
        You suggest article questions, a quiz, and a challenge — all related to the main topic. \
        Article questions help the reader explore specific angles. \
        The quiz tests what they've learned so far. \
        The challenge is a hands-on exercise to apply their understanding.
        """
    }

    private func buildPrompt() -> Prompt {
        let existingTitles = topic.contentItems
            .filter { $0.contentType == .article }
            .map { $0.title }

        let existingQuizCount = topic.contentItems
            .filter { $0.contentType == .quiz }
            .count

        let existingChallengeCount = topic.contentItems
            .filter { $0.contentType == .challenge }
            .count

        return Prompt {
            """
            Main topic: "\(topic.question)"

            Articles the reader has already seen:
            \(existingTitles.isEmpty ? "None yet" : existingTitles.enumerated().map { "- \($0.offset + 1). \($0.element)" }.joined(separator: "\n"))

            Quizzes completed: \(existingQuizCount)
            Challenges completed: \(existingChallengeCount)

            Generate:
            1. Three follow-up article questions that dig into specific angles not yet covered
            2. A quiz title and subtitle that tests understanding of what was read so far
            3. A challenge title and subtitle that applies what was learned to something practical

            All suggestions must be directly relevant to "\(topic.question)".
            Don't repeat topics already covered in existing articles.
            """
        }
    }
}
