# Apple's Foundation Framework: the complete Swift technical reference

**Foundation is the bedrock framework underlying every Apple platform app**, providing essential data types, networking, file I/O, concurrency primitives, formatting, and system services that all higher-level frameworks depend on. Whether you import SwiftUI, UIKit, or AppKit, Foundation is implicitly included — its types like `String`, `Date`, `URL`, `Data`, and `JSONDecoder` are the lingua franca of Apple development. This reference covers Foundation comprehensively across 15 major topic areas, with Swift code examples and attention to the latest APIs in iOS 17/18 and Swift 6. The framework has undergone a **major rewrite in pure Swift** since 2023, delivering up to 18× performance gains in key areas while becoming cross-platform for Linux and Windows.

---

## How Foundation fits into Apple's SDK stack

Foundation sits between the UI layer and the operating system kernel in a layered architecture:

```
SwiftUI / UIKit / AppKit       (UI frameworks)
         ↓
     Foundation                (base layer: types, networking, I/O, formatting)
         ↓
   Core Foundation             (C-level primitives, toll-free bridging)
         ↓
       Darwin                  (POSIX, system calls, kernel)
```

Every `import UIKit` or `import SwiftUI` implicitly imports Foundation. SwiftUI consumes Foundation types directly — `Text` accepts `AttributedString`, date formatting uses `FormatStyle`, and `@Observable` (the Observation framework) integrates with SwiftUI's view update cycle. UIKit uses `IndexPath` for table/collection views, `NSAttributedString` for rich text, and `URL` for resources.

Since December 2022, Apple has been **rewriting Foundation in pure Swift** under the open-source `swift-foundation` package. This modular rewrite ships as five packages: **FoundationEssentials** (core types with no system dependencies), **FoundationInternationalization** (locale-dependent APIs), **FoundationNetworking** (URLSession), **FoundationXML**, and **FoundationObjCCompatibility**. On Apple platforms, these are compiled into the system Foundation.framework. On Linux and Windows, they provide the same APIs via Swift Package Manager. A reimplementation of `Calendar` in Swift benchmarked at **1.5× to 18× faster** than the C version; the new `JSONDecoder` shows **200–500% improvement** in decode time.

```swift
import Foundation                       // All Apple platforms — imports everything
import FoundationEssentials             // Non-Apple platforms — core types only
import FoundationInternationalization   // + Locale, formatters
import FoundationNetworking             // + URLSession (separate on Linux)
```

---

## Core data types and collection bridging

### String, Data, URL, UUID, and Date

**String** bridges seamlessly with `NSString` when Foundation is imported. Swift strings are Unicode-correct by default, using extended grapheme clusters as their `Character` unit. The emoji `👨‍👩‍👧‍👧` counts as **1 character** but 7 Unicode scalars and 25 UTF-8 bytes. `Substring` shares storage with its parent string for performance — convert to `String` explicitly for long-term storage.

```swift
let str = "Hello, Swift Foundation!"
str.components(separatedBy: " ")                    // NSString method via bridging
"Éclair".localizedStandardContains("E")             // true (locale-aware)
let price = 29.99
"Price: \(price, format: .currency(code: "USD"))"   // iOS 15+ interpolation
```

**Data** is a value type representing a byte buffer, bridging with `NSData`. It supports base64 encoding, memory-mapped file reading for large files (`.mappedIfSafe`), and atomic writes.

```swift
let data = "Hello".data(using: .utf8)!
let base64 = data.base64EncodedString()              // "SGVsbG8="
try data.write(to: fileURL, options: [.atomic])       // Safe atomic write
let large = try Data(contentsOf: url, options: [.mappedIfSafe])
```

**URL** distinguishes between file URLs and network URLs. The modern `URL(filePath:)` initializer (iOS 16+) replaces `URL(fileURLWithPath:)`. For network URLs, always use `URLComponents` for safe construction with automatic percent-encoding.

