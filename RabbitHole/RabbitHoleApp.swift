import SwiftUI
import SwiftData

@main
struct RabbitHoleApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Topic.self, ContentItem.self, UserProgress.self])
        }
    }
}
