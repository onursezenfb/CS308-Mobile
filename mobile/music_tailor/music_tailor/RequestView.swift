//
//  RequestView.swift
//  music_tailor
//
//  Created by Şimal on 24.12.2023.
//

import SwiftUI

struct RequestView: View {
    @EnvironmentObject var userSession: UserSession
    @State private var requesters: [String] = []

    var body: some View {
        List(requesters, id: \.self) { requester in
            if requester != userSession.username {
                HStack {
                    Text(requester)
                    Spacer()
                    Button(action: { acceptRequest(from: requester) }) {
                        Image(systemName: "checkmark.circle")
                    }
                    .buttonStyle(BorderlessButtonStyle())

                    Button(action: { declineRequest(from: requester) }) {
                        Image(systemName: "xmark.circle")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
        }
        .onAppear(perform: fetchFriendRequests)
    }

    private func fetchFriendRequests() {
        guard let loggedInUser = userSession.username, !loggedInUser.isEmpty else {
            print("Logged-in user's username is not available")
            return
        }

        guard let url = URL(string: "http://127.0.0.1:8000/api/see-request-mobile/\(loggedInUser)") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"


        URLSession.shared.dataTask(with: request) { data, response, error in
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
                let users = try JSONDecoder().decode([String].self, from: data)
                DispatchQueue.main.async {
                    self.requesters = users
                }
            } catch {
                print("Failed to decode response: \(error.localizedDescription)")
            }
        }.resume()
    }


    private func acceptRequest(from requester: String) {
        guard let loggedInUser = userSession.username, !loggedInUser.isEmpty else {
            print("Logged-in user's username is not available")
            return
        }

        let urlString = "http://127.0.0.1:8000/api/accept-request"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["requester": requester, "user_requested": loggedInUser]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    // Remove the accepted requester from the list
                    self.requesters.removeAll { $0 == requester }
                    // Optionally, you can show a confirmation message to the user
                } else if let error = error {
                    print("Failed to accept friend request: \(error.localizedDescription)")
                } else {
                    print("Request failed with status code other than 200")
                }
            }
        }.resume()
    }



    private func declineRequest(from requester: String) {
        // Implement the logic to decline the request.
        // If there's an API endpoint for declining, call it here.
        // Otherwise, simply remove the requester from the list.
    }
}


struct RequestView_Previews: PreviewProvider {
    static var previews: some View {
        RequestView()
            .environmentObject(UserSession()) // Assuming UserSession is your environment object
            // Add mock data or conditions as necessary
    }
}