```swift
let fileURL = URL(filePath: "/Users/dev/document.txt")     // iOS 16+
var components = URLComponents()
components.scheme = "https"
components.host = "api.example.com"
components.path = "/v2/search"
components.queryItems = [URLQueryItem(name: "q", value: "swift foundation")]
let url = components.url!  // Automatically percent-encoded
```

**UUID** generates RFC 4122 v4 random identifiers. It conforms to `Identifiable`, `Codable`, `Hashable`, and `Comparable` — ideal for SwiftUI list identifiers and database primary keys.

**Date** represents a single point in time independent of calendar or timezone. Use `Date.now` (iOS 15+) for clarity, `Calendar` for date arithmetic, and the modern `.formatted()` API for display.

```swift
let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: .now)!
Calendar.current.isDateInWeekend(.now)                      // Bool
Date.now.formatted(.dateTime.year().month().day())           // "Feb 21, 2026"
```

### Collection bridging with NS* types

Swift's `Array`, `Dictionary`, and `Set` bridge to `NSArray`, `NSDictionary`, and `NSSet` via compiler-mediated conversion (not toll-free bridging). The cast uses `as` and may involve a copy. True toll-free bridging exists only between Core Foundation types and their Objective-C counterparts (e.g., `CFString` ↔ `NSString`). `NSNull` represents null in Objective-C collections; prefer Swift optionals instead. `NSRange` uses UTF-16 offsets — always use `NSRange(_:in:)` and `Range(_:in:)` initializers to convert safely.

---

## Networking with URLSession

### Session types and configuration

**URLSession** coordinates network transfers through four session flavors. `URLSession.shared` is a singleton for simple one-off requests. **Default sessions** use disk-persisted caches. **Ephemeral sessions** store nothing to disk (private browsing). **Background sessions** continue transfers while the app is suspended — handled by the system's `nsurlsessiond` daemon, requiring a delegate (no completion handlers).

```swift
let config = URLSessionConfiguration.background(withIdentifier: "com.myapp.bg")
config.isDiscretionary = true                  // Defer to WiFi/charging
config.sessionSendsLaunchEvents = true         // Wake app on completion
let bgSession = URLSession(configuration: config, delegate: myDelegate, delegateQueue: nil)
```

Key configuration properties include `timeoutIntervalForRequest` (default 60s), `waitsForConnectivity` (wait rather than fail immediately), `allowsExpensiveNetworkAccess` / `allowsConstrainedNetworkAccess` (iOS 13+), and `protocolClasses` for URLProtocol interception.

### Async/await networking (iOS 15+)

The modern async/await APIs from **WWDC 2021 (Session 10095)** make networking code linear with native error handling and automatic `Task` cancellation integration:

```swift
// GET request
let (data, response) = try await URLSession.shared.data(from: url)
guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
    throw URLError(.badServerResponse)
}
let user = try JSONDecoder().decode(User.self, from: data)

// POST request
var request = URLRequest(url: url)
request.httpMethod = "POST"
request.setValue("application/json", forHTTPHeaderField: "Content-Type")
request.httpBody = try JSONEncoder().encode(payload)
let (responseData, _) = try await URLSession.shared.data(for: request)

// Streaming with AsyncBytes
let (bytes, _) = try await URLSession.shared.bytes(from: streamURL)
for try await line in bytes.lines {
    let event = try JSONDecoder().decode(Event.self, from: Data(line.utf8))
}
```

**URLSessionWebSocketTask** (iOS 13+) provides native WebSocket support with text/binary messages, ping/pong, and close codes. **URLProtocol** enables request interception — invaluable for testing by injecting mock responses via a custom session configuration's `protocolClasses`.

**URLSessionTaskMetrics** provides detailed timing breakdowns (DNS lookup, TCP connect, TLS handshake, request/response durations) via the `urlSession(_:task:didFinishCollecting:)` delegate method.

---

## File system access and data persistence

