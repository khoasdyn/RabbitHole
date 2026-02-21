# Rabbit Hole: Technical requirements

Companion document to `rabbit-hole-prd.md`. Defines the technical stack, architecture, coding standards, and implementation guidelines.


## Tech stack

| Component | Technology |
|-----------|------------|
| **IDE** | Xcode (latest stable) |
| **Framework** | SwiftUI |
| **Language** | Swift |
| **Minimum target** | iOS 26 |
| **Data layer** | SwiftData (`@Model` classes, `ModelContainer`) |
| **Navigation** | `NavigationStack`, conditional root view (tab bar planned) |
| **Media** | `AVKit` for video player |
| **Icons** | SF Symbols exclusively |
| **Animations** | SwiftUI native |
| **Dependencies** | None |

Everything uses native SwiftUI and Apple-provided frameworks only.


## Color system

**Only iOS built-in system colors.** No custom hex values, no `Color` extensions, no hard-coded RGB.

- Backgrounds: `Color(.systemBackground)`, `.secondarySystemBackground`, `.tertiarySystemBackground`
- Text: `Color(.label)`, `.secondaryLabel`, `.tertiaryLabel`
- Accents: System semantic colors (`.blue`, `.orange`, `.green`, etc.) for content type indicators and topic theming
- Dark aesthetic: Achieved via `preferredColorScheme(.dark)` modifier, not custom dark colors

System colors adapt automatically to light/dark mode and accessibility settings.


## SwiftData architecture

### Model container

Configured on `WindowGroup` in `RabbitHoleApp.swift`:

```swift
.modelContainer(for: [Topic.self, ContentItem.self, UserProgress.self])
```

### Models (as currently implemented)

```swift
@Model final class Topic {
    var question: String
    var subjectArea: String       // e.g. "Philosophy", "Custom"
    var accentColorName: String   // maps to system Color via extension
    var iconName: String          // SF Symbol name
    var isActive: Bool
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \ContentItem.topic)
    var contentItems: [ContentItem]
    @Relationship(deleteRule: .cascade, inverse: \UserProgress.topic)
    var progress: UserProgress?
}

@Model final class ContentItem {
    var type: String              // ContentType raw value
    var level: Int
    var title: String
    var subtitle: String?
    var body: String?             // plain text or JSON for structured types
    var estimatedMinutes: Int?
    var isCompleted: Bool
    var sortOrder: Int
    var topic: Topic?

    var contentType: ContentType  // computed, not persisted
}

@Model final class UserProgress {
    var currentLevel: Int
    var completedItems: Int
    var levelUnlockedAt: Date?
    var topic: Topic?
}
```

### Data querying

`@Query` in `ContentView` fetches all topics. Content items are accessed through the `Topic.contentItems` relationship and filtered/sorted in the view.

### Mock data seeding

`MockDataSeeder.seedIfNeeded(context:)` checks if any topics exist via `fetchCount`. If zero, it inserts 5 seeded topics and Level 1 content for the Stoicism question. Called in `ContentView.task`.

### User-created topics

When a user submits a custom question, `ContentView` creates a new `Topic` with `subjectArea: "Custom"`, a round-robin accent color, and no content items. The topic persists in SwiftData.


## Architecture

The prototype uses a lightweight approach rather than strict MVVM:

- **Models:** `@Model` classes with SwiftData persistence
- **Views:** SwiftUI views using `@Query` and `@Environment(\.modelContext)` directly
- **Shared components:** `TypeBadge`, `CardStyle`, `BundleImage` in `Components/`
- **No ViewModels** in the current build. `@Query` handles data reactivity. ViewModels will be introduced when business logic complexity warrants it (e.g., level progression).

### Folder structure (current)

