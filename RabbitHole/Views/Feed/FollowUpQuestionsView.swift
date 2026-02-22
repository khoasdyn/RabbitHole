import SwiftUI

struct FollowUpQuestionsView: View {

    let questions: [FollowUpQuestion]
    let isLoading: Bool
    let accentColor: Color
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Keep exploring", systemImage: "arrow.turn.down.right")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color(.secondaryLabel))

            if isLoading {
                loadingState
            } else {
                ForEach(questions, id: \.text) { question in
                    Button {
                        onSelect(question.text)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "sparkle")
                                .font(.caption)
                                .foregroundStyle(accentColor)

                            Text(question.text)
                                .font(.subheadline)
                                .foregroundStyle(Color(.label))
                                .multilineTextAlignment(.leading)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundStyle(Color(.tertiaryLabel))
                        }
                        .padding(CardStyle.padding)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: CardStyle.cornerRadius))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Loading

    private var loadingState: some View {
        VStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { _ in
                ShimmerQuestionRow()
            }
        }
    }
}

// MARK: - Shimmer row

private struct ShimmerQuestionRow: View {

    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(.tertiarySystemFill))
                .frame(width: 14, height: 14)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.tertiarySystemFill))
                .frame(height: 12)
        }
        .padding(CardStyle.padding)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: CardStyle.cornerRadius))
        .opacity(isAnimating ? 0.4 : 0.8)
        .animation(
            .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
            value: isAnimating
        )
        .onAppear { isAnimating = true }
    }
}
