# How to use Apple Foundation Framework

This guide covers the Foundation framework APIs most relevant to iOS/macOS SwiftUI development. Every code pattern here is drawn from or directly applicable to real project structures: a SimpleDictionary app using on-device AI for word definitions, and a WWDC 2025 FoundationModels code-along that generates travel itineraries with streaming output and tool use.

Both projects share common Foundation patterns: `@Observable` for state management, `Codable` for JSON parsing, `Bundle` for loading resources, structured concurrency with `async/await`, and the new `FoundationModels` framework for on-device generative AI. This guide explains each pattern in depth, with code study sections showing exactly how they work.


## The Observation framework (`@Observable`)

The Observation framework, introduced in iOS 17, replaces the older Combine-based `ObservableObject` pattern. It uses the `@Observable` macro to automatically track which stored properties a SwiftUI view reads, and only triggers re-renders when those specific properties change. This is a significant performance improvement over `ObservableObject`, where any `@Published` property change would re-render all observing views regardless of which property they actually used.

### How it works in your projects

Both projects use the same pattern: an `@Observable` class annotated with `@MainActor` that holds mutable state the view reads.

```swift
// From DictionaryGenerator.swift (SimpleDictionary)
import Observation

@Observable
@MainActor
final class DictionaryGenerator {
    var error: Error?
    private var session: LanguageModelSession
    private(set) var entry: DictionaryEntry.PartiallyGenerated?
}
```

```swift
// From ItineraryGenerator.swift (WWDC2025 code-along)
@Observable
@MainActor
final class ItineraryGenerator {
    var error: Error?
    let landmark: Landmark
    private var session: LanguageModelSession
    private(set) var itinerary: Itinerary.PartiallyGenerated?
}
```

The `@MainActor` annotation ensures all property mutations happen on the main thread, which is required for SwiftUI view updates. Without it, modifying `entry` or `itinerary` from an async context could cause runtime warnings or undefined behavior.

### How SwiftUI consumes `@Observable`

In the view layer, `@Observable` objects are held with `@State` (for owned state) or passed as plain properties. There is no `@StateObject` or `@ObservedObject` needed.

```swift
// From MainView.swift (SimpleDictionary)
struct MainView: View {
    @State private var generator = DictionaryGenerator()
    
    var body: some View {
        // Only re-renders when generator.entry or generator.error changes
        if let entry = generator.entry {
            DefinitionCard(entry: entry)
        }
        if let error = generator.error {
            Text("Error: \(error.localizedDescription)")
        }
    }
}
```

```swift
// From LandmarkTripView.swift (WWDC2025 code-along)
struct LandmarkTripView: View {
    let landmark: Landmark
    @State private var itineraryGenerator: ItineraryGenerator?
    
    var body: some View {
        // ...
    }
    .task {
        let generator = ItineraryGenerator(landmark: landmark)
        self.itineraryGenerator = generator
        generator.prewarmModel()
    }
}
```

### Key migration from `ObservableObject`

| Old pattern (Combine) | New pattern (Observation) |
|---|---|
| `class VM: ObservableObject` | `@Observable class VM` |
| `@Published var items = []` | `var items = []` (automatic) |
| `@StateObject var vm = VM()` | `@State var vm = VM()` |
| `@ObservedObject var vm: VM` | `var vm: VM` (plain property) |
| `@EnvironmentObject var vm` | `@Environment(VM.self) var vm` |

### `@ObservationIgnored`

If a stored property should not trigger view updates, annotate it with `@ObservationIgnored`. This is useful for caches, internal buffers, or any data the UI does not display.

```swift
@Observable class ViewModel {
    var visibleItems: [Item] = []              // Triggers re-render
    @ObservationIgnored var internalCache: [String: Data] = [:]  // Does not
}
```

### Using `@Observable` outside SwiftUI

The `withObservationTracking` function lets you observe property changes outside of SwiftUI. The `onChange` closure fires once before the new value is set, and you must re-register to observe again.

```swift
func observeChanges(on model: SomeModel) {
    withObservationTracking {
        _ = model.someProperty  // Access triggers tracking
    } onChange: {
        print("someProperty is about to change")
        // Re-register if continuous observation is needed
        Task { @MainActor in observeChanges(on: model) }
    }
}
```


