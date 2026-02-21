import SwiftUI

// MARK: - Shared layout constants

enum CardStyle {
    static let cornerRadius: CGFloat = 14
    static let padding: CGFloat = 14
    static let spacing: CGFloat = 10
    static let mediaHeight: CGFloat = 180
    static let imageHeight: CGFloat = 160
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

// MARK: - Bundle image loader

enum BundleImage {
    static func load(name: String, ext: String) -> UIImage? {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext),
              let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }
}
