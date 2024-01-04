import SwiftUI


struct CardView: View {
    var title: String
    var names: [String]
    var themeColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .frame(height: 150)  // Adjusted height
                .foregroundColor(.white)
                .overlay(
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)  // Adjusted font size
                            .foregroundColor(.black)
                            .padding(.bottom, 4)
                        
                        RoundedRectangle(cornerRadius: 12)
                            .frame(height: 110)  // Adjusted height
                            .foregroundColor(themeColor.opacity(0.5))
                            .overlay(
                                VStack(alignment: .leading, spacing: 4) {
                                    ForEach(names, id: \.self) { name in
                                        Text(name)
                                            .font(.subheadline)  // Adjusted font size
                                    }
                                }
                                    .padding()
                            )
                    }
                    .padding()
                )            
        }
    }
}

struct WrappedView: View {
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var themeManager: ThemeManager
    @State private var top5Songs: [Song] = []
    @State private var songOfYear: Song?
    @State private var top5Albums: [Album] = []
    @State private var top5Genres: [String] = []

    var body: some View {
        VStack {

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeManager.themeColor.ignoresSafeArea())
        .onAppear {
            getTop5Songs()
            getSongOfYear()
            getTop5Albums()
            getTop5Genres()
        }
        .overlay(
            VStack {
                // Display Top 5 Songs
                if !top5Songs.isEmpty {
                    CardView(title: "Top 5 Songs", names: top5Songs.map(\.name), themeColor: themeManager.themeColor)
                }

                // Display Song of the Year
                if let songOfYear = songOfYear {
                    CardView(title: "Song of the Year", names: [songOfYear.name], themeColor: themeManager.themeColor)
                }

                // Display Top 5 Albums
                if !top5Albums.isEmpty {
                    CardView(title: "Top 5 Albums", names: top5Albums.map(\.name), themeColor: themeManager.themeColor)
                }

                // Display Top 5 Genres
                if !top5Genres.isEmpty {
                    CardView(title: "Top 5 Genres", names: top5Genres, themeColor: themeManager.themeColor)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        )
    }

    func getTop5Songs() {
        // Ensure the username is not nil
        guard let username = userSession.username else {
            print("Username is nil")
            return
        }

        // Construct the URL using optional binding to unwrap the username
        if let url = URL(string: "http://127.0.0.1:8000/api/users/\(username)/top5-songs") {
            print(url)
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode([Song].self, from: data)
                        DispatchQueue.main.async {
                            self.top5Songs = decodedData
                            print("Top 5 Songs:", self.top5Songs)
                        }
                    } catch {
                        print("Error decoding top 5 songs:", error)
                    }
                } else if let error = error {
                    print("Error fetching top 5 songs:", error)
                }
            }.resume()
        } else {
            print("Invalid URL")
        }
    }



    func getSongOfYear() {
        // Ensure the username is not nil
        guard let username = userSession.username else {
            print("Username is nil")
            return
        }

        // Construct the URL using optional binding to unwrap the username
        if let url = URL(string: "http://127.0.0.1:8000/api/users/\(username)/song-of-year") {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode([Song].self, from: data)
                        DispatchQueue.main.async {
                            self.songOfYear = decodedData.first
                        }
                    } catch {
                        print("Error decoding song of the year:", error)
                    }
                } else if let error = error {
                    print("Error fetching song of the year:", error)
                }
            }.resume()
        } else {
            print("Invalid URL")
        }
    }

    func getTop5Albums() {
        // Ensure the username is not nil
        guard let username = userSession.username else {
            print("Username is nil")
            return
        }

        // Construct the URL using optional binding to unwrap the username
        if let url = URL(string: "http://127.0.0.1:8000/api/users/\(username)/top5-albums") {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode([Album].self, from: data)
                        DispatchQueue.main.async {
                            self.top5Albums = decodedData
                        }
                    } catch {
                        print("Error decoding top 5 albums:", error)
                    }
                } else if let error = error {
                    print("Error fetching top 5 albums:", error)
                }
            }.resume()
        } else {
            print("Invalid URL")
        }
    }
    func getTop5Genres() {
        // Ensure the username is not nil
        guard let username = userSession.username else {
            print("Username is nil")
            return
        }

        // Construct the URL using optional binding to unwrap the username
        if let url = URL(string: "http://127.0.0.1:8000/api/users/\(username)/top5-genres") {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode([String].self, from: data)
                        DispatchQueue.main.async {
                            self.top5Genres = decodedData
                            print("Top 5 Genres:", self.top5Genres)
                        }
                    } catch {
                        print("Error decoding top 5 genres:", error)
                    }
                } else if let error = error {
                    print("Error fetching top 5 genres:", error)
                }
            }.resume()
        } else {
            print("Invalid URL")
        }
    }


}

struct WrappedView_Previews: PreviewProvider {
    static var previews: some View {
        WrappedView()
            .environmentObject(UserSession.mock)
            .environmentObject(ThemeManager()) // Add ThemeManager as an environment object
    }
}
