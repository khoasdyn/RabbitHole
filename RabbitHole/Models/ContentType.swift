import Foundation
import SwiftUI

enum ContentType: String, Codable, CaseIterable {
    case video
    case article
    case imageCard
    case quiz
    case discussion
    case survey
    case challenge

    var label: String {
        switch self {
        case .video: "Video"
        case .article: "Article"
        case .imageCard: "Image"
        case .quiz: "Quiz"
        case .discussion: "Discussion"
        case .survey: "Survey"
        case .challenge: "Challenge"
        }
    }

    var iconName: String {
        switch self {
        case .video: "play.circle.fill"
        case .article: "doc.text"
        case .imageCard: "photo"
        case .quiz: "questionmark.circle"
        case .discussion: "bubble.left.and.bubble.right"
        case .survey: "chart.bar"
        case .challenge: "flame"
        }
    }

    var color: Color {
        switch self {
        case .video: .red
        case .article: .blue
        case .imageCard: .indigo
        case .quiz: .orange
        case .discussion: .purple
        case .survey: .teal
        case .challenge: .pink
        }
    }
}
