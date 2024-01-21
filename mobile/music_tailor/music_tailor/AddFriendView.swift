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

struct FriendRequest: Decodable {
        var requester: String
        // Add other properties as per your API response
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
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var allUsers: [User] = [] // To store all users

    
    var body: some View {
        VStack {
                    Text("Add a Friend").font(.largeTitle).bold().padding().foregroundColor(themeManager.themeColor)

                    SearchBar(text: $searchText)
                        .padding()
                        .onChange(of: searchText) { newValue in
                            performSearch(with: newValue)
                        }
                        
                    if showingOwnNameAlert {
                        Text("You cannot search for your own username.").foregroundColor(.red).padding()
                    }

                    ScrollView {
                        LazyVStack {
                            ForEach(searchResults, id: \.id) { user in
                                UserRow(user: user)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .onAppear {
                    fetchAllUsers()
                    fetchBlockedUsers()
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }

    private func UserRow(user: User) -> some View {
        HStack {
            Text(user.username)
            Spacer()
            if user.username != userSession.username {
                if !blockedUsernames.contains(user.username) {
                    if !requestSent[user.username, default: false] {
                        Button("Follow Friend") {
                            sendFriendRequest(to: user)
                        }
                        .foregroundColor(.blue)
                        .disabled(blockedUsernames.contains(user.username)) // Disable if user is blocked
                    } else {
                        Text("Request Sent").foregroundColor(.gray)
                    }
                    Button("Block") {
                        blockUser(user)
                    }
                    .foregroundColor(.red)
                } else {
                    Text("Blocked").foregroundColor(.gray)
                }
            }
        }
    }

    
    
    
    private func fetchAllUsers() {
            guard let url = URL(string: "http://127.0.0.1:8000/api/users") else {
                print("Invalid URL")
                return
            }

            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        let users = try JSONDecoder().decode([User].self, from: data)
                        DispatchQueue.main.async {
                            self.allUsers = users
                        }
                    } catch {
                        print("Error decoding user data: \(error)")
                    }
                }
            }.resume()
        }
    
    private func performSearch(with searchText: String) {
            if searchText.isEmpty {
                searchResults = []
            } else {
                searchResults = allUsers.filter { $0.username.lowercased().contains(searchText.lowercased()) }
            }
        }

    
    
    private func sendFriendRequest(to user: User) {
        guard let currentUser = userSession.username else {
            self.alertMessage = "Logged-in user's username is not available"
            self.showAlert = true
            return
        }

        // First, check if already friends
        checkIfAlreadyFriends(currentUser: currentUser, potentialFriend: user.username) { areFriends in
            if areFriends {
                self.alertMessage = "You are already friends with \(user.username)!"
                self.showAlert = true
            } else {
                // If not already friends, proceed to check for duplicate friend requests
                self.checkForDuplicateRequest(to: user, currentUser: currentUser)
            }
        }
    }

    private func checkIfAlreadyFriends(currentUser: String, potentialFriend: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:8000/api/user/\(currentUser)/friends") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let friends = try? JSONDecoder().decode([Friend].self, from: data) {
                DispatchQueue.main.async {
                    completion(friends.contains(where: { $0.username == potentialFriend }))
                }
            } else {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }.resume()
    }

    private func checkForDuplicateRequest(to user: User, currentUser: String) {
        let checkUrlString = "http://127.0.0.1:8000/api/see-request-mobile/\(user.username)"
        guard let checkUrl = URL(string: checkUrlString) else {
            self.alertMessage = "Invalid URL for checking requests"
            self.showAlert = true
            return
        }

        var request = URLRequest(url: checkUrl)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.alertMessage = "Error checking requests: \(error.localizedDescription)"
                    self.showAlert = true
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.alertMessage = "No HTTP response received"
                    self.showAlert = true
                }
                return
            }

            if httpResponse.statusCode == 200, let data = data {
                do {
                    let requesters = try JSONDecoder().decode([String].self, from: data)
                    if requesters.contains(currentUser) {
                        DispatchQueue.main.async {
                            self.alertMessage = "You can't send a request to the same person again!"
                            self.showAlert = true
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.proceedToSendFriendRequest(to: user)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.alertMessage = "Failed to decode existing requests: \(error.localizedDescription)"
                        self.showAlert = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.alertMessage = "Error checking requests: \(httpResponse.statusCode)"
                    self.showAlert = true
                }
            }
        }.resume()
    }
    
    private func proceedToSendFriendRequest(to user: User) {
        guard let requesterUsername = userSession.username else {
            self.alertMessage = "Logged-in user's username is not available"
            self.showAlert = true
            return
        }

        guard let url = URL(string: "http://127.0.0.1:8000/api/friend-request-mobile/\(requesterUsername)/\(user.username)") else {
            self.alertMessage = "Invalid URL"
            self.showAlert = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        self.requestSent[user.username] = true
                        self.alertMessage = "Friend request sent successfully to \(user.username)"
                        self.showAlert = true
                    } else {
                        self.alertMessage = "Failed to send friend request: \(error?.localizedDescription ?? "Unknown error")"
                        self.showAlert = true
                    }
                } else {
                    self.alertMessage = "Failed to send friend request due to an unknown response from the server."
                    self.showAlert = true
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
                    // Update the blockedUsernames set
                    self.blockedUsernames.insert(user.username)
                    self.userBlocked[user.username] = true
                    print("Successfully blocked user \(user.username).")
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
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP Status Code: \(httpResponse.statusCode)")
                }

                if let error = error {
                    print("Error fetching blocked users: \(error.localizedDescription)")
                    return
                }

                guard let data = data, !data.isEmpty else {
                    print("No data received or data is empty")
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
