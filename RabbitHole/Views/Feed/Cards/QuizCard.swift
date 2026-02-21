import SwiftUI

struct QuizCard: View {
    let item: ContentItem

    var body: some View {
        VStack(alignment: .leading, spacing: CardStyle.spacing) {
            TypeBadge(type: .quiz)

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
        .padding(CardStyle.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: CardStyle.cornerRadius)
                .strokeBorder(ContentType.quiz.color.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: CardStyle.cornerRadius))
    }
}
