import SwiftUI

struct WelcomeView: View {

    let topics: [Topic]
    var onQuestionSelected: (Topic) -> Void
    var onCustomQuestion: (String) -> Void

    @State private var customQuestion = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                promptInput
                dividerLabel
                questionCards
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .background(Color(.systemBackground))
        .onTapGesture { isInputFocused = false }
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
        .padding(.bottom, 24)
    }

    // MARK: - Custom prompt

    private var promptInput: some View {
        HStack(spacing: 10) {
            TextField("Type your own question...", text: $customQuestion, axis: .vertical)
                .font(.subheadline)
                .lineLimit(1...3)
                .focused($isInputFocused)

            Button {
                submitCustomQuestion()
            } label: {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
                    .foregroundStyle(
                        trimmedQuestion.isEmpty
                            ? Color(.tertiaryLabel)
                            : .white
                    )
            }
            .disabled(trimmedQuestion.isEmpty)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.bottom, 24)
    }

    // MARK: - Divider label

    private var dividerLabel: some View {
        Text("Or pick one to explore")
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(Color(.tertiaryLabel))
            .padding(.bottom, 16)
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

    // MARK: - Helpers

    private var trimmedQuestion: String {
        customQuestion.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func submitCustomQuestion() {
        guard !trimmedQuestion.isEmpty else { return }
        onCustomQuestion(trimmedQuestion)
        customQuestion = ""
        isInputFocused = false
    }
}