## Codable and JSON decoding

`Codable` (a typealias for `Encodable & Decodable`) is Foundation's primary mechanism for converting between Swift types and serialized formats like JSON and property lists. The compiler auto-synthesizes conformance when all stored properties are themselves `Codable`.

### How it works in your projects

The WWDC2025 code-along loads landmark data from a bundled JSON file:

```swift
// From ModelData.swift
static func parseLandmarks(fileName: String) -> [Landmark] {
    guard let file = Bundle.main.url(forResource: fileName, withExtension: nil) else {
        fatalError("Couldn't find \(fileName) in main bundle.")
    }
    do {
        let data: Data = try Data(contentsOf: file)
        let decoder = JSONDecoder()
        return try decoder.decode([Landmark].self, from: data)
    } catch {
        fatalError("Couldn't parse \(fileName):\n\(error)")
    }
}
```

The `Landmark` model conforms to `Codable` with properties matching the JSON keys exactly:

```swift
// From Landmark.swift
struct Landmark: Hashable, Codable, Identifiable {
    var id: Int
    var name: String
    var continent: String
    var description: String
    var shortDescription: String
    var latitude: Double
    var longitude: Double
    var span: Double
    var placeID: String?
}
```

### Custom key mapping with `CodingKeys`

When JSON keys don't match your Swift property names, define a `CodingKeys` enum:

```swift
struct Product: Codable {
    let productId: Int
    let productName: String
    
    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
        case productName = "product_name"
    }
}
```

Alternatively, set a key decoding strategy on the decoder to handle snake_case globally:

```swift
let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
```

### Date decoding strategies

Dates are a common pain point in JSON. `JSONDecoder` provides several strategies:

```swift
decoder.dateDecodingStrategy = .iso8601                          // "2025-06-10T14:30:00Z"
decoder.dateDecodingStrategy = .secondsSince1970                 // 1749564600
decoder.dateDecodingStrategy = .formatted(customDateFormatter)   // Custom DateFormatter
```

### Encoding output

`JSONEncoder` mirrors the decoder with matching strategies:

```swift
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
encoder.keyEncodingStrategy = .convertToSnakeCase
encoder.dateEncodingStrategy = .iso8601

let data = try encoder.encode(myModel)
let jsonString = String(data: data, encoding: .utf8)
```

### Handling nested and polymorphic JSON

For complex JSON structures where you need to flatten nested objects or decode type-discriminated unions, implement `init(from:)` and `encode(to:)` manually using `container(keyedBy:)`, `nestedContainer(keyedBy:)`, and `singleValueContainer()`.


## Bundle: loading app resources

`Bundle.main` provides access to files included in your app target at build time. The WWDC2025 project loads `landmarkData.json` from the bundle:

```swift
guard let file = Bundle.main.url(forResource: "landmarkData", withExtension: "json") else {
    fatalError("Couldn't find landmarkData.json in main bundle.")
}
let data = try Data(contentsOf: file)
```

For Swift Package Manager modules, use `Bundle.module` instead of `Bundle.main` to access resources declared in `Package.swift`.

`Bundle` also provides Info.plist values:

```swift
let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
let displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
```


## Structured concurrency: `async/await` and `Task`

Both projects use Swift's structured concurrency model extensively. The key principle is that async work is launched within a `Task`, and SwiftUI provides the `.task` modifier to tie task lifetime to view lifetime (automatic cancellation when the view disappears).

### Launching async work from SwiftUI

```swift
// From MainView.swift (SimpleDictionary)
Button {
    Task {
        isSearching = true
        await generator.defineWord(searchWord)
        isSearching = false
    }
} label: {
    if isSearching { ProgressView() }
    else { Text("Define") }
}
```

```swift
// From LandmarkTripView.swift (WWDC2025 code-along)
.task {
    let generator = ItineraryGenerator(landmark: landmark)
    self.itineraryGenerator = generator
    generator.prewarmModel()
}
```

The `.task` modifier is preferred over `Task { }` inside `.onAppear` because `.task` automatically cancels when the view disappears. Use `Task { }` inside button actions or event handlers where you want the work to complete regardless of view lifecycle.

### `@MainActor` isolation