### FileManager and the iOS sandbox

**FileManager.default** handles all file operations. iOS apps operate within a sandbox containing read-only bundle, Documents (user data, backed up), Library/Caches (purgeable), Library/Application Support (backed up), and tmp directories.

```swift
let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
let appSupport = try FileManager.default.url(
    for: .applicationSupportDirectory, in: .userDomainMask,
    appropriateFor: nil, create: true    // Creates directory if needed
)
```

Directory enumeration supports shallow (`contentsOfDirectory(at:)`) and deep recursive enumeration via `enumerator(at:includingPropertiesForKeys:options:)`. **FileHandle** provides lower-level read/write/seek operations and supports `AsyncBytes` for async line-by-line reading (iOS 15+). **Bundle.main** accesses app resources and Info.plist values; Swift packages use `Bundle.module`.

### Codable, JSON, and UserDefaults

**Codable** (`Encodable & Decodable`), introduced at WWDC 2017, is Foundation's primary serialization mechanism. The compiler auto-synthesizes conformance when all properties are Codable. Custom `CodingKeys` enums map property names to JSON keys, while `nestedContainer`, `unkeyedContainer`, and `singleValueContainer` handle complex JSON structures.

```swift
struct Product: Codable {
    let productId: Int
    let productName: String
    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
        case productName = "product_name"
    }
}

let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
decoder.dateDecodingStrategy = .iso8601
let product = try decoder.decode(Product.self, from: jsonData)
```

**UserDefaults** stores small preferences as property lists. It supports app group sharing via suite names and connects to SwiftUI through `@AppStorage`. Register default values with `register(defaults:)` to avoid nil checks. **NSKeyedArchiver** with `NSSecureCoding` handles legacy object graph persistence but is slower than Codable for most use cases.

---

## Concurrency primitives and Swift Concurrency integration

**OperationQueue** provides higher-level concurrency with dependency management, cancellation, and quality-of-service control. Operations declare dependencies (`addDependency`), and the queue respects execution order. `addBarrierBlock` acts as a synchronization point.

```swift
let queue = OperationQueue()
queue.maxConcurrentOperationCount = 3
let download = BlockOperation { /* download */ }
let parse = BlockOperation { /* parse */ }
parse.addDependency(download)    // parse waits for download
queue.addOperations([download, parse], waitUntilFinished: false)
```

**Timer** is tightly coupled with **RunLoop**. Timers scheduled via `scheduledTimer` use `.default` run loop mode and **pause during scrolling**. Add timers to `.common` mode to fire during UI interaction. Always set `tolerance` (Apple recommends ≥10% of interval) to save power.

**Integration with Swift Concurrency:** `@MainActor` replaces `DispatchQueue.main.async` for main-thread guarantees. `Task(priority:)` replaces `OperationQueue` for most new code. In Swift 6, `Thread.isMainThread` is unavailable in async contexts — use `@MainActor` instead. Foundation's concurrency primitives remain available but are considered legacy for new Swift code.

---

## NotificationCenter, KVO, and the Observation framework

### Three generations of observation

**NotificationCenter** delivers broadcast notifications synchronously on the posting thread. Selector-based observers auto-unregister on dealloc (iOS 9+); **block-based observers must be manually removed**. The modern async sequence API (iOS 15+) integrates cleanly with Swift Concurrency:

```swift
for await notification in NotificationCenter.default.notifications(named: .dataDidUpdate) {
    print("Update received: \(notification.userInfo ?? [:])")
    // Automatically cleaned up when Task is cancelled
}
```

**KVO** requires `NSObject` subclasses with `@objc dynamic` properties. The modern Swift API returns an `NSKeyValueObservation` token that auto-invalidates on dealloc:

```swift
observation = person.observe(\.name, options: [.old, .new]) { person, change in
    print("Name changed to \(change.newValue ?? "")")
}
```

