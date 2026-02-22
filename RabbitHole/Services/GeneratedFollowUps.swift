import Foundation
import FoundationModels

@Generable
struct GeneratedFollowUps: Equatable {

    @Guide(description: """
        3 to 5 follow-up questions that dig deeper into the topic. \
        Each question should explore a specific angle, cause, consequence, or example \
        that helps reveal the answer to the main topic question. \
        Questions should be conversational, specific, and under 15 words each.
        """)
    @Guide(.count(3...5))
    let questions: [FollowUpQuestion]
}

@Generable
struct FollowUpQuestion: Equatable {

    @Guide(description: "A specific, curiosity-driven question under 15 words.")
    let text: String
}