Both generator classes use `@MainActor` to guarantee all mutable state is accessed on the main thread. Inside an `@MainActor` class, all methods are implicitly main-actor-isolated. When you call an async method from a view (which is already on the main actor), updates to `@Observable` properties happen seamlessly.

### `for try await` streaming

Both projects consume async sequences via `for try await`:

```swift
// From DictionaryGenerator.swift
let stream = session.streamResponse(
    to: prompt,
    generating: DictionaryEntry.self,
    includeSchemaInPrompt: false
)
for try await partialResponse in stream {
    self.entry = partialResponse.content
}
```

Each iteration yields a progressively more complete `PartiallyGenerated` version of the output. Because the class is `@MainActor`, assigning to `self.entry` triggers a SwiftUI view update on each iteration, creating a live streaming effect in the UI.


## FoundationModels framework (iOS 26+)

The `FoundationModels` framework, introduced at WWDC 2025, provides access to Apple's on-device language model (Apple Intelligence). It runs entirely on-device with no network calls, no API keys, and no data leaving the device.

### Core concepts

The framework has four pillars: `LanguageModelSession` manages conversation state, `@Generable` defines structured output schemas, `@Guide` constrains generation, and `Tool` lets the model call back into your code.

### Checking model availability

Before using any FoundationModels API, check if Apple Intelligence is available:

```swift
// From LandmarkDetailView.swift (WWDC2025 code-along)
import FoundationModels

private let model = SystemLanguageModel.default

var body: some View {
    switch model.availability {
    case .available:
        LandmarkTripView(landmark: landmark)
    case .unavailable:
        MessageView(message: "Apple Intelligence has not been turned on.")
    @unknown default:
        MessageView(message: "Trip Planner is unavailable.")
    }
}
```

### `@Generable` for structured output

The `@Generable` macro tells the framework your struct or enum can be generated as structured output. The compiler synthesizes a companion `PartiallyGenerated` type where every property is optional, enabling progressive streaming of results.

```swift
// From DictionaryEntry.swift (SimpleDictionary)
import FoundationModels

@Generable
struct DictionaryEntry: Equatable {
    let word: String
    let definition: String
    let partOfSpeech: PartOfSpeech
    let pronunciation: String
    let emojis: [String]
    let examples: [Example]
}

@Generable
struct Example: Equatable {
    let sentence: String
}

@Generable
enum PartOfSpeech: String, CaseIterable {
    case noun, verb, adjective, adverb, pronoun, preposition, conjunction, interjection
}
```

```swift
// From Itinerary.swift (WWDC2025 code-along)
@Generable
struct Itinerary: Equatable {
    let title: String
    let destinationName: String
    let description: String
    let rationale: String
    let days: [DayPlan]
}

@Generable
struct DayPlan: Equatable {
    let title: String
    let subtitle: String
    let destination: String
    let activities: [Activity]
}
```

Nested `@Generable` types compose. The framework generates the entire object graph, and each level gets its own `.PartiallyGenerated` variant.

### `@Guide` for constraining generation

`@Guide` annotations control what the model produces. They accept a description string, count constraints, and value constraints:

```swift
@Guide(description: "A detailed, beginner-friendly definition.")
let definition: String

@Guide(description: "Exactly 3 emojis that visually represent this word.")
@Guide(.count(3))
let emojis: [String]

@Guide(.anyOf(ModelData.landmarkNames))   // Constrain to known values
let destinationName: String
```

### `Instructions` and `Prompt`

`Instructions` set the system-level persona. `Prompt` is the per-turn user message. Both use a result-builder syntax:

```swift
// From DictionaryGenerator.swift
let instructions = Instructions {
    "You are a friendly dictionary for learners of all ages."
    "Avoid using complex words in your definitions."
}

let prompt = Prompt {
    "Define the word '\(word)' in simple, beginner-friendly language."
    DictionaryEntry.exampleHappy   // Provide an example of the desired output
}
```

Including a static example instance in the prompt (like `DictionaryEntry.exampleHappy` or `Itinerary.exampleTripToJapan`) is a powerful technique. It shows the model the exact structure and tone you want without relying on schema-only prompting.

### `LanguageModelSession` lifecycle

A session maintains conversation history across multiple turns. Create it once with tools and instructions, then call `respond` or `streamResponse` per turn.

