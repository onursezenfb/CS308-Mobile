//
//  MoodyMix.swift
//  music_tailor
//
//  Created by selin ceydeli on 12/9/23.
//

import SwiftUI

// Define MoodySong and MoodyRecommendedSong structures
struct MoodySong: Decodable {
    var song_id: String
    var name: String
    var album_id: String
    // Include other relevant fields
}

struct MoodyRecommendedSong {
    var song: MoodySong
    var albumImageUrl: String?
    var albumName: String
}

struct MoodyMix: View {
    @EnvironmentObject var userSession: UserSession
    @State private var recommendedSongs: [MoodyRecommendedSong] = []

    var body: some View {
        VStack {
            Text("Your Moody")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Recommendations")
                .font(.title)
                .bold()
                .foregroundColor(.pink)
                .frame(maxWidth: .infinity, alignment: .leading)

            List(recommendedSongs, id: \.song.song_id) { recommendedSong in
                HStack {
                    if let imageUrl = recommendedSong.albumImageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable()
                            case .failure:
                                Image(systemName: "photo").resizable()
                            case .empty:
                                ProgressView()
                            @unknown default:
                                Image(systemName: "photo").resizable()
                            }
                        }
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                    }
                    VStack(alignment: .leading) {
                        Text(recommendedSong.song.name)
                            .font(.headline)
                        Text(recommendedSong.albumName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .onAppear {
            fetchMoodyMixRecommendations()
        }
        .padding()
    }

    private func fetchMoodyMixRecommendations() {
        guard let username = userSession.username, !username.isEmpty else {
            print("Username is empty")
            return
        }

        let urlString = "http://127.0.0.1:8000/api/users/\(username)/moody-recommendations"
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
                typealias SongsResponse = [String: MoodySong]
                let songsResponse = try JSONDecoder().decode(SongsResponse.self, from: data)
                let songs = Array(songsResponse.values) // Convert dictionary values to an array
                DispatchQueue.main.async {
                    self.recommendedSongs = songs.map { MoodyRecommendedSong(song: $0, albumImageUrl: nil, albumName: "") }
                    for song in songs {
                        fetchAlbum(for: song.album_id, song: song)
                    }
                }
            } catch {
                print("Failed to decode songs: \(error)")
            }
        }.resume()
    }

    private func fetchAlbum(for albumID: String, song: MoodySong) {
        guard let url = URL(string: "http://127.0.0.1:8000/api/albums/\(albumID)") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }

            if let album = try? JSONDecoder().decode(Album.self, from: data) {
                DispatchQueue.main.async {
                    if let index = self.recommendedSongs.firstIndex(where: { $0.song.song_id == song.song_id }) {
                        self.recommendedSongs[index].albumImageUrl = album.image_url
                        self.recommendedSongs[index].albumName = album.name
                    } else {
                        self.recommendedSongs.append(MoodyRecommendedSong(song: song, albumImageUrl: album.image_url, albumName: album.name))
                    }
                }
            }
        }.resume()
    }
}
