//
//  ReccomendationView.swift
//  music_tailor
//
//  Created by Şimal on 5.12.2023.
//



import SwiftUI



struct RecommendationView: View {
    @EnvironmentObject var userSession: UserSession
    @State private var recommendedSongs: [RecommendedSong] = []

    var body: some View {
            VStack {
                Text("Your Fav Genre")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.black)
                    .frame(width: 300, height: 5, alignment: .leading)
                Text("Recommendations")
                    .font(Font.system(size: 30, design: .rounded))
                    .bold()
                    .foregroundColor(.pink)
                    .frame(width: 300, height: 50, alignment: .leading)

                List(recommendedSongs, id: \.song.song_id) { recommendedSong in
                    HStack {
                        if let imageUrl = recommendedSong.albumImageUrl, let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image.resizable()
                                } else if phase.error != nil {
                                    Image(systemName: "photo") // Placeholder for error
                                } else {
                                    Image(systemName: "photo") // Placeholder for loading
                                }
                            }
                            .frame(width: 50, height: 50)
                        }
                        VStack(alignment: .leading) {
                            Text(recommendedSong.song.name)
                            Text("Album: \(recommendedSong.albumName)")
                        }
                    }
                }
            }
            .onAppear {
                fetchRecommendations()
            }
    }

    private func fetchRecommendations() {
        guard let username = userSession.username, !username.isEmpty else {
            print("Username is empty")
            return
        }
        let urlString = "http://127.0.0.1:8000/api/users/\(username)/fav-genre-recommendations"
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching recommendations: \(error)")
                return
            }

            guard let data = data else {
                print("No data returned")
                return
            }

            if let songs = try? JSONDecoder().decode([Song].self, from: data) {
                print("Received songs: \(songs)")
                DispatchQueue.main.async {
                    self.recommendedSongs = songs.map { RecommendedSong(song: $0, albumImageUrl: nil, albumName: "") }
                    // Populate album details for each song
                    for song in songs {
                        fetchAlbum(for: song.album_id, song: song)
                    }
                }
            } else {
                print("Failed to decode songs")
            }
        }.resume()
    }


    // Similar error handling can be added to fetchSongDetails and fetchAlbum methods.


    private func fetchSongDetails(for songID: String) {
        guard let url = URL(string: "http://127.0.0.1:8000/api/songs/\(songID)") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching song details: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data returned for song ID: \(songID)")
                return
            }

            do {
                let song = try JSONDecoder().decode(Song.self, from: data)
                fetchAlbum(for: song.album_id, song: song)
            } catch {
                print("Error decoding song details for ID \(songID): \(error)")
            }
        }.resume()
    }


    private func fetchAlbum(for albumID: String, song: Song) {
        guard let url = URL(string: "http://127.0.0.1:8000/api/albums/\(albumID)") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }

            if let album = try? JSONDecoder().decode(Album.self, from: data) {
                DispatchQueue.main.async {
                    if let index = self.recommendedSongs.firstIndex(where: { $0.song.song_id == song.song_id }) {
                        self.recommendedSongs[index].albumImageUrl = album.image_url
                        self.recommendedSongs[index].albumName = album.name
                    } else {
                        self.recommendedSongs.append(RecommendedSong(song: song, albumImageUrl: album.image_url, albumName: album.name))
                    }
                }
            }
        }.resume()
    }

}

struct RecommendedSong {
    var song: Song
    var albumImageUrl: String?
    var albumName: String
}

struct Song: Decodable {
    var song_id: String
    var isrc: String
    var name: String
    var performers: String
    var album_id: String
    var duration: Int
    var tempo: String
    var key: String
    var lyrics: String?
    var mode: String? // Make this optional
    var explicit: Int
    var system_entry_date: String
    var danceability: String
    var energy: String
    var loudness: String
    var speechiness: String
    var instrumentalness: String
    var liveness: String
    var valence: String
    var time_signature: String
    var created_at: String?
    var updated_at: String?
    var ratings: [Rating]? // Make this optional
}



struct Rating: Decodable {
    var id: Int
    var rating: String
    var username: String
    var song_id: String
    var date_rated: String
    var created_at: String?
    var updated_at: String?
}

struct Album: Decodable {
    var album_id: String
    var name: String
    var image_url: String
    // Add other album properties as needed
}

