import Foundation
import FoundationModels

// MARK: - AI-generated follow-up suggestions

@Generable
struct GeneratedFollowUps: Equatable {

    @Guide(description: """
        3 follow-up questions that dig deeper into the topic. \
        Each question should explore a specific angle, cause, consequence, or example \
        that helps reveal the answer to the main topic question. \
        Questions should be conversational, specific, and under 15 words each.
        """)
    @Guide(.count(3))
    let articleQuestions: [FollowUpArticleQuestion]

    @Guide(description: "A short, engaging title for a quiz about this topic, under 15 words.")
    let quizTitle: String

    @Guide(description: "A one-line subtitle for the quiz, like 'Test what you've learned so far'.")
    let quizSubtitle: String

    @Guide(description: "A short, actionable title for a hands-on challenge about this topic, under 15 words.")
    let challengeTitle: String

    @Guide(description: "A one-line subtitle for the challenge describing what the reader will practice.")
    let challengeSubtitle: String
}

@Generable
struct FollowUpArticleQuestion: Equatable {

    @Guide(description: "A specific, curiosity-driven question under 15 words.")
    let text: String
}

// MARK: - View model for suggestions

struct FollowUpSuggestion: Identifiable {
    let id = UUID()
    let type: ContentType
    let text: String
    let subtitle: String?
}
