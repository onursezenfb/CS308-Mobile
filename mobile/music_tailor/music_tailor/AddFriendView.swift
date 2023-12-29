import SwiftUI

struct User: Identifiable, Decodable {
    var id = UUID() // For SwiftUI's Identifiable conformance
    let username: String
    let email: String
    let emailVerifiedAt: String?
    let name: String
    let surname: String
    let dateOfBirth: String
    let language: String
    let subscription: String
    let rateLimit: String
    let createdAt: String
    let updatedAt: String
    let stripeId: String?
    let pmType: String?
    let pmLastFour: String?
    let trialEndsAt: String?
    let theme: String?
    let image: String?

    enum CodingKeys: String, CodingKey {
        case username, email, emailVerifiedAt = "email_verified_at", name, surname, dateOfBirth = "date_of_birth", language, subscription, rateLimit = "rate_limit", createdAt = "created_at", updatedAt = "updated_at", stripeId = "stripe_id", pmType = "pm_type", pmLastFour = "pm_last_four", trialEndsAt = "trial_ends_at", theme, image
    }
}


struct AddFriendView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userSession: UserSession // Assuming this holds the logged-in user's info
    @EnvironmentObject var themeManager: ThemeManager
    @State private var searchText = ""
    @State private var searchResults: [User] = []
    @State private var requestSent: [String: Bool] = [:]
    @State private var userBlocked: [String: Bool] = [:] // To keep track of blocked users
    @State private var showingOwnNameAlert = false
    @State private var blockedUsernames: Set<String> = []
    
    var body: some View {
            VStack {
            
                Text("Add a Friend").font(.largeTitle).bold().padding().foregroundColor(themeManager.themeColor)

                HStack {
                    SearchBar(text: $searchText).padding(.horizontal)
                    Button("Search") { performSearch() }.foregroundColor(themeManager.themeColor).padding()
                }
                
                if showingOwnNameAlert {
                                Text("You cannot search for your own username.").foregroundColor(.red).padding()
                            }

                List(searchResults) { user in
                                if !blockedUsernames.contains(user.username) && user.username != userSession.username {
                    HStack {
                        Text(user.username)
                        Spacer()

                        if !requestSent[user.username, default: false] {
                            Button("Follow Friend") { sendFriendRequest(to: user) }.foregroundColor(.blue)
                        } else {
                            Text("Request Sent").foregroundColor(.gray)
                        }
                    }

                    HStack {
                        Spacer()
                        if !userBlocked[user.username, default: false] {
                            Button("Block") { blockUser(user) }.foregroundColor(.red)
                        } else {
                            Text("Blocked").foregroundColor(.gray)
                        }
                    }
                }
                Spacer()
            }
                .onAppear(perform: fetchBlockedUsers)
        }
    }
    private func performSearch() {
        if searchText == userSession.username {
                    showingOwnNameAlert = true
                    return
                } else {
                    showingOwnNameAlert = false
                }
        let encodedUsername = searchText.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ""
        guard let url = URL(string: "http://127.0.0.1:8000/api/users/\(encodedUsername)") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error making request: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received from the server")
                return
            }
            
            print("Raw data: \(String(decoding: data, as: UTF8.self))")
            
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    self.searchResults = [user]
                }
            } catch {
                print("Failed to decode response: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    
    private func sendFriendRequest(to user: User) {
        guard let requesterUsername = userSession.username else {
            print("Logged-in user's username is not available")
            return
        }

        guard let url = URL(string: "http://127.0.0.1:8000/api/friend-request-mobile/\(requesterUsername)/\(user.username)") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    self.requestSent[user.username] = true
                    print("Friend request sent successfully to \(user.username)")
                } else {
                    print("Failed to send friend request: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }.resume()
    }

    
    private func blockUser(_ user: User) {
            guard let blockerUsername = userSession.username else {
                print("Logged-in user's username is not available")
                return
            }

            let urlString = "http://127.0.0.1:8000/api/block-user-mobile"
            guard let url = URL(string: urlString), let bodyData = try? JSONEncoder().encode(["blocker_username": blockerUsername, "blocked_username": user.username]) else {
                print("Invalid URL or body data")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = bodyData

        URLSession.shared.dataTask(with: request) { _, response, error in
                    DispatchQueue.main.async {
                        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                            self.userBlocked[user.username] = true
                            print("Successfully blocked user.")
                        } else {
                            print("Failed to block: \(error?.localizedDescription ?? "Unknown error")")
                        }
                    }
                }.resume()
        }
    
    private func fetchBlockedUsers() {
        guard let currentUser = userSession.username, !currentUser.isEmpty else {
            print("Current user's username is not available")
            return
        }

        let urlString = "http://127.0.0.1:8000/api/user/\(currentUser)/blocked"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching blocked users: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error fetching blocked users: Invalid response")
                return
            }

            guard let data = data else {
                print("No data received for blocked users")
                return
            }

            do {
                let blockedUsers = try JSONDecoder().decode([BlockedUser].self, from: data)
                DispatchQueue.main.async {
                    self.blockedUsernames = Set(blockedUsers.map { $0.blockedUsername })
                }
            } catch {
                print("Failed to decode blocked users: \(error)")
            }
        }.resume()
    }

    
    struct SearchBar: UIViewRepresentable {
        @Binding var text: String
        
        func makeUIView(context: Context) -> UISearchBar {
            let searchBar = UISearchBar(frame: .zero)
            searchBar.delegate = context.coordinator
            return searchBar
        }
        
        func updateUIView(_ uiView: UISearchBar, context: Context) {
            uiView.text = text
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, UISearchBarDelegate {
            var parent: SearchBar
            
            init(_ parent: SearchBar) {
                self.parent = parent
            }
            
            func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
                parent.text = searchText
            }
        }
    }
    
    // Define this struct for preview in Xcode
    struct AddFriendView_Previews: PreviewProvider {
        static var previews: some View {
            AddFriendView()
        }
    }
}
