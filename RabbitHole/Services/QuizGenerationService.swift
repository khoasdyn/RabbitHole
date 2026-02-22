import Foundation
import FoundationModels
import SwiftData
import Observation

@Observable
@MainActor
final class QuizGenerationService {

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

    func generateQuiz(title: String, subtitle: String, context: ModelContext) async {
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
                generating: GeneratedQuiz.self
            )

            let quiz = response.content
            let body = serializeQuizJSON(quiz)

            let item = ContentItem(
                type: ContentType.quiz.rawValue,
                level: level,
                title: quiz.title,
                subtitle: quiz.subtitle,
                body: body,
                estimatedMinutes: 3,
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
        You create quizzes for a learning app called Rabbit Hole. \
        Quizzes test the reader's understanding of articles they've read. \
        Questions should be specific, not trivia. They test comprehension of concepts, \
        not memorization of facts. Each question has exactly 4 options with 1 correct answer. \
        Explanations should be concise and educational.
        """
    }

    private func buildPrompt(title: String) -> Prompt {
        let levelInfo = Level(rawValue: level)
        let existingArticleTitles = topic.contentItems
            .filter { $0.contentType == .article }
            .map { $0.title }

        return Prompt {
            """
            Main topic: "\(topic.question)"
            Quiz focus: "\(title)"
            Level: \(levelInfo?.label ?? "Newcomer") — \(levelInfo?.description ?? "The basics")

            Articles the reader has seen:
            \(existingArticleTitles.isEmpty ? "None yet" : existingArticleTitles.enumerated().map { "- \($0.offset + 1). \($0.element)" }.joined(separator: "\n"))

            Generate a quiz with exactly 5 questions that test understanding of this topic. \
            Questions should relate to concepts from the articles above. \
            Each question must have exactly 4 options with only 1 correct answer. \
            correctIndex must be 0, 1, 2, or 3.
            """
        }
    }

    // MARK: - JSON serialization

    private func serializeQuizJSON(_ quiz: GeneratedQuiz) -> String {
        let questionsArray = quiz.questions.map { q -> [String: Any] in
            [
                "question": q.question,
                "options": q.options,
                "correctIndex": q.correctIndex,
                "explanation": q.explanation
            ]
        }
        let dict: [String: Any] = ["questions": questionsArray]
        guard let data = try? JSONSerialization.data(withJSONObject: dict),
              let string = String(data: data, encoding: .utf8) else {
            return "{\"questions\":[]}"
        }
        return string
    }
}
