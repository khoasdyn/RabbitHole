import SwiftUI

struct QuizCard: View {

    let item: ContentItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            typeBadge

            Text(item.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color(.label))
                .fixedSize(horizontal: false, vertical: true)

            if let subtitle = item.subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color(.secondaryLabel))
            }

            HStack {
                Label("3 questions", systemImage: "list.number")
                    .font(.caption2)
                    .foregroundStyle(Color(.tertiaryLabel))
                Spacer()
                Text("Start Quiz")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(ContentType.quiz.color)
            }
            .padding(.top, 4)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(ContentType.quiz.color.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var typeBadge: some View {
        Label(ContentType.quiz.label, systemImage: ContentType.quiz.iconName)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(ContentType.quiz.color)
    }
}
