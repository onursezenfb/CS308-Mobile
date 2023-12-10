//
//  FavoriteSongsAnalysisView.swift
//  music_tailor
//
//  Created by selin ceydeli on 12/10/23.
//

import SwiftUI
import Charts

struct SongRating: Identifiable, Codable {
    let id: String
    let name: String
    let averageRatingString: String

    enum CodingKeys: String, CodingKey {
        case id = "song_id"
        case name
        case averageRatingString = "average_rating"
    }

    // Computed property to convert the average rating from String to Double
    var averageRating: Double? {
        return Double(averageRatingString)
    }
    
    // Shorten the song name for display on the x-axis
    var shortName: String {
        return String(name.prefix(10)) // Display only the first 10 characters
    }
}

struct FavoriteSongsAnalysisView: View {
    @EnvironmentObject var userSession: UserSession
    @State private var selectedMonths: String = "1" // Default to 1 month
    @State private var favoriteSongs: [SongRating] = []
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    let monthOptions = ["1", "3", "6", "12"]
    let barColors: [Color] = [.red, .green, .blue, .orange, .purple, .pink, .yellow, .cyan, .mint]
    
    var body: some View {
        VStack {
            // Chart Title
            VStack {
                Text("Your Favorite 5 Songs")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.black)
                
                Text("in Last Months")
                    .font(Font.system(size: 36, design: .rounded))
                    .bold()
                    .foregroundColor(.pink)
            }
            VStack(alignment: .leading) {
                Text("Select Months")
                    .font(.headline)
                    .foregroundColor(.pink)
                    .padding([.top, .leading]) // Add padding to top and leading edges
                
                // Picker to select the months
                Picker("Select Months", selection: $selectedMonths) {
                    ForEach(monthOptions, id: \.self) {
                        Text("\($0) months")
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
            }
            .padding(.horizontal) // Apply horizontal padding to the entire VStack if needed
            
                
            Chart(favoriteSongs) { song in
                if let averageRating = song.averageRating {
                    BarMark(
                        x: .value("Song Name", song.shortName),
                        y: .value("Average Rating", averageRating)
                    )
                    .foregroundStyle(barColors.randomElement() ?? .blue)
                    .annotation(position: .top) {
                        Text("\(averageRating, specifier: "%.2f")")
                            .font(.caption)
                    }
                }
            }
            .frame(height: 300)
            // Load data when the selected months change
            .onChange(of: selectedMonths) { newMonths in
                loadFavoriteSongs(for: newMonths)
            }
        }
        .onAppear {
            loadFavoriteSongs(for: selectedMonths)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func loadFavoriteSongs(for months: String) {
        guard let username = userSession.username, !username.isEmpty else {
            self.alertMessage = "Username is not set"
            self.showAlert = true
            return
        }

        guard let url = URL(string: "http://127.0.0.1:8000/api/songrating/user/\(username)/top-10-in/\(months)/months") else {
            self.alertMessage = "Invalid URL"
            self.showAlert = true
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.alertMessage = "Network error: \(error.localizedDescription)"
                    self.showAlert = true
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    self.alertMessage = "Error fetching data: Server returned an error"
                    self.showAlert = true
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.alertMessage = "Error fetching data: Data was nil"
                    self.showAlert = true
                }
                return
            }

            do {
                let decodedSongs = try JSONDecoder().decode([SongRating].self, from: data)
                DispatchQueue.main.async {
                    self.favoriteSongs = decodedSongs
                }
            } catch {
                DispatchQueue.main.async {
                    self.alertMessage = "Error parsing data: \(error.localizedDescription)"
                    self.showAlert = true
                }
            }
        }
        task.resume()
    }
}

struct FavoriteSongsAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteSongsAnalysisView().environmentObject(UserSession())
    }
}