```swift
// Single complete response
let response = try await session.respond(
    to: prompt,
    generating: Itinerary.self,
    options: GenerationOptions(sampling: .greedy)
)

// Streaming partial responses
let stream = session.streamResponse(
    to: prompt,
    generating: DictionaryEntry.self,
    includeSchemaInPrompt: false
)
for try await partial in stream {
    self.entry = partial.content  // Progressively more complete
}
```

`includeSchemaInPrompt: false` is used when you've already provided an example instance in the prompt, avoiding redundancy.

### Prewarming the model

Loading the on-device model takes time. Both projects call `prewarm()` early so the model is ready when the user requests generation:

```swift
// From DictionaryGenerator.swift
func prewarmModel() {
    session.prewarm()
}

// Called in onAppear
.onAppear {
    generator.prewarmModel()
}

// From LandmarkTripView.swift (WWDC2025)
.task {
    let generator = ItineraryGenerator(landmark: landmark)
    self.itineraryGenerator = generator
    generator.prewarmModel()
}
```

### Tool use

The `Tool` protocol lets the model call back into your code to fetch data. The model decides when to call the tool based on the prompt context.

```swift
// From FindPointsOfInterestTool.swift (WWDC2025 code-along)
@Observable
final class FindPointsOfInterestTool: Tool {
    let name = "findPointsOfInterest"
    let description = "Finds points of interest for a landmark."
    let landmark: Landmark
    
    @Generable
    struct Arguments {
        @Guide(description: "This is the type of business to look up for.")
        let pointOfInterest: Category
    }
    
    func call(arguments: Arguments) async throws -> String {
        let results = await getSuggestions(
            category: arguments.pointOfInterest,
            landmark: landmark.name
        )
        return "There are these \(arguments.pointOfInterest) in \(landmark.name): \(results.joined(separator: ", "))"
    }
}

@Generable
enum Category: String, CaseIterable {
    case hotel, restaurant
}
```

Tools are passed to the session at creation:

```swift
let pointOfInterestTool = FindPointsOfInterestTool(landmark: landmark)
let session = LanguageModelSession(
    tools: [pointOfInterestTool],
    instructions: instructions
)
```

The `Arguments` struct must also be `@Generable` so the model can produce the function call arguments.

### Consuming `PartiallyGenerated` in views

When streaming, every property on a `PartiallyGenerated` type is optional. Views must unwrap each field:

```swift
// From ItineraryView.swift (WWDC2025 code-along)
let itinerary: Itinerary.PartiallyGenerated

var body: some View {
    VStack(alignment: .leading) {
        if let title = itinerary.title {
            Text(title).contentTransition(.opacity)
        }
        if let description = itinerary.description {
            Text(description).contentTransition(.opacity)
        }
        if let days = itinerary.days {
            ForEach(days, id: \.title) { plan in
                DayView(landmark: landmark, plan: plan)
            }
        }
    }
    .animation(.easeOut, value: itinerary)
}
```

The `.contentTransition(.opacity)` modifier creates a smooth fade-in effect as each field appears during streaming. The `.animation(.easeOut, value: itinerary)` drives the animation when the `Equatable` itinerary changes.

For arrays, the `PartiallyGenerated` type is `[Activity].PartiallyGenerated` (not `[Activity.PartiallyGenerated]`):

```swift
let activities: [Activity].PartiallyGenerated
```


## Formatting with FormatStyle (iOS 15+)

The `FormatStyle` API replaces legacy `Formatter` subclasses with chainable, declarative formatting called directly on values.

### Date formatting

```swift
Date.now.formatted(date: .abbreviated, time: .standard)     // "Feb 22, 2026, 2:15:36 PM"
Date.now.formatted(.dateTime.year().month().day())           // "Feb 22, 2026"
Date.now.formatted(.relative(presentation: .named))          // "today"
```

### Number and currency formatting

```swift
1_234_567.formatted(.number.grouping(.automatic))       // "1,234,567"
0.856.formatted(.percent)                                // "85.6%"
42.99.formatted(.currency(code: "USD"))                  // "$42.99"
42.99.formatted(.currency(code: "VND"))                  // "₫42.99" (locale-dependent)
```

