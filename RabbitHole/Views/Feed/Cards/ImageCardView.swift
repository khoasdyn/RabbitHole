import SwiftUI

struct ImageCardView: View {

    let item: ContentItem
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Real image or fallback
            ZStack {
                if let url = Bundle.main.url(forResource: "image-demo", withExtension: "png"),
                   let data = try? Data(contentsOf: url),
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 160)
                        .clipped()
                } else {
                    LinearGradient(
                        colors: [accentColor.opacity(0.3), accentColor.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 160)

                    Image(systemName: "photo")
                        .font(.system(size: 36))
                        .foregroundStyle(accentColor.opacity(0.5))
                }
            }
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 14, topTrailingRadius: 14))

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
        Label(ContentType.imageCard.label, systemImage: ContentType.imageCard.iconName)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(ContentType.imageCard.color)
    }
}
