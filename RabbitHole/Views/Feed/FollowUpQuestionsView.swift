import SwiftUI

struct FollowUpQuestionsView: View {

    let suggestions: [FollowUpSuggestion]
    let isLoading: Bool
    let accentColor: Color
    let onSelect: (FollowUpSuggestion) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Keep exploring", systemImage: "arrow.turn.down.right")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color(.secondaryLabel))

            ForEach(suggestions) { suggestion in
                Button {
                    onSelect(suggestion)
                } label: {
                    suggestionRow(suggestion)
                }
                .buttonStyle(.plain)
            }

            if isLoading {
                ShimmerQuestionRow()
            }
        }
    }

    // MARK: - Suggestion row

    private func suggestionRow(_ suggestion: FollowUpSuggestion) -> some View {
        HStack(spacing: 10) {
            Image(systemName: iconName(for: suggestion.type))
                .font(.caption)
                .foregroundStyle(suggestion.type.color)

            VStack(alignment: .leading, spacing: 2) {
                Text(suggestion.text)
                    .font(.subheadline)
                    .foregroundStyle(Color(.label))
                    .multilineTextAlignment(.leading)

                if let subtitle = suggestion.subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(Color(.tertiaryLabel))
                }
            }

            Spacer()

            typePill(suggestion.type)
        }
        .padding(CardStyle.padding)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: CardStyle.cornerRadius))
    }

    private func iconName(for type: ContentType) -> String {
        switch type {
        case .article: "sparkle"
        case .quiz: "questionmark.circle"
        case .challenge: "flame"
        case .discussion: "bubble.left.and.bubble.right"
        }
    }

    private func typePill(_ type: ContentType) -> some View {
        Text(type.label)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(type.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(type.color.opacity(0.12))
            .clipShape(Capsule())
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
