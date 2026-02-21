import SwiftUI

struct VideoCard: View {

    let item: ContentItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail placeholder
            ZStack {
                Color(.tertiarySystemBackground)
                    .frame(height: 180)

                VStack(spacing: 8) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.white.opacity(0.9))

                    if let minutes = item.estimatedMinutes {
                        Text("\(minutes) min")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
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
                        .lineLimit(2)
                }
            }
            .padding(14)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var typeBadge: some View {
        Label(ContentType.video.label, systemImage: ContentType.video.iconName)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(ContentType.video.color)
    }
}
