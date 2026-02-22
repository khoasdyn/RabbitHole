import Foundation
import SwiftUI

enum ContentType: String, Codable, CaseIterable {
    case article
    case quiz
    case discussion
    case challenge

    var label: String {
        switch self {
        case .article: "Article"
        case .quiz: "Quiz"
        case .discussion: "Discussion"
        case .challenge: "Challenge"
        }
    }

    var iconName: String {
        switch self {
        case .article: "doc.text"
        case .quiz: "questionmark.circle"
        case .discussion: "bubble.left.and.bubble.right"
        case .challenge: "flame"
        }
    }

    var color: Color {
        switch self {
        case .article: .blue
        case .quiz: .orange
        case .discussion: .purple
        case .challenge: .pink
        }
    }
}