### List formatting

```swift
["Swift", "Kotlin", "Rust"].formatted(.list(type: .and, width: .standard))
// "Swift, Kotlin, and Rust"
```


## UserDefaults for lightweight persistence

`UserDefaults` stores small key-value preferences. It should not be used for large data or complex objects. Use SwiftData or file storage instead.

```swift
// Writing
UserDefaults.standard.set("dark", forKey: "preferredTheme")
UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

// Reading
let theme = UserDefaults.standard.string(forKey: "preferredTheme") ?? "system"
let onboarded = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

// Registering defaults (set fallback values, never overwrites existing)
UserDefaults.standard.register(defaults: [
    "preferredTheme": "system",
    "hasCompletedOnboarding": false
])
```

In SwiftUI, `@AppStorage` provides a reactive property wrapper over `UserDefaults`:

```swift
struct SettingsView: View {
    @AppStorage("preferredTheme") var theme = "system"
    
    var body: some View {
        Picker("Theme", selection: $theme) {
            Text("System").tag("system")
            Text("Light").tag("light")
            Text("Dark").tag("dark")
        }
    }
}
```

For sharing defaults across app extensions or widgets, use `UserDefaults(suiteName: "group.com.yourapp.shared")`.


## FileManager: file system access

`FileManager.default` handles creating, reading, moving, and deleting files. iOS apps are sandboxed, and each app has specific directories:

```swift
// Documents directory: user data, backed up to iCloud
let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

// Application Support: app-generated data, backed up
let appSupport = try FileManager.default.url(
    for: .applicationSupportDirectory, in: .userDomainMask,
    appropriateFor: nil, create: true
)

// Caches: purgeable by the system when storage is low
let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!

// Temp: for transient files
let tmp = FileManager.default.temporaryDirectory
```

Common operations:

```swift
let fm = FileManager.default
let fileURL = docs.appendingPathComponent("data.json")

// Write
try data.write(to: fileURL, options: [.atomic])

// Read
let contents = try Data(contentsOf: fileURL)

// Check existence
fm.fileExists(atPath: fileURL.path)

// Delete
try fm.removeItem(at: fileURL)

// Create directory
try fm.createDirectory(at: docs.appendingPathComponent("exports"), 
                       withIntermediateDirectories: true)
```


## URLSession: networking

`URLSession` handles all HTTP networking. The modern `async/await` APIs (iOS 15+) make network code straightforward:

```swift
// Simple GET
let (data, response) = try await URLSession.shared.data(from: url)
guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
    throw URLError(.badServerResponse)
}
let result = try JSONDecoder().decode(MyModel.self, from: data)

// POST with JSON body
var request = URLRequest(url: url)
request.httpMethod = "POST"
request.setValue("application/json", forHTTPHeaderField: "Content-Type")
request.httpBody = try JSONEncoder().encode(payload)
let (responseData, _) = try await URLSession.shared.data(for: request)

// Streaming bytes
let (bytes, _) = try await URLSession.shared.bytes(from: url)
for try await line in bytes.lines {
    processLine(line)
}
```

### Session configurations

```swift
// Ephemeral (no disk caching, like private browsing)
let config = URLSessionConfiguration.ephemeral
let session = URLSession(configuration: config)

// Background (continues after app suspension)
let bgConfig = URLSessionConfiguration.background(withIdentifier: "com.app.download")
bgConfig.isDiscretionary = true
bgConfig.sessionSendsLaunchEvents = true
```


## Error handling patterns

Foundation provides several error protocols for different levels of user-facing detail.

### `LocalizedError` for user-facing messages

```swift
enum AppError: LocalizedError {
    case networkFailure
    case invalidInput(detail: String)
    
    var errorDescription: String? {
        switch self {
        case .networkFailure:
            return "Unable to connect to the server."
        case .invalidInput(let detail):
            return "Invalid input: \(detail)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkFailure:
            return "Check your internet connection and try again."
        case .invalidInput:
            return "Please correct the input and try again."
        }
    }
}
```

Both projects catch errors and expose them to the view layer through an optional `error` property:

```swift
// Pattern used in both DictionaryGenerator and ItineraryGenerator
do {
    // ... generation logic
} catch {
    self.error = error
}

// In the view
if let error = generator.error {
    Text("Error: \(error.localizedDescription)")
        .foregroundStyle(.red)
}
```

