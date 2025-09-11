import Foundation
import SwiftUI

struct Note: Identifiable, Equatable, Codable {
    let id: String
    var title: String
    var description: String
    var backgroundColorHex: String
    let createdAt: Date
    var updatedAt: Date
    var creatorUsername: String?

    var backgroundColor: Color {
        Color(hex: backgroundColorHex)
    }
}

extension Note {
    static func randomColorHex() -> String {
        // Match Android's exact color palette from NotesViewModel.getRandomNoteColor()
        let colors: [Color] = [
            Color(red: 1.0, green: 0.98, blue: 0.77),  // Light Yellow #FFF9C4
            Color(red: 1.0, green: 0.88, blue: 0.70),  // Light Orange #FFE0B2
            Color(red: 0.88, green: 0.96, blue: 0.99), // Light Blue #E1F5FE
            Color(red: 0.95, green: 0.90, blue: 0.96), // Light Purple #F3E5F5
            Color(red: 0.91, green: 0.96, blue: 0.91)  // Light Green #E8F5E8
        ]
        return (colors.randomElement() ?? .yellow).toHex() ?? "#FFF9C4"
    }
}


