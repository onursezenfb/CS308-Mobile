//
//  PlaylistDetailView.swift
//  music_tailor
//
//  Created by Şimal on 1.01.2024.
//

import SwiftUI

struct PlaylistDetailView: View {
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var themeManager: ThemeManager
    var playlist: Playlist
    @State private var searchText: String = ""
    @State private var searchResults: [Song] = []
    @State private var playlistSongs: [Song] = []
    @State private var showingAddUserSheet = false
    @State private var userSearchText: String = ""
    @State private var userSearchResults: [User] = []
    @State private var blockedUsers: [BlockedUser] = []
    @State private var showAlert = false
    @State private var alertMessage = ""
    



    var body: some View {
        VStack {
            
            Text(playlist.playlist_name)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(themeManager.themeColor)
                .padding(10)

            
            
            Button("Add Users to This Playlist!") {
                            showingAddUserSheet = true
                        }
            
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [themeManager.themeColor, themeManager.themeColor.opacity(0.7)]), startPoint: .top, endPoint: .bottom))
                        .cornerRadius(15)
                        .foregroundColor(.white)
                        .font(.headline)
                        .shadow(radius: 5)
                        .scaleEffect(showingAddUserSheet ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.3))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                       .sheet(isPresented: $showingAddUserSheet
                      ) {
                           // Sheet content for adding users
                           VStack {
                               Text("Add Collaborators to")
                                   .font(.custom("Arial-BoldMT", size: 25))
                                   .bold()
                                   .foregroundColor(.clear)
                                   .background(
                                       LinearGradient(gradient: Gradient(colors: [Color.pink, Color.orange]), startPoint: .leading, endPoint: .trailing)
                                   )
                                   .mask(
                                       Text("Add Collaborators to")
                                           .font(.custom("Arial-BoldMT", size: 25))
                                           .bold()
                                   )
                               Text("Your Playlist")
                                   .font(.custom("Arial-BoldMT", size: 25))
                                   .bold()
                                   .foregroundColor(.clear)
                                   .background(
                                       LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .leading, endPoint: .trailing)
                                   )
                                   .mask(
                                       Text("Your Playlist")
                                           .font(.custom("Arial-BoldMT", size: 25))
                                           .bold()
                                   )
                               
                               TextField("Search users...", text: $userSearchText)
                                   .textFieldStyle(RoundedBorderTextFieldStyle())
                                   .padding()
                                   .onChange(of: userSearchText, perform: { value in
                                       if !value.isEmpty {
                                           searchUsers(query: value)
                                       }
                                   })

                               List(userSearchResults, id: \.id) { user in
                                           HStack {
                                               Text(user.username)
                                               Spacer()
                                               if blockedUsers.contains(where: { $0.blockedUsername == user.username }) {
                                                   Text("Blocked")
                                                       .foregroundColor(.red)
                                               } else {
                                                   Button(action: {
                                                       addUserToPlaylist(username: user.username)
                                                       showingAddUserSheet = false // Close the sheet
                                                   }) {
                                                       Image(systemName: "plus.circle.fill")
                                                           .foregroundColor(.green)
                                                   }
                                               }
                                           }
                                       }
                                   }
                                   .padding()
                       }
        
            List {
                Section(header: Text("Playlist Songs")) {
                    ForEach(playlistSongs, id: \.song_id) { song in
                        HStack {
                            Text(song.name)
                            Spacer()
                            Button(action: {
                                deleteSongFromPlaylist(songId: song.song_id)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }

                TextField("Search songs...", text: $searchText)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: searchText, perform: { value in
                        if value.isEmpty {
                            searchResults = []
                        } else {
                            searchSongs(query: value)
                        }
                    })
            List{
                Section(header: Text("Search Results")) {
                    ForEach(searchResults, id: \.song_id) { song in
                        HStack {
                            Text(song.name)
                            Spacer()
                            Button(action: {
                                addSongToPlaylist(songId: song.song_id)
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Playlist Details", displayMode: .inline)
        .onAppear(perform: fetchPlaylistSongs)
        .onAppear(perform: fetchBlockedUsers)
        .alert(isPresented: $showAlert) {
                Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
    }
    
    func searchUsers(query: String) {
            guard let url = URL(string: "http://127.0.0.1:8000/api/users") else { return }

            // Assuming that the search term is passed as a query parameter
            var request = URLRequest(url: url)
            request.httpMethod = "GET"

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    do {
                        // Decode the response into an array of User objects
                        let users = try JSONDecoder().decode([User].self, from: data)
                        DispatchQueue.main.async {
                            // Update the search results
                            self.userSearchResults = users.filter { $0.username.lowercased().contains(query.lowercased()) }
                        }
                    } catch {
                        print("Error decoding user search results: \(error)")
                    }
                }
            }.resume()
        }
    
    func addUserToPlaylist(username: String) {
        // Check if the user is blocked
        if blockedUsers.contains(where: { $0.blockedUsername == username }) {
            DispatchQueue.main.async {
                print("User is blocked, alert should show now.")
                self.alertMessage = "You can't add this user to your playlist because they are blocked!"
                self.showAlert = true
            }
            return
        }

        guard let url = URL(string: "http://127.0.0.1:8000/api/playlist/\(playlist.id)/users") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: [String]] = ["usernames": [username]]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("User added to playlist successfully, alert should show now.")
                    self.alertMessage = "User \(username) added to playlist successfully."
                    self.showAlert = true
                } else {
                    print("Error adding user to playlist: \(error?.localizedDescription ?? "Unknown error"), alert should show now.")
                    self.alertMessage = "Error adding user to playlist."
                    self.showAlert = true
                }
            }
        }.resume()
    }


    
    func fetchBlockedUsers() {
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
            if let data = data, let blockedUsers = try? JSONDecoder().decode([BlockedUser].self, from: data) {
                DispatchQueue.main.async {
                    self.blockedUsers = blockedUsers
                }
            } else {
                print("Failed to fetch or decode blocked users")
            }
        }.resume()
    }


    func fetchPlaylistSongs() {
        guard let url = URL(string: "http://127.0.0.1:8000/api/playlist/\(playlist.id)") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let decodedResponse = try? JSONDecoder().decode(PlaylistDetailResponse.self, from: data) {
                DispatchQueue.main.async {
                    self.playlistSongs = decodedResponse.playlistDetail.songs
                }
            } else {
                print("Error: Decoding failed or data is nil")
            }
        }.resume()
    }

    func deleteSongFromPlaylist(songId: String) {
        guard let url = URL(string: "http://127.0.0.1:8000/api/playlist/\(playlist.id)/song/\(songId)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    self.fetchPlaylistSongs() // Reload the playlist songs after deletion
                }
            } else {
                // Handle any errors
                print("Error: Failed to delete the song from playlist")
            }
        }.resume()
    }



    func searchSongs(query: String) {
        // Implement the search functionality
        // Assuming the search endpoint returns a list of songs based on the query
        guard let url = URL(string: "http://127.0.0.1:8000/api/songs") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let response = try? JSONDecoder().decode([Song].self, from: data) {
                DispatchQueue.main.async {
                    self.searchResults = response.filter { $0.name.lowercased().contains(query.lowercased()) }
                }
            }
        }.resume()
    }

    func addSongToPlaylist(songId: String) {
        guard let url = URL(string: "http://127.0.0.1:8000/api/playlist/\(playlist.id)/songs") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: [String]] = ["song_ids": [songId]]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    self.fetchPlaylistSongs() // Reload the playlist songs after adding
                }
            }
        }.resume()
    }
}