### Common Foundation error types

`URLError` wraps networking failures with specific codes like `.notConnectedToInternet`, `.timedOut`, and `.cancelled`. `DecodingError` surfaces JSON parsing failures with cases like `.keyNotFound`, `.typeMismatch`, and `.valueNotFound`. `CocoaError` covers file system issues like `.fileNoSuchFile` and `.fileWriteOutOfSpace`.


## NotificationCenter

`NotificationCenter` broadcasts messages across your app. The modern async API (iOS 15+) integrates with structured concurrency:

```swift
// Posting
NotificationCenter.default.post(name: .dataDidUpdate, object: nil, userInfo: ["count": 42])

// Observing with async sequence (automatically cleaned up when Task is cancelled)
for await notification in NotificationCenter.default.notifications(named: .dataDidUpdate) {
    if let count = notification.userInfo?["count"] as? Int {
        print("Updated with \(count) items")
    }
}

// Common system notifications
NotificationCenter.default.addObserver(
    forName: UIApplication.didBecomeActiveNotification,
    object: nil, queue: .main
) { _ in
    // App came to foreground
}
```


## ProcessInfo: device environment

`ProcessInfo` provides runtime information about the device and process:

```swift
let info = ProcessInfo.processInfo
info.operatingSystemVersion            // (major: 19, minor: 0, patch: 0)
info.isLowPowerModeEnabled             // Low Power Mode active?
info.thermalState                      // .nominal, .fair, .serious, .critical
info.processorCount                    // Number of CPU cores
info.physicalMemory                    // Total RAM in bytes

// Check OS version
if ProcessInfo.processInfo.isOperatingSystemAtLeast(
    OperatingSystemVersion(majorVersion: 18, minorVersion: 0, patchVersion: 0)
) {
    // iOS 18+ code path
}
```

These are useful for adapting app behavior. For example, reduce animation complexity when `thermalState` is `.serious` or `.critical`, or disable background tasks when `isLowPowerModeEnabled` is true.


## Quick reference: what to use when

| Task | Foundation API |
|---|---|
| State management for SwiftUI | `@Observable` macro |
| Parse JSON from network or file | `JSONDecoder` + `Codable` |
| Load bundled app resources | `Bundle.main.url(forResource:withExtension:)` |
| Store small user preferences | `UserDefaults` / `@AppStorage` |
| Read and write files | `FileManager` + `Data(contentsOf:)` / `data.write(to:)` |
| Make HTTP requests | `URLSession` with `async/await` |
| Format dates, numbers, currency | `.formatted()` with `FormatStyle` |
| Broadcast events across the app | `NotificationCenter` |
| Generate structured AI output on-device | `FoundationModels` + `@Generable` |
| Stream AI generation with live UI updates | `session.streamResponse` + `PartiallyGenerated` |
| Give the AI model callable functions | `Tool` protocol + `@Generable Arguments` |
| Type-safe filtering for SwiftData | `#Predicate` macro |
| Type-safe sorting | `SortDescriptor` with Swift key paths |
| Rich styled text | `AttributedString` (value type) |
| Physical unit conversion | `Measurement<UnitType>` |
| Check device state / thermal pressure | `ProcessInfo.processInfo` |


## Key WWDC sessions for further study

These sessions provide the deepest official coverage of the Foundation APIs used in your projects:

| Session | Year | Topic |
|---|---|---|
| Get started with Foundation Models | WWDC 2025 | `@Generable`, `LanguageModelSession`, streaming, tools |
| Use async/await with URLSession | WWDC 2021 | Modern networking with `async/await` |
| Discover Observation in SwiftUI | WWDC 2023 | `@Observable` macro, migration from Combine |
| What's new in Foundation | WWDC 2021 | `FormatStyle`, `AttributedString`, `Codable` improvements |
| What's new in Foundation | WWDC 2017 | `Codable` introduction, `KeyPath`, `KVO` in Swift |
| Discover String Catalogs | WWDC 2023 | Modern localization with `String(localized:)` |
| What's new in SwiftData | WWDC 2024 | `#Expression` macro, predicate enhancements |
