//
//  EnergyDanceabilityRecommendationView.swift
//  music_tailor
//
//  Created by Şimal on 5.12.2023.
//

import SwiftUI
struct SongsResponse: Decodable {
    var data: [Song]
}


struct EnergyDanceabilityRecommendationView: View {
    @EnvironmentObject var userSession: UserSession
    @State private var recommendedSongs: [RecommendedSong] = []

    var body: some View {
        VStack {
            Text("Your Energic")
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
            fetchEnergyDanceabilityRecommendations()
        }
    }

    private func fetchEnergyDanceabilityRecommendations() {
        guard let username = userSession.username, !username.isEmpty else {
            print("Username is empty")
            return
        }
        let urlString = "http://127.0.0.1:8000/api/users/\(username)/energy-danceability-recommendations"
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
                        let songsResponse = try JSONDecoder().decode(SongsResponse.self, from: data)
                        let songs = songsResponse.data
                        DispatchQueue.main.async {
                            // Initialize recommendedSongs with song data and placeholder for album details
                            self.recommendedSongs = songs.map { RecommendedSong(song: $0, albumImageUrl: nil, albumName: "") }

                            // Fetch album details for each song
                            for song in songs {
                                fetchAlbum(for: song.album_id, song: song)
                            }
                        }
                    } catch {
                        print("Failed to decode songs: \(error)")
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



