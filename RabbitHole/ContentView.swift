import SwiftUI
import SwiftData

struct ContentView: View {

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Topic.createdAt) private var topics: [Topic]
    @State private var selectedTopic: Topic?

    var body: some View {
        Group {
            if let topic = selectedTopic {
                feedPlaceholder(for: topic)
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

    // MARK: - Placeholder (will be replaced with tab view)

    private func feedPlaceholder(for topic: Topic) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(topic.accentColor)

            Text("You picked:")
                .font(.headline)
                .foregroundStyle(Color(.secondaryLabel))

            Text(topic.question)
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button("Back to questions") {
                selectedTopic = nil
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
