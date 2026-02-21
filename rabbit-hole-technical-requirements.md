# Rabbit Hole: Technical requirements

Companion document to `rabbit-hole-prd.md`. This document defines the technical stack, architecture, coding standards, and implementation guidelines for the Rabbit Hole prototype.


## Tech stack

| Component | Technology |
|-----------|------------|
| **IDE** | Xcode (latest stable) |
| **Framework** | SwiftUI |
| **Language** | Swift |
| **Minimum target** | iOS 26 |
| **Architecture** | MVVM (Model-View-ViewModel) |
| **Data layer** | SwiftData for persistence, mock data seeded on first launch |
| **Navigation** | SwiftUI `NavigationStack` and `TabView` |
| **Media** | `AVKit` for video player UI |
| **Icons** | SF Symbols exclusively |
| **Animations** | SwiftUI native animations and transitions |
| **Dependencies** | None. Zero third-party packages. |
| **Persistence** | SwiftData with `@Model` classes and `ModelContainer` |

Everything must be achievable with native SwiftUI and Apple-provided frameworks only.


## Color system

Use **only iOS built-in system colors**. No custom hex values, no custom `Color` extensions, no hard-coded RGB.

### Backgrounds and surfaces

- `Color(.systemBackground)` for primary backgrounds
- `Color(.secondarySystemBackground)` for card surfaces
- `Color(.tertiarySystemBackground)` for elevated elements
- `Color(.systemGroupedBackground)` and `Color(.secondarySystemGroupedBackground)` for grouped layouts

### Text

- `Color(.label)` for primary text
- `Color(.secondaryLabel)` for subtitles and secondary info
- `Color(.tertiaryLabel)` for placeholders and hints

### Accents and semantics

- `.accentColor` / `.tint()` for primary interactive elements
- `Color.blue`, `Color.orange`, `Color.green`, `Color.purple`, `Color.red`, etc. (the system-provided semantic colors) for content type indicators, level theming, and accent variation
- `Color(.separator)` for dividers and borders
- `Color(.systemFill)` and variants for subtle fills

### Why this matters

System colors automatically adapt to light mode, dark mode, and increased contrast accessibility settings. By using them exclusively, the app gets correct appearance across all contexts for free with no manual color scheme management.

The dark, immersive aesthetic described in the PRD should be achieved through the app's `preferredColorScheme(.dark)` modifier and thoughtful use of system background tiers, not through custom dark color values.


## SwiftData architecture

### Model container setup

Configure the `ModelContainer` at the app entry point and inject it into the environment:

```swift
@main
struct RabbitHoleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Topic.self, ContentItem.self, UserProgress.self])
    }
}
```

### Model definitions

All persistent data types use `@Model` classes instead of plain structs. Example:

```swift
@Model
class Topic {
    var question: String
    var subjectArea: String
    var accentColorName: String
    var isActive: Bool
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var contentItems: [ContentItem]
    @Relationship(deleteRule: .cascade) var progress: UserProgress?
}

@Model
class ContentItem {
    var type: String  // maps to ContentType enum raw value
    var level: Int
    var title: String
    var subtitle: String?
    var estimatedMinutes: Int?
    var isCompleted: Bool
    var topic: Topic?
}

@Model
class UserProgress {
    var currentLevel: Int
    var completedItems: Int
    var levelUnlockedAt: Date?
    var topic: Topic?
}
```

### Querying data

Use `@Query` in views to fetch data directly:

```swift
struct ContentFeedView: View {
    @Query(sort: \ContentItem.level) var items: [ContentItem]
    // ...
}
```

For filtered queries (e.g., content for the active topic at the current level), use `#Predicate` and pass filter parameters.

### Mock data seeding

On first launch, seed the SwiftData store with pre-built mock content. Use a flag in `UserDefaults` to check whether seeding has already occurred:

```swift
func seedMockDataIfNeeded(context: ModelContext) {
    let hasSeeded = UserDefaults.standard.bool(forKey: "hasSeededMockData")
    guard !hasSeeded else { return }

    // Insert mock topics, content items, and initial progress
    // ...

    UserDefaults.standard.set(true, forKey: "hasSeededMockData")
}
```

Call this in the app's root view `.onAppear` or in the `App` init.

### Why SwiftData over JSON files

SwiftData gives us queryable, filterable data with relationships (topic → content items → progress) out of the box. It also establishes the correct persistence pattern for when the app moves beyond the prototype, so the transition to real data will require no architectural changes.


## MVVM pattern

The project follows a strict MVVM separation:

**Model:** Plain Swift structs representing data (topics, content items, levels, quiz questions, progress states). All models conform to `Identifiable` and `Codable` where appropriate.

