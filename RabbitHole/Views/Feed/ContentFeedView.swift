import SwiftUI

struct ContentFeedView: View {

    let topic: Topic
    var onBack: () -> Void

    @State private var selectedArticle: ContentItem?
    @State private var selectedQuiz: ContentItem?

    private var sortedItems: [ContentItem] {
        topic.contentItems
            .filter { $0.level == 1 }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    feedHeader
                    ForEach(sortedItems) { item in
                        contentCard(for: item)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                    }
                }
                ToolbarItem(placement: .principal) {
                    LevelPill(level: 1, color: topic.accentColor)
                }
            }
            .sheet(item: $selectedArticle) { article in
                ArticleDetailView(item: article)
            }
            .fullScreenCover(item: $selectedQuiz) { quiz in
                QuizFlowView(item: quiz)
            }
        }
    }

    // MARK: - Header

    private var feedHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(topic.subjectArea.uppercased())
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(topic.accentColor)

            Text(topic.question)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color(.label))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }

    // MARK: - Card router

    @ViewBuilder
    private func contentCard(for item: ContentItem) -> some View {
        let type = ContentType(rawValue: item.type) ?? .article
        switch type {
        case .article:
            Button { selectedArticle = item } label: {
                ArticleCard(item: item)
            }
            .buttonStyle(.plain)
        case .quiz:
            Button { selectedQuiz = item } label: {
                QuizCard(item: item)
            }
            .buttonStyle(.plain)
        case .video:
            VideoCard(item: item)
        case .imageCard:
            ImageCardView(item: item, accentColor: topic.accentColor)
        case .survey:
            SurveyCard(item: item)
        case .discussion:
            DiscussionCard(item: item)
        case .challenge:
            ChallengeCard(item: item, accentColor: topic.accentColor)
        }
    }
}

// MARK: - Level pill

private struct LevelPill: View {
    let level: Int
    let color: Color

    var body: some View {
        Text("Level \(level) · Newcomer")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }
}
