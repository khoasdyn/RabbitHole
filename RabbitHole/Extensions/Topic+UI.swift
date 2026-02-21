import SwiftUI

extension Topic {

    var accentColor: Color {
        switch accentColorName {
        case "orange": .orange
        case "blue": .blue
        case "purple": .purple
        case "green": .green
        case "pink": .pink
        case "red": .red
        case "yellow": .yellow
        case "cyan": .cyan
        case "mint": .mint
        case "indigo": .indigo
        case "teal": .teal
        default: .blue
        }
    }
}
