import Foundation
import FoundationModels

@Generable
struct GeneratedQuiz: Equatable {

    @Guide(description: "An engaging quiz title under 15 words, testing the reader's understanding.")
    let title: String

    @Guide(description: "A one-line subtitle like '5 questions to test your understanding'.")
    let subtitle: String

    @Guide(description: "Exactly 5 multiple-choice questions about the topic.")
    @Guide(.count(5))
    let questions: [GeneratedQuizQuestion]
}

@Generable
struct GeneratedQuizQuestion: Equatable {

    @Guide(description: "A clear, specific question about the topic.")
    let question: String

    @Guide(description: "Exactly 4 answer options. Only one is correct.")
    @Guide(.count(4))
    let options: [String]

    @Guide(description: "The index (0-3) of the correct option.")
    let correctIndex: Int

    @Guide(description: "A 1-2 sentence explanation of why the correct answer is right.")
    let explanation: String
}
