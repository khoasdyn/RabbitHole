import SwiftUI

struct ArticleCard: View {

    let item: ContentItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                typeBadge
                Spacer()
                if let minutes = item.estimatedMinutes {
                    Text("\(minutes) min read")
                        .font(.caption2)
                        .foregroundStyle(Color(.tertiaryLabel))
                }
            }

            Text(item.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color(.label))
                .fixedSize(horizontal: false, vertical: true)

            if let subtitle = item.subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color(.secondaryLabel))
                    .lineLimit(2)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var typeBadge: some View {
        Label(ContentType.article.label, systemImage: ContentType.article.iconName)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(ContentType.article.color)
    }
}
