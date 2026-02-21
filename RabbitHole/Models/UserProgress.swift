import Foundation
import SwiftData

@Model
final class UserProgress {

    // MARK: - Properties

    var currentLevel: Int
    var completedItems: Int
    var levelUnlockedAt: Date?
    var topic: Topic?

    // MARK: - Init

    init(
        currentLevel: Int = 1,
        completedItems: Int = 0,
        levelUnlockedAt: Date? = nil
    ) {
        self.currentLevel = currentLevel
        self.completedItems = completedItems
        self.levelUnlockedAt = levelUnlockedAt
    }
}
