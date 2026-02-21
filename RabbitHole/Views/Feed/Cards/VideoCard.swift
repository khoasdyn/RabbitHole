import SwiftUI
import AVKit

struct VideoCard: View {

    let item: ContentItem
    @State private var thumbnail: UIImage?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail
            ZStack {
                Color(.tertiarySystemBackground)
                    .frame(height: 180)

                if let thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipped()
                }

                // Play overlay
                VStack(spacing: 8) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.white.opacity(0.9))
                        .shadow(radius: 4)

                    if let minutes = item.estimatedMinutes {
                        Text("\(minutes) min")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.black.opacity(0.5))
                            .clipShape(Capsule())
                    }
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
        .task {
            await generateThumbnail()
        }
    }

    private var typeBadge: some View {
        Label(ContentType.video.label, systemImage: ContentType.video.iconName)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(ContentType.video.color)
    }

    private func generateThumbnail() async {
        guard let url = Bundle.main.url(forResource: "video-demo", withExtension: "mp4") else { return }
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 600, height: 400)
        do {
            let cgImage = try await generator.image(at: .init(seconds: 1, preferredTimescale: 600)).image
            await MainActor.run {
                thumbnail = UIImage(cgImage: cgImage)
            }
        } catch {}
    }
}
