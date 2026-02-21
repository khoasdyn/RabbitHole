import Foundation
import SwiftData

struct MockDataSeeder {

    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Topic>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0
        guard existingCount == 0 else { return }

        seedTopics(context: context)
    }

    // MARK: - Topics

    private static func seedTopics(context: ModelContext) {
        let topics = [
            Topic(
                question: "Were the Stoics right that most of your problems are imaginary?",
                subjectArea: "Philosophy",
                accentColorName: "orange",
                iconName: "brain.head.profile"
            ),
            Topic(
                question: "What happens to time when you fall into a black hole?",
                subjectArea: "Astrophysics",
                accentColorName: "blue",
                iconName: "moon.stars"
            ),
            Topic(
                question: "How did Airbnb use design thinking to avoid going bankrupt?",
                subjectArea: "Design",
                accentColorName: "purple",
                iconName: "lightbulb"
            ),
            Topic(
                question: "Is eating local actually better for the planet?",
                subjectArea: "Environment",
                accentColorName: "green",
                iconName: "leaf"
            ),
            Topic(
                question: "Can you actually rewire your brain by changing your habits?",
                subjectArea: "Neuroscience",
                accentColorName: "pink",
                iconName: "brain"
            )
        ]

        for topic in topics {
            context.insert(topic)
        }

        try? context.save()
    }
}
