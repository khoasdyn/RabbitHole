import Foundation
import SwiftData

@Model
final class Topic {

    // MARK: - Properties

    var question: String
    var subjectArea: String
    var accentColorName: String
    var iconName: String
    var isActive: Bool
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \ContentItem.topic)
    var contentItems: [ContentItem]

    @Relationship(deleteRule: .cascade, inverse: \UserProgress.topic)
    var progress: UserProgress?

    // MARK: - Init

    init(
        question: String,
        subjectArea: String,
        accentColorName: String,
        iconName: String,
        isActive: Bool = false,
        createdAt: Date = .now
    ) {
        self.question = question
        self.subjectArea = subjectArea
        self.accentColorName = accentColorName
        self.iconName = iconName
        self.isActive = isActive
        self.createdAt = createdAt
        self.contentItems = []
        self.progress = nil
    }
}
