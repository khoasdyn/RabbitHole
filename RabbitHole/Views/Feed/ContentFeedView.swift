import SwiftUI
import FoundationModels

struct ContentFeedView: View {

    let topic: Topic
    var onBack: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var selectedItem: ContentItem?
    @State private var presentAsFullScreen = false
    @State private var generationService: ArticleGenerationService?
    @State private var generationTask: Task<Void, Never>?
    @State private var modelUnavailable = false

    private var sortedItems: [ContentItem] {
        topic.contentItems
            .filter { $0.level == 1 }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    private var needsGeneration: Bool {
        topic.contentItems.filter { $0.level == 1 }.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    feedHeader

                    if modelUnavailable {
                        modelUnavailableCard
                    }

                    ForEach(sortedItems) { item in
                        contentCard(for: item)
                    }

                    if let service = generationService, !service.isCompleted {
                        ArticleCardSkeleton(
                            partial: service.partial,
                            hasFailed: service.hasFailed
                        )
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
                    LevelPill(level: .newcomer, color: topic.accentColor)
                }
            }
            .sheet(item: sheetBinding) { item in
                detailView(for: item)
            }
            .fullScreenCover(item: fullScreenBinding) { item in
                detailView(for: item)
            }
            .onAppear {
                startGenerationIfNeeded()
            }
        }
    }

    // MARK: - Generation

    private func startGenerationIfNeeded() {
        guard needsGeneration else { return }
        guard generationTask == nil else { return }

        guard SystemLanguageModel.default.availability == .available else {
            modelUnavailable = true
            return
        }

        let service = ArticleGenerationService(topic: topic)
        self.generationService = service
        service.prewarm()

        // Stored Task survives view disappearance — won't cancel on navigation
        generationTask = Task { @MainActor in
            await service.generateArticle(context: modelContext)

            if service.isCompleted {
                self.generationService = nil
            }
        }
    }

    // MARK: - Presentation bindings

    private var sheetBinding: Binding<ContentItem?> {
        Binding(
            get: { presentAsFullScreen ? nil : selectedItem },
            set: { selectedItem = $0 }
        )
    }

    private var fullScreenBinding: Binding<ContentItem?> {
        Binding(
            get: { presentAsFullScreen ? selectedItem : nil },
            set: { selectedItem = $0 }
        )
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

    // MARK: - Model unavailable

    private var modelUnavailableCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "wand.and.stars")
                .font(.largeTitle)
                .foregroundStyle(Color(.tertiaryLabel))

            Text("Apple Intelligence is required to generate content.")
                .font(.subheadline)
                .foregroundStyle(Color(.secondaryLabel))
                .multilineTextAlignment(.center)

            Text("Enable it in Settings to explore custom topics.")
                .font(.caption)
                .foregroundStyle(Color(.tertiaryLabel))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Card router

    @ViewBuilder
    private func contentCard(for item: ContentItem) -> some View {
        switch item.contentType {
        case .article:
            Button { select(item, fullScreen: false) } label: { ArticleCard(item: item) }
                .buttonStyle(.plain)
        case .quiz:
            Button { select(item, fullScreen: true) } label: { QuizCard(item: item) }
                .buttonStyle(.plain)
        case .video:
            Button { select(item, fullScreen: true) } label: { VideoCard(item: item) }
                .buttonStyle(.plain)
        case .imageCard:
            Button { select(item, fullScreen: false) } label: { ImageCard(item: item) }
                .buttonStyle(.plain)
        case .discussion:
            Button { select(item, fullScreen: true) } label: { DiscussionCard(item: item) }
                .buttonStyle(.plain)
        case .challenge:
            Button { select(item, fullScreen: false) } label: { ChallengeCard(item: item) }
                .buttonStyle(.plain)
        case .survey:
            SurveyCard(item: item)
        }
    }

    private func select(_ item: ContentItem, fullScreen: Bool) {
        presentAsFullScreen = fullScreen
        selectedItem = item
    }

    // MARK: - Detail router

    @ViewBuilder
    private func detailView(for item: ContentItem) -> some View {
        switch item.contentType {
        case .article:  ArticleDetailView(item: item)
        case .quiz:     QuizFlowView(item: item)
        case .video:    VideoDetailView(item: item)
        case .imageCard: ImageDetailView(item: item)
        case .discussion: DiscussionThreadView(item: item)
        case .challenge: ChallengeDetailView(item: item)
        case .survey:   EmptyView()
        }
    }
}

// MARK: - Level pill

private struct LevelPill: View {
    let level: Level
    let color: Color

    var body: some View {
        Text("Level \(level.rawValue) · \(level.label)")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundStyle(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }
}
