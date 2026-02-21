import SwiftUI

struct ChallengeCard: View {
    let item: ContentItem

    var body: some View {
        VStack(alignment: .leading, spacing: CardStyle.spacing) {
            TypeBadge(type: .challenge)

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
                if let minutes = item.estimatedMinutes {
                    Label("\(minutes) min", systemImage: "clock")
                        .font(.caption2)
                        .foregroundStyle(Color(.tertiaryLabel))
                }
                Spacer()
                Text("Start Challenge")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(ContentType.challenge.color)
                    .clipShape(Capsule())
            }
            .padding(.top, 4)
        }
        .padding(CardStyle.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: CardStyle.cornerRadius))
    }
}
