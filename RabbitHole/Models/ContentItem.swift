import Foundation
import SwiftData

@Model
final class ContentItem {

    // MARK: - Properties

    var type: String
    var level: Int
    var title: String
    var subtitle: String?
    var body: String?
    var estimatedMinutes: Int?
    var isCompleted: Bool
    var sortOrder: Int
    var topic: Topic?

    // MARK: - Init

    init(
        type: String,
        level: Int,
        title: String,
        subtitle: String? = nil,
        body: String? = nil,
        estimatedMinutes: Int? = nil,
        isCompleted: Bool = false,
        sortOrder: Int = 0
    ) {
        self.type = type
        self.level = level
        self.title = title
        self.subtitle = subtitle
        self.body = body
        self.estimatedMinutes = estimatedMinutes
        self.isCompleted = isCompleted
        self.sortOrder = sortOrder
    }
}
