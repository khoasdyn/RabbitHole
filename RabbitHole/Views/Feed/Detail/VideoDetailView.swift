import SwiftUI
import AVKit

struct VideoDetailView: View {

    let item: ContentItem
    @Environment(\.dismiss) private var dismiss
    @State private var player: AVPlayer?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Player
                ZStack {
                    Color.black
                    if let player {
                        VideoPlayer(player: player)
                    }
                }
                .frame(maxHeight: 300)

                // Info below
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Label(ContentType.video.label, systemImage: ContentType.video.iconName)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(ContentType.video.color)

                        Text(item.title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(Color(.label))
                            .fixedSize(horizontal: false, vertical: true)

                        if let subtitle = item.subtitle {
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundStyle(Color(.secondaryLabel))
                                .lineSpacing(4)
                        }

                        if let minutes = item.estimatedMinutes {
                            Label("\(minutes) min", systemImage: "clock")
                                .font(.caption)
                                .foregroundStyle(Color(.tertiaryLabel))
                        }

                        Button {
                            item.isCompleted = true
                            dismiss()
                        } label: {
                            Label(
                                item.isCompleted ? "Watched" : "Mark as Watched",
                                systemImage: item.isCompleted ? "checkmark.circle.fill" : "checkmark.circle"
                            )
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(.tertiarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .foregroundStyle(item.isCompleted ? Color(.tertiaryLabel) : ContentType.video.color)
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
                .scrollIndicators(.hidden)
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        player?.pause()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                if player == nil, let url = Bundle.main.url(forResource: "video-demo", withExtension: "mp4") {
                    player = AVPlayer(url: url)
                }
            }
            .onDisappear {
                player?.pause()
                player = nil
            }
        }
    }
}
