import Foundation
import FoundationModels

@Generable
struct GeneratedChallenge: Equatable {

    @Guide(description: "An actionable challenge title under 15 words, framed as a task.")
    let title: String

    @Guide(description: "A one-line subtitle describing what the reader will practice.")
    let subtitle: String

    @Guide(description: """
        Detailed instructions for the challenge, 50–100 words. \
        Explain what to do step by step. Conversational tone, second-person "you".
        """)
    let instructions: String

    @Guide(description: "A short phrase the user sees on the completion button, like 'I completed the exercise'.")
    let completionPrompt: String
}
