import Foundation
import SwiftData

struct MockDataSeeder {

    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Topic>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0
        guard existingCount == 0 else { return }

        let stoicism = Topic(
            question: "Were the Stoics right that most of your problems are imaginary?",
            subjectArea: "Philosophy",
            accentColorName: "orange",
            iconName: "brain.head.profile"
        )

        let blackHole = Topic(
            question: "What happens to time when you fall into a black hole?",
            subjectArea: "Astrophysics",
            accentColorName: "blue",
            iconName: "moon.stars"
        )

        let designThinking = Topic(
            question: "How did Airbnb use design thinking to avoid going bankrupt?",
            subjectArea: "Design",
            accentColorName: "purple",
            iconName: "lightbulb"
        )

        let eatingLocal = Topic(
            question: "Is eating local actually better for the planet?",
            subjectArea: "Environment",
            accentColorName: "green",
            iconName: "leaf"
        )

        let brainRewire = Topic(
            question: "Can you actually rewire your brain by changing your habits?",
            subjectArea: "Neuroscience",
            accentColorName: "pink",
            iconName: "brain"
        )

        let allTopics = [stoicism, blackHole, designThinking, eatingLocal, brainRewire]
        for topic in allTopics {
            context.insert(topic)
        }

        // Seed Level 1 content for the primary demo question
        StoicismMockContent.seedLevel1(topic: stoicism, context: context)

        try? context.save()
    }
}
