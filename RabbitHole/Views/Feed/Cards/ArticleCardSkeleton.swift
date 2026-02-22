import SwiftUI
import FoundationModels

struct ArticleCardSkeleton: View {

    let partial: GeneratedArticle.PartiallyGenerated?
    var hasFailed: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: CardStyle.spacing) {
            HStack {
                TypeBadge(type: .article)
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

            if let title = partial?.title {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.label))
                    .fixedSize(horizontal: false, vertical: true)
                    .contentTransition(.opacity)
            } else {
                ShimmerLine(height: 14)
                ShimmerLine(width: 180, height: 14)
            }

            if let subtitle = partial?.subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color(.secondaryLabel))
                    .lineLimit(2)
                    .contentTransition(.opacity)
            } else {
                ShimmerLine(width: 220, height: 11)
            }
        }
        .padding(CardStyle.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: CardStyle.cornerRadius))
        .animation(.easeOut(duration: 0.3), value: partial?.title)
    }
}

// MARK: - Shimmer placeholder line

private struct ShimmerLine: View {

    var width: CGFloat? = nil
    let height: CGFloat

    @State private var isAnimating = false

    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color(.tertiarySystemFill))
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil, alignment: .leading)
            .opacity(isAnimating ? 0.4 : 0.8)
            .animation(
                .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear { isAnimating = true }
    }
}
