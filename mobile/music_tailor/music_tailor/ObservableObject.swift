import Foundation
import SwiftUI
class UserSession: ObservableObject {
    @Published var username: String?
    @Published var email: String?
    @Published var name: String?
    @Published var surname: String?
    @Published var password: String?
    @Published var theme: String?
    
    static var mock: UserSession {
        let session = UserSession()
        session.username = "ozaancelebi2"
        session.email = "ozancelebi@gmail.com"
        session.name = "Ozan"
        session.surname = "Çelebi"
        session.password = "Ozan1234."
        session.theme = "Pink"
        return session
    }
    

}

