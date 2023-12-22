//
//  music_tailorApp.swift
//  music_tailor
//
//  Created by Ozan Çelebi on 2.11.2023.
//

import SwiftUI

@main
struct music_tailorApp: App {
    // Create an instance of ThemeManager
    var themeManager = ThemeManager()

    // Existing UserSession instance (if already declared)
    var userSession = UserSession()

    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(userSession) // Continue providing UserSession
                .environmentObject(themeManager) // Provide ThemeManager as an environment object
        }
    }
}

