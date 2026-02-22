import Foundation
import FoundationModels

@Generable
struct GeneratedArticle: Equatable {

    @Guide(description: "An engaging, curiosity-driven title under 15 words. Conversational tone, not academic.")
    let title: String

    @Guide(description: "A one-line subtitle hinting at the article's angle or what the reader will learn.")
    let subtitle: String

    @Guide(description: """
        The full article body, under 200 words. Conversational tone, second-person "you" framing. \
        Start with a relatable scenario, then build to the concept. \
        No bullet points, numbered lists, or headers.
        """)
    let body: String

    @Guide(description: "Estimated reading time in minutes, either 1 or 2.")
    let estimatedMinutes: Int
}
