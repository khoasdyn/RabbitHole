import SwiftUI
import SwiftData

struct ContentView: View {

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Topic.createdAt) private var topics: [Topic]
    @State private var selectedTopic: Topic?

    var body: some View {
        Group {
            if let topic = selectedTopic {
                ContentFeedView(topic: topic) {
                    selectedTopic = nil
                }
            } else {
                WelcomeView(topics: topics) { topic in
                    topic.isActive = true
                    selectedTopic = topic
                }
            }
        }
        .preferredColorScheme(.dark)
        .task {
            MockDataSeeder.seedIfNeeded(context: modelContext)
        }
    }
}
