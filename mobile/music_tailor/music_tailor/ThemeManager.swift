//
//  ThemeManager.swift
//  music_tailor
//
//  Created by selin ceydeli on 12/22/23.
//

import SwiftUI

class ThemeManager: ObservableObject {
    @Published var themeColor: Color = .pink // Default color

    func applyTheme(named themeName: String) {
        switch themeName {
        case "Red":
            themeColor = .red
        case "Blue":
            themeColor = .blue
        case "Green":
            themeColor = .green
        case "Yellow":
            themeColor = .yellow
        case "Purple":
            themeColor = .purple
        // Add more themes as needed
        default:
            themeColor = .pink
        }
    }
}
