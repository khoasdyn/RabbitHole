import SwiftUI

// MARK: - Shared layout constants

enum CardStyle {
    static let cornerRadius: CGFloat = 14
    static let padding: CGFloat = 14
    static let spacing: CGFloat = 10
}

// MARK: - Reusable type badge

struct TypeBadge: View {
    let type: ContentType

    var body: some View {
        Label(type.label, systemImage: type.iconName)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(type.color)
    }
}
