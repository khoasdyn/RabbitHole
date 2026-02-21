import SwiftUI

struct ChallengeCard: View {

    let item: ContentItem
    let accentColor: Color

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
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var typeBadge: some View {
        Label(ContentType.challenge.label, systemImage: ContentType.challenge.iconName)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(ContentType.challenge.color)
    }
}
