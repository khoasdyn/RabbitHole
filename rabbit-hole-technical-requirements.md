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
| **AI generation** | FoundationModels (on-device, Apple Intelligence) |
| **Navigation** | `NavigationStack`, conditional root view (tab bar planned) |
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

When a user submits a custom question, `ContentView` creates a new `Topic` with `subjectArea: "Custom"`, a round-robin accent color, and no content items. The topic persists in SwiftData. On-device AI generates an initial article when the feed loads.


## On-device AI generation (FoundationModels)

### Overview

Article content and follow-up questions are generated entirely on-device using Apple's FoundationModels framework (iOS 26+). No network calls, no API keys, no data leaves the device.

### Generable types

```swift
@Generable struct GeneratedArticle {
    let title: String       // @Guide: engaging, under 15 words
    let subtitle: String    // @Guide: one-line angle hint
    let body: String        // @Guide: under 200 words, conversational
    let estimatedMinutes: Int
}

@Generable struct GeneratedFollowUps {
    let questions: [FollowUpQuestion]  // @Guide: 3–5 questions
}

@Generable struct FollowUpQuestion {
    let text: String        // @Guide: specific, under 15 words
}
```

### Services

**`ArticleGenerationService`** — `@Observable @MainActor` class that manages `LanguageModelSession`, streams article generation, and persists completed articles to SwiftData. Supports both initial topic articles and follow-up question articles via separate prompt construction.

**`FollowUpService`** — Generates 3–5 follow-up questions based on the topic and existing articles. Uses `session.respond` (non-streaming) since output is small. Prompt includes existing article titles to avoid repetition.

### Generation flow

1. User selects topic with no content → `ArticleGenerationService` creates session, calls `prewarm()`
2. Article streams via `session.streamResponse` → partial updates shown in skeleton card
3. Completed article persisted as `ContentItem` in SwiftData
4. `FollowUpService` generates 3–5 follow-up questions
5. User taps follow-up → new article generates → new follow-ups appear → cycle repeats

### Availability check

```swift
guard SystemLanguageModel.default.availability == .available else {
    // Show unavailable message
    return
}
```

### Task management

Generation uses stored `Task` references (`@State private var generationTask: Task<Void, Never>?`) rather than `.task` modifier to prevent cancellation when the user navigates to detail views.


## Architecture

The prototype uses a lightweight approach rather than strict MVVM:

- **Models:** `@Model` classes with SwiftData persistence
- **Services:** `@Observable @MainActor` classes for AI generation (`ArticleGenerationService`, `FollowUpService`)
- **Views:** SwiftUI views using `@Query` and `@Environment(\.modelContext)` directly
- **Shared components:** `TypeBadge`, `CardStyle` in `Components/`
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
│   ├── ContentType.swift          // enum: article, quiz, discussion, challenge
│   └── Level.swift                // enum with label, description
├── Services/
│   ├── GeneratedArticle.swift     // @Generable article output
│   ├── GeneratedFollowUps.swift   // @Generable follow-up questions
│   ├── ArticleGenerationService.swift
│   └── FollowUpService.swift
├── Components/
│   └── SharedComponents.swift     // TypeBadge, CardStyle
├── Extensions/
│   └── Topic+UI.swift             // accentColor computed property
├── Views/
│   ├── Welcome/
│   │   ├── WelcomeView.swift      // prompt input + curated cards
│   │   └── QuestionCardView.swift
│   └── Feed/
│       ├── ContentFeedView.swift  // feed + card/detail routing + AI orchestration
│       ├── FollowUpQuestionsView.swift
│       ├── Cards/
│       │   ├── ArticleCard.swift
│       │   ├── ArticleCardSkeleton.swift
│       │   ├── QuizCard.swift
│       │   ├── DiscussionCard.swift
│       │   └── ChallengeCard.swift
│       └── Detail/
│           ├── ArticleDetailView.swift
│           ├── QuizFlowView.swift
│           ├── DiscussionThreadView.swift
│           └── ChallengeDetailView.swift
└── MockData/
    ├── MockDataSeeder.swift
    └── StoicismMockContent.swift
```

### Navigation (current)

`ContentView` conditionally shows `WelcomeView` or `ContentFeedView` based on `selectedTopic` state. Detail views are presented via `.sheet` (articles, challenges) or `.fullScreenCover` (quizzes, discussions) from a single `selectedItem` state in `ContentFeedView`.

### Navigation (planned)

`TabView` with Feed, Progress, and Explore tabs. `NavigationStack` within each tab.


## Coding standards

### Native components first

Prefer native SwiftUI components: `ScrollView`, `LazyVStack`, `NavigationStack`, `Sheet`, `fullScreenCover`, `Label`, `Button`. Only build custom when no native equivalent exists.

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
- **Discussions:** `{"exchanges":[{"role":"prompt","text":"..."},{"role":"follow_up_1","text":"..."}]}`
- **Challenges:** `{"instructions":"...","completionPrompt":"..."}`

### Question quality in mock data

All curated questions follow the content question guidelines from the PRD: specific, under 15 words, conversational, provocative, not definitional. Content item titles follow the same spirit.


## Performance

- `LazyVStack` for feed rendering
- Model prewarming via `session.prewarm()` for faster AI response
- Stored `Task` references prevent unnecessary re-generation
- `.task` for data loading
- Tested on simulator; real device testing recommended


## Accessibility baseline

- Minimum 44x44pt tap targets
- `accessibilityLabel` on interactive elements
- Semantic SwiftUI elements (`Button`, `Label`) over `onTapGesture`
- Dynamic Type via built-in text styles


## Future technical considerations (out of scope)

- **Extended AI generation:** On-device generation for quizzes, discussions, and challenges
- **Networking layer:** `URLSession`-based API client (if external APIs needed)
- **Authentication:** Sign in with Apple
- **Push notifications:** APNs for streaks and reminders
- **Analytics:** Event tracking for engagement and drop-off