**@Observable (iOS 17+)** from the Observation framework replaces both KVO and Combine's `ObservableObject`. It provides **property-level tracking** — only views reading changed properties re-render. No `@Published` annotations needed; all stored properties are automatically observable. Use `@ObservationIgnored` to opt out.

```swift
@Observable class ViewModel {
    var items: [Item] = []       // Automatically observable
    var isLoading = false        // Automatically observable
    @ObservationIgnored var cache: [String: Any] = [:]  // Not observed
}

struct ContentView: View {
    @State var vm = ViewModel()          // @State, not @StateObject
    var body: some View {
        List(vm.items) { item in Text(item.name) }  // Re-renders only when items changes
    }
}
```

The key migration path: `@StateObject` → `@State`, `@ObservedObject` → plain property or `@Bindable`, `@EnvironmentObject` → `@Environment`. Outside SwiftUI, `withObservationTracking` provides one-shot observation — the `onChange` closure fires **once before the new value is set** and must be re-registered recursively for continuous observation.

---

## Regular expressions and text processing

**NSRegularExpression** remains available for all OS versions, using ICU regex syntax with `NSRange`-based matching. **Swift Regex** (Swift 5.7+ / iOS 16+) provides three creation modes: runtime strings (`try Regex("\\d+")`), compile-time literals (`/pattern/`), and the **RegexBuilder DSL** for complex, readable patterns with typed captures:

```swift
import RegexBuilder
let pattern = Regex {
    "My name is "
    Capture { OneOrMore(.word) }
    " and I'm "
    TryCapture { OneOrMore(.digit) } transform: { Int($0) }
    " years old."
}
if let match = text.firstMatch(of: pattern) {
    print("Name: \(match.1), Age: \(match.2)")  // Typed: Substring, Int
}
```

**NSDataDetector** automatically identifies dates, URLs, phone numbers, and addresses in natural language text — a specialized `NSRegularExpression` subclass. **Scanner** parses structured text sequentially, maintaining an internal position cursor.

---

## Formatting: from NumberFormatter to FormatStyle

### Legacy formatters (pre-iOS 15)

`NumberFormatter` handles currency (`.currency`), decimal, percent, and spellOut styles. `DateFormatter` provides localized formatting via `dateStyle`/`timeStyle` or custom `dateFormat` strings. `ISO8601DateFormatter` handles ISO 8601 dates. Other specialized formatters include `ByteCountFormatter` (file sizes), `DateComponentsFormatter` (durations), `PersonNameComponentsFormatter` (locale-aware name formatting), `ListFormatter` (joining lists with locale-appropriate conjunctions), and `RelativeDateTimeFormatter` ("2 hours ago").

### FormatStyle API (iOS 15+) — the modern approach

**FormatStyle** replaces `Formatter` subclasses with declarative, chainable formatting via `.formatted()` directly on values. No need to create or cache formatter instances.

```swift
Date.now.formatted(date: .abbreviated, time: .standard)     // "Feb 21, 2026, 2:15:36 PM"
Date.now.formatted(.dateTime.year().month().day())           // "Feb 21, 2026"
1_200_450.formatted(.number.notation(.scientific))           // "1.20045E6"
0.375.formatted(.percent)                                    // "37.5%"
1450.28.formatted(.currency(code: "EUR"))                    // "€1,450.28"
["red", "green", "blue"].formatted(.list(type: .or))         // "red, green, or blue"
Date(timeIntervalSinceNow: -86400).formatted(.relative(presentation: .named))  // "yesterday"
```

`FormatStyle` supports bidirectional parsing via `ParseStrategy` — convert strings back to typed values with `try Date("May 26, 2022", strategy: format)`. The `.attributed` modifier returns `AttributedString` with semantic attributes for each field, enabling per-component styling.

---

## AttributedString and Markdown parsing

**AttributedString** (iOS 15+) is a Swift-native **value type** replacing `NSAttributedString`. It provides type-safe attribute access via dot syntax, Codable conformance, and built-in Markdown parsing.

