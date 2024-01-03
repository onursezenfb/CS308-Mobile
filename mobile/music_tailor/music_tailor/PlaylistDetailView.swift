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

    var body: some View {
        VStack {
            Text(playlist.playlist_name)
                .font(.largeTitle)
                .padding()

            TextField("Search songs...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .onChange(of: searchText, perform: { value in
                    if value.isEmpty {
                        searchResults = []
                    } else {
                        searchSongs(query: value)
                    }
                })
            
            Button("Add Users to This Playlist!") {
                           showingAddUserSheet = true
                       }
                       .padding()
                       .sheet(isPresented: $showingAddUserSheet
                      ) {
                           // Sheet content for adding users
                           VStack {
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
            guard let url = URL(string: "http://127.0.0.1:8000/api/playlist/\(playlist.id)/users") else { return }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let body: [String: [String]] = ["usernames": [username]]
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("User added to playlist successfully")
                    // Handle successful addition here, e.g., show a confirmation message
                } else {
                    // Handle error
                    print("Error adding user to playlist: \(error?.localizedDescription ?? "Unknown error")")
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

