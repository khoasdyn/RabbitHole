import SwiftUI

struct WelcomeView: View {

    let topics: [Topic]
    var onQuestionSelected: (Topic) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                questionCards
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .background(Color(.systemBackground))
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Spacer().frame(height: 60)

            Image(systemName: "arrow.down.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.white, Color(.tertiarySystemBackground))
                .padding(.bottom, 4)

            Text("Rabbit Hole")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color(.label))

            Text("What are you curious about?")
                .font(.title3)
                .foregroundStyle(Color(.secondaryLabel))
        }
        .padding(.bottom, 32)
    }

    // MARK: - Cards

    private var questionCards: some View {
        VStack(spacing: 16) {
            ForEach(topics) { topic in
                QuestionCardView(topic: topic) {
                    onQuestionSelected(topic)
                }
            }
        }
    }
}