```
RabbitHole/
├── RabbitHoleApp.swift
├── ContentView.swift
├── Models/
│   ├── Topic.swift
│   ├── ContentItem.swift
│   ├── UserProgress.swift
│   ├── ContentType.swift          // enum with label, iconName, color
│   └── Level.swift                // enum with label, description
├── Components/
│   └── SharedComponents.swift     // TypeBadge, CardStyle, BundleImage
├── Extensions/
│   └── Topic+UI.swift             // accentColor computed property
├── Views/
│   ├── Welcome/
│   │   ├── WelcomeView.swift      // prompt input + curated cards
│   │   └── QuestionCardView.swift
│   └── Feed/
│       ├── ContentFeedView.swift  // feed + card/detail routing
│       ├── Cards/
│       │   ├── ArticleCard.swift
│       │   ├── VideoCard.swift
│       │   ├── ImageCard.swift
│       │   ├── QuizCard.swift
│       │   ├── DiscussionCard.swift
│       │   ├── SurveyCard.swift
│       │   └── ChallengeCard.swift
│       └── Detail/
│           ├── ArticleDetailView.swift
│           ├── VideoDetailView.swift
│           ├── ImageDetailView.swift
│           ├── QuizFlowView.swift
│           ├── DiscussionThreadView.swift
│           └── ChallengeDetailView.swift
├── MockData/
│   ├── MockDataSeeder.swift
│   └── StoicismMockContent.swift
└── Resources/
    ├── Images/
    │   └── image-demo.png
    └── Videos/
        └── video-demo.mp4
```

### Navigation (current)

`ContentView` conditionally shows `WelcomeView` or `ContentFeedView` based on `selectedTopic` state. Detail views are presented via `.sheet` (articles, images, challenges) or `.fullScreenCover` (quizzes, discussions, videos) from a single `selectedItem` state in `ContentFeedView`.

### Navigation (planned)

`TabView` with Feed, Progress, and Explore tabs. `NavigationStack` within each tab.


## Coding standards

### Native components first

Prefer native SwiftUI components: `ScrollView`, `LazyVStack`, `NavigationStack`, `Sheet`, `fullScreenCover`, `VideoPlayer`, `Label`, `Button`. Only build custom when no native equivalent exists.

### Conventions

- Types: `UpperCamelCase`. Properties: `lowerCamelCase`. Booleans: `isCompleted`, `hasUnlockedNextLevel`
- Most restrictive access control. `private` by default.
- `@State` for view-local state, `@Query` for SwiftData, `@Environment` for context
- Extract subviews when body exceeds ~40 lines
- No force unwrapping. No magic numbers (use `CardStyle` constants).
- Files under 200 lines. `// MARK: -` for organization.


## Content data format

Type-specific data is stored as JSON in `ContentItem.body`:

- **Articles:** Plain text body
- **Quizzes:** `{"questions":[{"question":"...","options":[...],"correctIndex":0,"explanation":"..."}]}`
- **Surveys:** `{"options":[...],"results":[28,31,24,17]}`
- **Discussions:** `{"exchanges":[{"role":"prompt","text":"..."},{"role":"follow_up_1","text":"..."}]}`
- **Challenges:** `{"instructions":"...","completionPrompt":"..."}`
- **Videos/Images:** `body` is nil. Resources loaded from bundle.

### Question quality in mock data

All curated questions follow the content question guidelines from the PRD: specific, under 15 words, conversational, provocative, not definitional. Content item titles follow the same spirit.


## Performance

- `LazyVStack` for feed rendering
- Video thumbnail generated async via `AVAssetImageGenerator`
- `.task` for data loading
- Tested on simulator; real device testing recommended


## Accessibility baseline

- Minimum 44x44pt tap targets
- `accessibilityLabel` on interactive elements
- Semantic SwiftUI elements (`Button`, `Label`) over `onTapGesture`
- Dynamic Type via built-in text styles


## Future technical considerations (out of scope)

- **AI integration:** Claude API for content generation, real-time discussions
- **Networking layer:** `URLSession`-based API client
- **Authentication:** Sign in with Apple
- **Push notifications:** APNs for streaks and reminders
- **Analytics:** Event tracking for engagement and drop-off
- **Media pipeline:** Server-side video/audio generation with caching
