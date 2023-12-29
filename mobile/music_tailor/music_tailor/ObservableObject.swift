import Foundation
import SwiftUI
class UserSession: ObservableObject {
    @Published var username: String?
    @Published var email: String?
    @Published var name: String?
    @Published var surname: String?
    @Published var password: String?
    @Published var rateLimit: String = "100"
    @Published var theme: String?
    @Published var subscription: String = "Free"
    @Published var childMode: Bool = false // Added boolean property

    func updateSubscription(to newSubscriptionType: String) {
        DispatchQueue.main.async {
            self.subscription = newSubscriptionType
        }
    }
    
    func updateRateLimit(to newRateLimitType: String) {
        DispatchQueue.main.async {
            self.rateLimit = newRateLimitType
        }
    }
    
    func setChildMode(_ enabled: Bool) {
        childMode = enabled
    }
    
    func fetchAndUpdateUserData() {
        guard let username = self.username, let url = URL(string: "http://127.0.0.1:8000/api/users/\(username)") else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Handle response and errors appropriately
            if let data = data {
                do {
                    let fetchedUser = try JSONDecoder().decode(User.self, from: data)
                    DispatchQueue.main.async {
                        // Update the UserSession properties with fetched data
                        self.updateUserData(with: fetchedUser)
                    }
                } catch {
                    print("Error decoding user data: \(error)")
                }
            }
        }
        task.resume()
    }

    private func updateUserData(with user: User) {
        // Update the properties of UserSession
        self.subscription = user.subscription
        self.rateLimit = user.rateLimit
        // Update other properties as necessary
    }
    
    static var mock: UserSession {
        let session = UserSession()
        session.username = "ozaancelebi2"
        session.email = "ozancelebi@gmail.com"
        session.name = "Ozan"
        session.surname = "Çelebi"
        session.password = "Ozan1234."
        session.theme = "Pink"
        session.rateLimit = "100"
        session.childMode = true // Set the childMode property
        return session
    }

}
