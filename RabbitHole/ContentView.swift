import SwiftUI
import SwiftData

struct ContentView: View {

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Topic.createdAt) private var topics: [Topic]
    @State private var selectedTopic: Topic?

    // Colors assigned round-robin to user-created topics
    private let userColors = ["cyan", "mint", "teal", "indigo", "yellow"]
    private let userIcons = ["sparkles", "magnifyingglass", "lightbulb", "puzzlepiece", "star"]

    var body: some View {
        Group {
            if let topic = selectedTopic {
                ContentFeedView(topic: topic) {
                    selectedTopic = nil
                }
            } else {
                WelcomeView(
                    topics: topics,
                    onQuestionSelected: { topic in
                        topic.isActive = true
                        selectedTopic = topic
                    },
                    onCustomQuestion: { question in
                        let topic = createCustomTopic(question: question)
                        selectedTopic = topic
                    }
                )
            }
        }
        .preferredColorScheme(.dark)
        .task {
            MockDataSeeder.seedIfNeeded(context: modelContext)
        }
    }

    // MARK: - Custom topic creation

    private func createCustomTopic(question: String) -> Topic {
        let userTopicCount = topics.filter { $0.subjectArea == "Custom" }.count
        let colorIndex = userTopicCount % userColors.count
        let iconIndex = userTopicCount % userIcons.count

        let topic = Topic(
            question: question,
            subjectArea: "Custom",
            accentColorName: userColors[colorIndex],
            iconName: userIcons[iconIndex],
            isActive: true
        )
        modelContext.insert(topic)
        try? modelContext.save()
        return topic
    }
}