struct PlaylistDetailResponse: Decodable {
    var songsCount: Int
    var playlistDetail: PlaylistDetail

    private enum CodingKeys: String, CodingKey {
        case songsCount = "songs_count"
        case playlistDetail = "songs"
    }

    struct PlaylistDetail: Decodable {
        var id: Int
        var playlistName: String
        var createdAt: String
        var updatedAt: String
        var songs: [Song]

        private enum CodingKeys: String, CodingKey {
            case id, playlistName = "playlist_name", createdAt = "created_at", updatedAt = "updated_at", songs
        }
    }
}


struct PlaylistDetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock Pivot object
        let mockPivot = Pivot(username: "mockUser", playlist_id: 123)
        
        // Create a mock Playlist object including all the necessary properties
        let mockPlaylist = Playlist(
            id: 123,
            playlist_name: "Mock Playlist",
            created_at: "2024-01-01T00:00:00Z",
            updated_at: "2024-01-01T00:00:00Z",
            pivot: mockPivot
        )
        
        // Pass the mock Playlist object to the PlaylistDetailView
        PlaylistDetailView(playlist: mockPlaylist)
            .environmentObject(UserSession())
            .environmentObject(ThemeManager())// Add this if UserSession is used within the view
            // Add any other necessary environment objects here
    }
}

