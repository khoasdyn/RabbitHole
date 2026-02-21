import SwiftUI

struct ImageCard: View {
    let item: ContentItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                if let uiImage = BundleImage.load(name: "image-demo", ext: "png") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: CardStyle.imageHeight)
                        .clipped()
                } else {
                    Color(.tertiarySystemBackground)
                        .frame(height: CardStyle.imageHeight)
                        .overlay {
                            Image(systemName: "photo")
                                .font(.system(size: 36))
                                .foregroundStyle(Color(.tertiaryLabel))
                        }
                }
            }
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: CardStyle.cornerRadius, topTrailingRadius: CardStyle.cornerRadius))

            VStack(alignment: .leading, spacing: 6) {
                TypeBadge(type: .imageCard)

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
            .padding(CardStyle.padding)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: CardStyle.cornerRadius))
    }
}
