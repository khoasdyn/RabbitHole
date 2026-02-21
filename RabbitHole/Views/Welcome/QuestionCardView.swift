import SwiftUI

struct QuestionCardView: View {

    // MARK: - Constants

    private enum Layout {
        static let cardCornerRadius: CGFloat = 16
        static let accentBarWidth: CGFloat = 4
        static let cardPadding: CGFloat = 16
        static let pillHorizontalPadding: CGFloat = 10
        static let pillVerticalPadding: CGFloat = 5
        static let pillCornerRadius: CGFloat = 8
        static let spacingBetweenPillAndQuestion: CGFloat = 12
        static let minimumTapArea: CGFloat = 44
    }

    // MARK: - Properties

    let topic: Topic
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                accentBar
                cardContent
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: Layout.cardCornerRadius))
        }
        .buttonStyle(QuestionCardButtonStyle())
        .accessibilityLabel(topic.question)
        .accessibilityHint("Tap to explore this question")
    }

    // MARK: - Subviews

    private var accentBar: some View {
        topic.accentColor
            .frame(width: Layout.accentBarWidth)
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: Layout.spacingBetweenPillAndQuestion) {
            subjectPill
            questionText
        }
        .padding(Layout.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var subjectPill: some View {
        Label(topic.subjectArea, systemImage: topic.iconName)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(topic.accentColor)
            .padding(.horizontal, Layout.pillHorizontalPadding)
            .padding(.vertical, Layout.pillVerticalPadding)
            .background(topic.accentColor.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: Layout.pillCornerRadius))
    }

    private var questionText: some View {
        Text(topic.question)
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(Color(.label))
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Button style

private struct QuestionCardButtonStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
