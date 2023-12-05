//
//  ObservableObject.swift
//  music_tailor
//
//  Created by Şimal on 4.12.2023.
//

import Foundation
import SwiftUI
class UserSession: ObservableObject {
    @Published var username: String?
    @Published var email: String?
    @Published var name: String?
    @Published var surname: String?
    @Published var password: String?
    // Add other relevant fields
}
