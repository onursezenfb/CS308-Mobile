//
//  EnergeticMix.swift
//  music_tailor
//
//  Created by selin ceydeli on 12/9/23.
//

import SwiftUI

// Define EnergeticSong and EnergeticRecommendedSong structures
struct EnergeticSong: Decodable {
    var song_id: String
    var name: String
    var album_id: String
    // Include other relevant fields
}

struct EnergeticRecommendedSong {
    var song: EnergeticSong
    var albumImageUrl: String?
    var albumName: String
}

struct EnergeticMix: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userSession: UserSession
    @State private var recommendedSongs: [EnergeticRecommendedSong] = []

    var body: some View {
        VStack {
            Text("Your Energetic")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.black)
                .frame(width: 300, alignment: .leading)
            Text("Recommendations")
                .font(Font.system(size: 30, design: .rounded))
                .bold()
                .foregroundColor(themeManager.themeColor)
                .frame(width: 300, alignment: .leading)

            List(recommendedSongs, id: \.song.song_id) { recommendedSong in
                HStack {
                    if let imageUrl = recommendedSong.albumImageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable()
                            case .failure:
                                Image(systemName: "photo")
                            default:
                                Image(systemName: "photo")
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
            fetchEnergeticMixRecommendations()
        }
    }

    private func fetchEnergeticMixRecommendations() {
        guard let username = userSession.username, !username.isEmpty else {
            print("Username is empty")
            return
        }

        let urlString = "http://127.0.0.1:8000/api/users/\(username)/positive-recommendations"
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

            do {
                typealias SongsResponse = [String: EnergeticSong]
                let songsResponse = try JSONDecoder().decode(SongsResponse.self, from: data)
                let songs = Array(songsResponse.values) // Convert dictionary values to an array
                DispatchQueue.main.async {
                    self.recommendedSongs = songs.map { EnergeticRecommendedSong(song: $0, albumImageUrl: nil, albumName: "") }
                    for song in songs {
                        fetchAlbum(for: song.album_id, song: song)
                    }
                }
            } catch {
                print("Failed to decode songs: \(error)")
            }
        }.resume()
    }

    private func fetchAlbum(for albumID: String, song: EnergeticSong) {
        guard let url = URL(string: "http://127.0.0.1:8000/api/albums/\(albumID)") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }

            if let album = try? JSONDecoder().decode(Album.self, from: data) {
                DispatchQueue.main.async {
                    if let index = self.recommendedSongs.firstIndex(where: { $0.song.song_id == song.song_id }) {
                        self.recommendedSongs[index].albumImageUrl = album.image_url
                        self.recommendedSongs[index].albumName = album.name
                    } else {
                        self.recommendedSongs.append(EnergeticRecommendedSong(song: song, albumImageUrl: album.image_url, albumName: album.name))
                    }
                }
            }
        }.resume()
    }
}