**View:** SwiftUI views that are purely declarative. Views should contain no business logic, no data transformation, and no direct data manipulation. They read state from ViewModels and send user actions back to them.

**ViewModel:** `@Observable` classes (or `ObservableObject` with `@Published` if broader compatibility is needed) that own the business logic, hold state, and expose computed properties for views to consume. One ViewModel per major screen or feature area.

### Folder structure

```
RabbitHole/
├── App/
│   └── RabbitHoleApp.swift
├── Models/
│   ├── Topic.swift              // @Model
│   ├── ContentItem.swift        // @Model
│   ├── UserProgress.swift       // @Model
│   ├── ContentType.swift        // enum
│   ├── Level.swift              // enum or struct
│   └── ContentPayload.swift     // type-specific data
├── ViewModels/
│   ├── QuestionSelectionViewModel.swift
│   ├── ContentFeedViewModel.swift
│   ├── ProgressViewModel.swift
│   └── QuestionManagerViewModel.swift
├── Views/
│   ├── Welcome/
│   │   └── WelcomeView.swift
│   │   └── QuestionCardView.swift
│   ├── Feed/
│   │   ├── ContentFeedView.swift
│   │   ├── Cards/
│   │   │   ├── VideoCardView.swift
│   │   │   ├── ArticleCardView.swift
│   │   │   ├── ImageCardView.swift
│   │   │   ├── QuizCardView.swift
│   │   │   ├── DiscussionCardView.swift
│   │   │   ├── SurveyCardView.swift
│   │   │   └── ChallengeCardView.swift
│   │   └── Detail/
│   │       ├── VideoDetailView.swift
│   │       ├── ArticleDetailView.swift
│   │       ├── QuizFlowView.swift
│   │       ├── DiscussionThreadView.swift
│   │       └── ChallengeDetailView.swift
│   ├── Progress/
│   │   ├── LevelProgressView.swift
│   │   └── LevelUpView.swift
│   └── Explore/
│       └── QuestionManagementView.swift
├── Components/
│   ├── LevelBadge.swift
│   ├── ProgressBar.swift
│   └── ContentTypeIcon.swift
├── MockData/
│   ├── MockDataSeeder.swift
│   ├── StoicismMockContent.swift
│   └── AstrophysicsMockContent.swift
├── Extensions/
│   └── (any small utility extensions)
├── Resources/
│   └── Assets.xcassets
└── Preview Content/
    └── Preview Assets.xcassets
```

### Navigation architecture

Use SwiftUI's `NavigationStack` with a path-based approach for programmatic navigation. The root container is a `TabView` with three tabs (Feed, Progress, Explore) as defined in the PRD.

```swift
// Conceptual structure
TabView {
    NavigationStack { ContentFeedView() }
        .tabItem { Label("Feed", systemImage: "rectangle.stack") }

    NavigationStack { LevelProgressView() }
        .tabItem { Label("Progress", systemImage: "chart.bar") }

    NavigationStack { QuestionManagementView() }
        .tabItem { Label("Explore", systemImage: "safari") }
}
```


## Coding standards

### Native components first

Always prefer native SwiftUI components over custom implementations. Specifically:

- Use `List`, `ScrollView`, `LazyVStack` for content lists, not custom scroll implementations
- Use `NavigationStack` and `NavigationLink` for navigation, not manual view swapping
- Use `TabView` for tab navigation
- Use `Sheet`, `fullScreenCover`, and `popover` for modal presentations
- Use `ProgressView` for loading states
- Use `Toggle`, `Picker`, `Slider` for form inputs
- Use `Label` with SF Symbols for icon-text pairs
- Use `AsyncImage` for image loading patterns (even with local mock data, to establish the pattern)
- Use native `VideoPlayer` from `AVKit` for video player UI
- Use `withAnimation`, `matchedGeometryEffect`, and `.transition()` for animations rather than manual frame/offset manipulation

Only build a custom component when no native equivalent exists or when the native component cannot achieve the required design.

### Swift and SwiftUI conventions

**Naming:** Follow Swift API Design Guidelines. Types and protocols are `UpperCamelCase`. Properties, methods, and variables are `lowerCamelCase`. Boolean properties read as assertions (e.g., `isCompleted`, `hasUnlockedNextLevel`).

**Access control:** Mark everything with the most restrictive access level that works. Use `private` for properties and methods that don't need external access. Use `private(set)` for read-only external properties.

**Property wrappers:** Use the correct wrapper for the job. `@State` for view-local state. `@Binding` for parent-owned state passed to child views. `@Environment` for environment values. `@Observable` (or `@StateObject`/`@ObservedObject`) for ViewModels.

**View composition:** Break views into small, focused components. If a view body exceeds roughly 40 lines, extract subviews. Use `ViewBuilder` functions or computed properties for conditional sections within a view, but prefer extracted subviews over long computed properties.

