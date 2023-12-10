import Foundation
import SwiftUI
class UserSession: ObservableObject {
    @Published var username: String?
    @Published var email: String?
    @Published var name: String?
    @Published var surname: String?
    @Published var password: String?
    
    static var mock: UserSession {
        let session = UserSession()
        session.username = "MockUser"
        session.email = "mockuser@example.com"
        session.name = "John"
        session.surname = "Doe"
        session.password = "password123"
        return session
    }
    

}

