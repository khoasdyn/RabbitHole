import SwiftUI

struct DiscussionCard: View {
    let item: ContentItem

    var body: some View {
        VStack(alignment: .leading, spacing: CardStyle.spacing) {
            TypeBadge(type: .discussion)

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
                Spacer()
                Label("Join Discussion", systemImage: "arrow.right")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(ContentType.discussion.color)
            }
            .padding(.top, 4)
        }
        .padding(CardStyle.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: CardStyle.cornerRadius)
                .strokeBorder(ContentType.discussion.color.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: CardStyle.cornerRadius))
    }
}
