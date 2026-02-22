import SwiftUI

struct GeneratingCardSkeleton: View {

    let contentType: ContentType
    var hasFailed: Bool = false

    @State private var isAnimating = false

    var body: some View {
        VStack(alignment: .leading, spacing: CardStyle.spacing) {
            HStack {
                TypeBadge(type: contentType)
                Spacer()
                if hasFailed {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                } else {
                    ProgressView()
                        .controlSize(.small)
                }
            }

            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.tertiarySystemFill))
                .frame(height: 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(isAnimating ? 0.4 : 0.8)

            RoundedRectangle(cornerRadius: 4)
                .fill(Color(.tertiarySystemFill))
                .frame(width: 180, height: 11)
                .opacity(isAnimating ? 0.4 : 0.8)
        }
        .padding(CardStyle.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: CardStyle.cornerRadius))
        .animation(
            .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
            value: isAnimating
        )
        .onAppear { isAnimating = true }
    }
}