```swift
var str = try AttributedString(markdown: "**Bold** and *italic* with [link](https://apple.com)")
str.font = .body.bold()
str.foregroundColor = .red

// Attribute scopes: .foundation, .swiftUI, .uiKit, .appKit
// Runs view for iterating styled segments
for run in str.runs {
    print(run.range, run.attributes)
}

// Bidirectional conversion
let nsVersion = NSAttributedString(str)
let swiftVersion = AttributedString(nsVersion)
```

**AttributeContainer** bundles attributes for bulk application. **AttributeScopes** organize attributes by framework — SwiftUI, UIKit, and AppKit scopes each include Foundation and Accessibility attributes. Custom attribute scopes enable app-specific Markdown extensions.

---

## Type-safe predicates and sorting

**NSPredicate** uses string-based format queries (`"age > %d AND name BEGINSWITH[c] %@"`) that are error-prone and untyped. **#Predicate** (iOS 17+) is a freestanding expression macro providing compile-time type safety for SwiftData and in-memory filtering:

```swift
let upcoming = #Predicate<Trip> { trip in
    trip.startDate > Date.now && trip.destination.contains("Paris")
}
let results = try modelContext.fetch(FetchDescriptor<Trip>(predicate: upcoming))
let filtered = try trips.filter(upcoming)  // Also works on arrays
```

`#Predicate` converts Swift closures into `PredicateExpressions` at compile time. SwiftData translates these to SQL for database queries. The `Predicate` struct conforms to both **Sendable and Codable**. Limitations include no support for `map()`, `hasPrefix()`/`hasSuffix()`, or dynamic composition (use `&&`/`||` inline instead). **#Expression** (iOS 18+) extends this with non-Boolean return types for richer query logic.

**SortDescriptor** (iOS 15+) provides type-safe sorting via Swift key paths, replacing `NSSortDescriptor`'s string-based keys:

```swift
let sorted = countries.sorted(using: [
    SortDescriptor(\.population, order: .reverse),
    SortDescriptor(\.name, comparator: .localizedStandard)
])
```

---

## Units, measurements, and conversion

The **Measurement** framework (iOS 10+) provides type-safe physical quantities. `Measurement<UnitType>` pairs a `Double` value with a `Unit`. Over **22 Dimension subclasses** cover length, mass, temperature, speed, duration, volume, energy, pressure, and more. Arithmetic and comparison work across different units of the same dimension:

```swift
let run1 = Measurement(value: 5, unit: UnitLength.kilometers)
let run2 = Measurement(value: 3, unit: UnitLength.miles)
let total = run1 + run2                    // Result in meters (~9828 m)
run1 > Measurement(value: 3000, unit: .meters)  // true

let temp = Measurement(value: 72, unit: UnitTemperature.fahrenheit)
temp.converted(to: .celsius)               // ~22.2°C
temp.formatted()                           // Locale-dependent formatting
```

`MeasurementFormatter` (legacy) and `Measurement.FormatStyle` (iOS 15+) format measurements with locale awareness, automatically converting to the user's preferred unit system when `unitOptions` includes `.naturalScale`.

---

## ProcessInfo: environment and device state

**ProcessInfo** provides runtime information about the process and device state. It exposes the OS version, hardware specs, environment variables, and two critical energy-related properties:

```swift
let info = ProcessInfo.processInfo
info.operatingSystemVersion            // e.g., (18, 0, 0)
info.physicalMemory                    // UInt64 bytes
info.processorCount                    // CPU cores
info.environment["API_KEY"]            // Environment variables
info.isLowPowerModeEnabled             // Low Power Mode active?
info.thermalState                      // .nominal, .fair, .serious, .critical
```

