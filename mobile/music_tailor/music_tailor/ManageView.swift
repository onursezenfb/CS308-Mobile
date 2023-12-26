//
//  ManageView.swift
//  music_tailor
//
//  Created by Şimal on 24.12.2023.
//

import SwiftUI

struct Friend: Identifiable, Decodable {
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
    let pivot: Pivot?

    enum CodingKeys: String, CodingKey {
        case username, email, emailVerifiedAt = "email_verified_at", name, surname, dateOfBirth = "date_of_birth", language, subscription, rateLimit = "rate_limit", createdAt = "created_at", updatedAt = "updated_at", stripeId = "stripe_id", pmType = "pm_type", pmLastFour = "pm_last_four", trialEndsAt = "trial_ends_at", theme, image, pivot
    }

    struct Pivot: Decodable {
        let requester: String
        let userRequested: String
        let status: Int

        enum CodingKeys: String, CodingKey {
            case requester, userRequested = "user_requested", status
        }
    }
}

struct BlockedUser: Identifiable, Decodable {
    var id: Int
    var blockerUsername: String
    var blockedUsername: String
    var createdAt: String
    var updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case blockerUsername = "blocker_username"
        case blockedUsername = "blocked_username"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}


struct AlertMessage: Identifiable {
    let id = UUID()
    let message: String
}




struct ManageView: View {
    @EnvironmentObject var userSession: UserSession
        @State private var friends: [Friend] = []
        @State private var blockedUsers: [BlockedUser] = [] // Corrected type for blocked users
        @State private var successMessage: AlertMessage?

        var body: some View {
            List {
                Section(header: Text("Friends")) {
                    ForEach(friends) { friend in
                        HStack {
                            Text(friend.username)
                            Spacer()
                            Button("Unfriend") {
                                unfriend(friend)
                            }
                        }
                    }
                }

                Section(header: Text("Blocked Users")) {
                    ForEach(blockedUsers, id: \.id) { blockedUser in
                        HStack {
                            Text(blockedUser.blockedUsername)
                            Spacer()
                            Button("Unblock") {
                                unblockUser(blockedUser)
                            }
                        }
                    }
                }            }
            .onAppear {
                fetchFriends()
                fetchBlockedUsers()
            }
            .alert(item: $successMessage) { alertMessage in
                Alert(title: Text(alertMessage.message))
            }
        }

    private func fetchFriends() {
        guard let currentUser = userSession.username, !currentUser.isEmpty else {
            print("Current user's username is not available")
            return
        }

        let urlString = "http://127.0.0.1:8000/api/user/\(currentUser)/friends"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }

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
                let fetchedFriends = try JSONDecoder().decode([Friend].self, from: data)
                DispatchQueue.main.async {
                    self.friends = fetchedFriends
                }
            } catch {
                print("Failed to decode response: \(error.localizedDescription)")
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
                        self.blockedUsers = blockedUsers
                    }
                } catch {
                    print("Failed to decode blocked users: \(error)")
                }
            }
        }.resume()
    }





    private func unfriend(_ friend: Friend) {
        guard let currentUser = userSession.username else {
            print("Logged-in user's username is not available")
            return
        }

        let urlString = "http://127.0.0.1:8000/api/unfriend-mobile/\(friend.username)/\(currentUser)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("No valid HTTP response received.")
                    return
                }
                
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                            print("Response data: \(responseString)")
                        }

                if httpResponse.statusCode == 200 {
                    if let index = self.friends.firstIndex(where: { $0.username == friend.username }) {
                        self.friends.remove(at: index)
                        print("Successfully unfriended \(friend.username)")
                    } else {
                        print("User \(friend.username) not found in the current friends list.")
                    }
                } else {
                    print("Failed to unfriend with status code: \(httpResponse.statusCode). Error: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }.resume()
    }
    
    private func unblockUser(_ user: BlockedUser) {
            guard let blockerUsername = userSession.username else {
                print("Logged-in user's username is not available")
                return
            }

            let urlString = "http://127.0.0.1:8000/api/unblock-user-mobile"
            guard let url = URL(string: urlString),
                  let bodyData = try? JSONEncoder().encode(["blocker_username": blockerUsername, "blocked_username": user.blockedUsername]) else {
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
                        self.blockedUsers.removeAll { $0.blockedUsername == user.blockedUsername }
                        print("Successfully unblocked user.")
                        fetchBlockedUsers() // Refresh the list of blocked users
                    } else {
                        print("Failed to unblock: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }.resume()
        }


}

struct ManageView_Previews: PreviewProvider {
    static var previews: some View {
        ManageView()
            .environmentObject(UserSession()) // Assuming UserSession is your environment object
    }
}