**No force unwrapping.** Never use `!` to force unwrap optionals. Use `if let`, `guard let`, or nil coalescing (`??`) with sensible defaults.

**No magic numbers or strings.** Define constants for spacing values, corner radii, font sizes, and durations. Group them in a dedicated `Constants` enum or extend `CGFloat`/`Font` as appropriate.

### Code cleanliness

- Remove all commented-out code before committing
- Remove all unused imports
- Every file should have a single clear responsibility
- No print statements left in production code (use `#if DEBUG` if needed during development)
- Keep files under 200 lines where possible; if a file grows beyond this, look for extraction opportunities
- Use `// MARK: -` sections to organize larger files logically


## Mock data guidelines

### Data format

Mock data is defined as static arrays in dedicated Swift files under `MockData/` and inserted into the SwiftData `ModelContext` on first launch via `MockDataSeeder`. This keeps mock content separate from app logic while using the same persistence layer the production app will use.

```swift
// Example: MockDataSeeder.swift
struct MockDataSeeder {
    static func seed(context: ModelContext) {
        let stoicism = Topic(
            question: "Were the Stoics right that most of your problems are imaginary?",
            subjectArea: "Philosophy",
            accentColorName: "orange",
            isActive: true,
            createdAt: .now
        )
        context.insert(stoicism)

        let item = ContentItem(
            type: ContentType.article.rawValue,
            level: 1,
            title: "What is Stoicism?",
            subtitle: "The ancient philosophy that still matters",
            estimatedMinutes: 4,
            isCompleted: false
        )
        item.topic = stoicism
        context.insert(item)

        // ... more items
    }
}
```

### Content item modeling

All content types share a single `ContentItem` model (as defined in the SwiftData architecture section above) with a `ContentType` enum to differentiate them. Type-specific data (article body text, quiz questions, discussion exchanges, etc.) can be stored as encoded JSON in a `String` property or as separate related `@Model` classes depending on complexity:

```swift
enum ContentType: String, Codable, CaseIterable {
    case video
    case article
    case imageCard
    case quiz
    case discussion
    case survey
    case challenge
}
```

The feed renders content polymorphically by switching on `ContentType` to select the appropriate card view.

### Mock data should feel real

Even though this is mock data, it should read like real content, not "Lorem ipsum" or "Test Article 1." The prototype will be demonstrated and evaluated on feel, so realistic mock content is important. Use actual facts about Stoicism and Astrophysics. Write actual quiz questions with plausible wrong answers.

### Question quality in mock data

All proposed questions displayed on the welcome screen must follow the content question guidelines defined in the PRD. Specifically:

- Every question must be specific and not broad (no "What is X?" style)
- Every question must be under 15 words
- Every question must feel conversational, not academic
- Every question should provoke curiosity, surprise, or a desire to know the answer
- Questions should span a variety of subject areas and tonal angles

When writing content items within a topic, the titles and framing of individual pieces should also follow this spirit. An article titled "Marcus Aurelius wrote a journal no one was supposed to read" is better than "The Life of Marcus Aurelius." A quiz question that tells a micro-story is better than one that asks for a definition.


## Performance considerations

Even as a prototype, the app should feel fast and smooth:

- Use `LazyVStack` or `LazyVGrid` inside `ScrollView` for the content feed so cards are rendered on demand, not all at once
- Avoid heavy computation in view bodies; defer to ViewModels
- Use `.task` or `.onAppear` for data loading rather than initializers
- Keep animations at 60fps by animating only simple properties (opacity, offset, scale) and avoiding layout-triggering animations on large view trees
- Test on a real device, not just the simulator, to validate scroll performance


## Accessibility baseline

The prototype should include basic accessibility support from the start:

- All interactive elements must be tappable with a minimum 44x44pt hit area
- All images should have meaningful `accessibilityLabel` values
- Use semantic SwiftUI elements (`Button`, `NavigationLink`, `Label`) rather than `onTapGesture` on plain `View`s where possible, as they automatically support accessibility
- Support Dynamic Type by using SwiftUI's built-in text styles (`.title`, `.body`, `.caption`) rather than fixed font sizes
- Ensure sufficient color contrast between text and backgrounds, especially on the dark color palette


## Future technical considerations (out of scope)

Documented for awareness only. Not part of the prototype.

- **Networking layer:** `URLSession`-based API client for fetching AI-generated content from a backend
- **Authentication:** Sign in with Apple, token-based session management
- **Push notifications:** APNs for daily reminders and streak nudges
- **Analytics:** Event tracking for content engagement, level progression, and drop-off analysis
- **AI integration:** Anthropic Claude API for real-time discussion and content generation
- **Media pipeline:** Server-side video/audio generation with on-device caching and streaming