Monitor thermal state changes via `ProcessInfo.thermalStateDidChangeNotification` and Low Power Mode via `.NSProcessInfoPowerStateDidChange`. At `.serious` thermal state, reduce CPU/GPU/IO work. At `.critical`, the device is overheating and UI stuttering is likely — take immediate action.

---

## Error handling: from NSError to LocalizedError

Foundation bridges Swift errors to `NSError` automatically. The **LocalizedError** protocol provides user-facing error messages with `errorDescription`, `failureReason`, and `recoverySuggestion`. **CustomNSError** controls the bridged `NSError` domain and code:

```swift
enum NetworkError: LocalizedError {
    case noConnection
    case serverError(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .noConnection: return "No internet connection available."
        case .serverError(let code): return "Server returned error \(code)."
        }
    }
    var recoverySuggestion: String? {
        switch self {
        case .noConnection: return "Check Wi-Fi or cellular and try again."
        case .serverError: return "Wait and retry, or contact support."
        }
    }
}
```

**URLError** codes cover common networking failures: `.notConnectedToInternet` (-1009), `.timedOut` (-1001), `.cancelled` (-999), `.secureConnectionFailed` (-1200). **DecodingError** provides four cases with detailed context: `.keyNotFound`, `.typeMismatch`, `.valueNotFound`, `.dataCorrupted`. **CocoaError** covers file system errors like `.fileNoSuchFile`, `.fileWriteOutOfSpace`. Pattern-match these in catch blocks for precise error handling.

---

## What changed in iOS 17, iOS 18, and Swift 6

**iOS 17 (Swift 5.9)** brought three transformative additions. The **@Observable macro** replaces Combine's `ObservableObject` with granular property-level tracking and simpler SwiftUI integration. The **#Predicate macro** provides type-safe query predicates for SwiftData. And the **Swift Foundation rewrite** began shipping on Apple platforms, delivering major performance improvements to `JSONDecoder`, `Calendar`, and core types.

**iOS 18 (Swift 6.0)** added the **#Expression macro** for non-Boolean predicate expressions, **Calendar.RecurrenceRule** for recurring event patterns, and additional `FormatStyle` enhancements. Swift 6 enforces **data-race safety at compile time** — Foundation's value types (`Date`, `URL`, `Data`, `UUID`, etc.) are inherently `Sendable` as structs, and `Predicate` explicitly conforms. The new `Synchronization` library provides `Mutex` and `Atomic` for thread-safe mutable state.

The Swift Foundation package is now the **default Foundation implementation** for Linux and Windows in Swift 6, unifying behavior across all platforms. Legacy APIs remain available on Darwin via `FoundationObjCCompatibility`, but the migration direction is clear:

| Legacy API | Modern Replacement |
|---|---|
| `ObservableObject` + `@Published` | `@Observable` macro |
| `NSPredicate` (string-based) | `#Predicate` macro |
| `Formatter` subclasses | `FormatStyle` protocol |
| `NSAttributedString` | `AttributedString` (value type) |
| `NSCoding` / `NSKeyedArchiver` | `Codable` |
| `OperationQueue` / GCD | Swift Structured Concurrency |
| `NSLocalizedString` | `String(localized:)` + String Catalogs |

---

## Conclusion

Foundation is not merely a utility library — it is the **architectural substrate** of Apple platform development, mediating between raw system calls and the expressive APIs developers use daily. The Swift rewrite represents the most significant evolution in Foundation's history, delivering cross-platform consistency, dramatic performance gains, and modern Swift idioms while maintaining backward compatibility. Three developments deserve particular attention: **@Observable** eliminates the SwiftUI observation complexity that plagued Combine-era code, **#Predicate** brings compile-time safety to queries that were previously string-based guesswork, and **FormatStyle** makes locale-correct formatting trivially easy. Developers targeting iOS 17+ should adopt these APIs aggressively — they are not incremental improvements but fundamental simplifications that reduce bugs and boilerplate. The Foundation framework's trajectory is clear: pure Swift, value types, type safety, and seamless concurrency integration.