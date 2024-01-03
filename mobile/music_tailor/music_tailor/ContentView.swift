import SwiftUI

enum ItemType {
    case song, album, performer
}

// Helper extension to append strings to Data
extension Data {
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var userSession: UserSession
    @State private var selectedTab: Int = 0
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            VStack {
                
                TabView(selection: $selectedTab) {
                    HomeView()
                        .environmentObject(userSession)
                        .tabItem {
                            Image(systemName: "house")
                            Text("Home")
                        }
                        .tag(0)
                    
                    UploadMusicFormView()
                        .tabItem {
                            Image(systemName: "square.and.arrow.up")
                            Text("Upload Music")
                        }
                        .tag(1)
                    
                    PlaylistsView()
                        .tabItem {
                            Image(systemName: "music.note.list")
                            Text("Your Music")
                        }
                        .tag(2)
                    
                    FriendsView()
                        .tabItem {
                            Image(systemName: "person.2")
                            Text("Friends")
                        }
                        .tag(3)
                    
                    ProfileView()
                        .tabItem {
                            Image(systemName: "person.circle")
                            Text("Profile")
                        }
                        .tag(4)
                }
                .accentColor(themeManager.themeColor)
            }
        }
    }
    
    
    struct DetailedSong: Decodable {
        var song_id: String
        var name: String
        var album_id: String
    }
    
    struct SongRating: Decodable {
        var song_ratings_avg_rating: String // Assuming JSON structure is similar
    }
    
    struct SongRatingResponse: Decodable {
        var data: [Rating] // Assuming similar structure as AlbumRatingResponse
    }
    
    struct SimpleAlbum: Decodable {
        var album_id: String
        var name: String
    }
    
    struct SongView: View {
        var userId: String
        var songId: String
        var artistName: String
        var imageUrl: String
        @EnvironmentObject var themeManager: ThemeManager
        @State private var song: DetailedSong?
        @State private var album: SimpleAlbum?
        @State private var averageRating: Double?
        @State private var errorMessage: String?
        @State private var selectedRating: Int?
        @State private var showAlert = false
        @State private var alertTitle = ""
        @State private var alertMessage = ""
        @State private var userLastRating: Double? = nil
        @GestureState private var dragOffset: CGFloat = 0
        
        var body: some View {
            ZStack {
                // Background image
                VStack {
                    if let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: UIScreen.main.bounds.width, height: 400)
                        .ignoresSafeArea()
                    }
                    Spacer()
                }
                
                // Custom scroll content
                VStack {
                    // Spacer to push the content down
                    Spacer().frame(height: 250)
                    
                    // Content container
                    VStack(alignment: .leading, spacing: 0) {
                        HStack{
                            if let name = song?.name {
                                Text(name)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(nil) // Allows unlimited lines
                                    .fixedSize(horizontal: false, vertical: true) // Allows vertical expansion
                                    .frame(maxWidth: .infinity, alignment: .center) // Use the full width
                                    .padding(.horizontal, 10)
                                    .padding(.top, 55)
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(width: UIScreen.main.bounds.width, alignment: .leading)
                                    .padding(.horizontal, 20)
                                    .background(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]), startPoint: .bottom, endPoint: .top))
                                
                                Spacer()
                            }
                            // album's name
                            
                            
                        }
                        
                        Divider()
                            .frame(height: 10)
                            .background(Color.black.opacity(0.7)) // Set divider color to white
                        
                        // album details
                        VStack(alignment: .leading, spacing: 60) {
                            HStack(spacing: 10){
                                
                                
                                Spacer()
                            }
                            .padding(.top, -25)
                            .frame(width: 400, height: 70)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]), startPoint: .top, endPoint: .bottom))
                            
                            VStack (spacing: 40){
                                HStack(spacing: 10){
                                    
                                    
                                    Text("Artist: \(artistName)")
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(nil) // Allows unlimited lines
                                        .fixedSize(horizontal: false, vertical: true) // Allows vertical expansion
                                        .foregroundColor(.white.opacity(0.85)) // Set text color to white
                                        .font(.custom("Optima", size: 28))
                                        .fontWeight(.semibold) // Adjust the weight as needed
                                        .italic()
                                        .padding(.leading, 15)
                                        .padding(.top, -120)
                                    
                                    
                                    Spacer()
                                }
                                
                                HStack(spacing: 10){
                                    
                                    
                                    Text("Album: \(album?.name ?? "Unknown")")
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(nil) // Allows unlimited lines
                                        .fixedSize(horizontal: false, vertical: true) // Allows vertical expansion
                                        .foregroundColor(.white.opacity(0.85)) // Set text color to white
                                        .font(.custom("Optima", size: 28))
                                        .fontWeight(.semibold) // Adjust the weight as needed
                                        .italic()
                                        .padding(.leading, 15)
                                        .padding(.top, -120)
                                    
                                    
                                    Spacer()
                                }
                            }
                            
                            
                            
                            ZStack {
                                Rectangle()
                                    .foregroundColor(Color.black.opacity(0.4)) // Adjust the color and opacity as needed
                                    .frame(height: 195) // Adjust the height of the rectangle
                                VStack(spacing: 10){
                                    HStack(spacing: 5) {
                                        Text("Rate This Song: ")
                                            .foregroundColor(.white.opacity(0.85))
                                            .font(.custom("Optima", size: 24))
                                            .fontWeight(.bold)
                                            .padding(.leading, 15)
                                        
                                        Spacer()
                                        
                                        ForEach(1...5, id: \.self) { index in
                                            Button(action: {
                                                selectedRating = index
                                                submitRating(for: songId, with: index, username: userId)
                                            }) {
                                                Image(systemName: index <= (selectedRating ?? 0) ? "star.fill" : "star")
                                                    .foregroundColor(.yellow)
                                                    .font(.system(size: 30))
                                            }
                                        }
                                        Spacer()
                                        Spacer()
                                        Spacer()
                                        
                                    }
                                    .padding(.leading, 10)
                                    .padding(.vertical, 20)
                                    
                                    HStack(spacing: 5) {
                                        if let averageRating = averageRating {
                                            Text("Average Rating : \(String(format: "%.2f", averageRating))/5")
                                                .foregroundColor(.white.opacity(0.85))
                                                .font(.custom("Optima", size: 24))
                                                .fontWeight(.bold)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.leading, 15)
                                    
                                    HStack(spacing: 5) {
                                        if let userRating = userLastRating {
                                            let intValue = Int(userRating)
                                            Text("Your Last Rating: \(String(intValue))/5")
                                                .foregroundColor(.white.opacity(0.85))
                                                .font(.custom("Optima", size: 24))
                                                .fontWeight(.bold)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.leading, 15)
                                    
                                    
                                }
                                
                            }
                            .frame(height: 50) // Match the height of the RoundedRectangle
                            .padding(.top, -25)
                            
                            
                            
                            Spacer()
                        }
                        .frame(width: 400, height: 500)
                        .padding(.horizontal, 20)
                        .padding(.top, 0)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.5), Color.clear]), startPoint: .top, endPoint: .bottom))
                        .background(LinearGradient(gradient: Gradient(colors: [.pink, .yellow]), startPoint: .topLeading, endPoint: .bottomTrailing)) // Gradient background
                        .cornerRadius(10)
                        
                        Spacer()
                    }
                    .frame(minHeight: 600) // This will make sure the white content area is larger
                }
                .offset(y: dragOffset)
                .animation(.spring(), value: dragOffset)
                .gesture(
                    DragGesture().updating($dragOffset, body: { (value, state, transaction) in
                        if value.translation.height > 55 { // Limit drag to 20 pixels
                            state = 55
                        } else {
                            state = value.translation.height
                        }
                    })
                )
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                fetchSongDetails()
            }
        }
        
        private func fetchAlbumDetails() {
            guard let albumId = song?.album_id else {
                self.errorMessage = "Album ID not found"
                return
            }
            
            guard let url = URL(string: "http://127.0.0.1:8000/api/albums/\(albumId)") else {
                self.errorMessage = "Invalid URL for album details"
                return
            }
            print(url)
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Network error: \(error.localizedDescription)"
                        self.alertTitle = "Network Error"
                        self.alertMessage = error.localizedDescription
                        self.showAlert = true
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Server error"
                        self.alertTitle = "Server Error"
                        self.alertMessage = "Failed to load album details"
                        self.showAlert = true
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Data error"
                        self.alertTitle = "Data Error"
                        self.alertMessage = "Invalid data received from the server"
                        self.showAlert = true
                    }
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(SimpleAlbum.self, from: data)
                    DispatchQueue.main.async {
                        self.album = decodedResponse
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "Decoding error: \(error.localizedDescription)"
                        self.alertTitle = "Decoding Error"
                        self.alertMessage = error.localizedDescription
                        self.showAlert = true
                    }
                }
            }.resume()
        }
        
        
        private func fetchSongDetails() {
            fetchSong()
            fetchUserLastRating(songId: songId, username: userId)
        }
        
        private func fetchSong() {
            guard let url = URL(string: "http://127.0.0.1:8000/api/songs/\(songId)") else {
                self.errorMessage = "Invalid URL for song details"
                return
            }
            print(url)
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Network error: \(error.localizedDescription)"
                        self.alertTitle = "Network Error"
                        self.alertMessage = error.localizedDescription
                        self.showAlert = true
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Server error"
                        self.alertTitle = "Server Error"
                        self.alertMessage = "Failed to load song details"
                        self.showAlert = true
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Data error"
                        self.alertTitle = "Data Error"
                        self.alertMessage = "Invalid data received from the server"
                        self.showAlert = true
                    }
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(DetailedSong.self, from: data)
                    DispatchQueue.main.async {
                        self.song = decodedResponse
                        // Call to fetchAverageRating should be here, after performer is set
                        if let encodedName = self.song?.name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                            self.fetchAverageRating(songName: encodedName)
                            self.fetchAlbumDetails()
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "Decoding error: \(error.localizedDescription)"
                        self.alertTitle = "Decoding Error"
                        self.alertMessage = error.localizedDescription
                        self.showAlert = true
                    }
                }
            }.resume()
        }
        
        private func fetchUserLastRating(songId: String, username: String) {
            guard let url = URL(string: "http://127.0.0.1:8000/api/songrating/song/\(songId)") else {
                print("Invalid URL for song rating")
                return
            }
            print(url)
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Server error or invalid response for song rating")
                    return
                }
                
                guard let data = data else {
                    print("No data received for song rating")
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(RatingResponse.self, from: data)
                    if let lastRating = decodedResponse.data.filter({ $0.username == username }).last {
                        DispatchQueue.main.async {
                            // Here we parse the string to a Double
                            self.userLastRating = Double(lastRating.rating)
                        }
                    }
                } catch {
                    print("Decoding error for song rating: \(error)")
                }
            }.resume()            }
        
        private func fetchAverageRating(songName: String) {
            guard let url = URL(string: "http://127.0.0.1:8000/api/search/song/\(songName)") else {
                print("Invalid URL for average rating")
                self.errorMessage = "Invalid URL for average rating"
                return
            }
            print(url)
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Server error or invalid response for average rating")
                    return
                }
                
                guard let data = data else {
                    print("No data received for average rating")
                    return
                }
                
                do {
                    // Assuming the JSON structure is an array of album ratings
                    let decodedResponse = try JSONDecoder().decode([SongRating].self, from: data)
                    if let firstSongRating = decodedResponse.first {
                        DispatchQueue.main.async {
                            // Here we parse the string to a Double
                            if let averageRating = Double(firstSongRating.song_ratings_avg_rating) {
                                self.averageRating = averageRating
                            } else {
                                print("Failed to parse average rating to a Double")
                            }
                        }
                    }
                } catch {
                    print("Decoding error for average rating: \(error)")
                }
            }.resume()
        }
        
        private func submitRating(for songID: String, with rating: Int, username: String) {
            let endpoint: String = "songrating/"
            
            guard let url = URL(string: "http://127.0.0.1:8000/api/\(endpoint)") else {
                self.errorMessage = "Invalid URL"
                return
            }
            
            print(url)
            
            
            let currentDate = getCurrentFormattedDate()
            
            let ratingData: [String: Any] = [
                "song_id": songID,
                "rating": rating,
                "username": username,
                "date_rated": currentDate // include the date
            ]
            
            print(ratingData)
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: ratingData) else {
                self.errorMessage = "Error encoding data"
                return
            }
            
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = "Network error: \(error.localizedDescription)"
                        self.alertTitle = "Error"
                        self.alertMessage = "Network error: \(error.localizedDescription)"
                        self.showAlert = true
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        if !(200...299).contains(httpResponse.statusCode) {
                            self.errorMessage = "Server error: \(httpResponse.statusCode)"
                            self.alertTitle = "Error"
                            self.alertMessage = "Server error: \(httpResponse.statusCode)"
                        } else {
                            self.alertTitle = "Success"
                            self.alertMessage = "Rating submitted successfully"
                            self.selectedRating = rating // Update the rating state if you need to reflect it in the UI
                            
                            // Refresh the user's last rating and the average rating after submission
                            if let songName = self.song?.name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                                self.fetchAverageRating(songName: songName)
                            }
                            self.fetchUserLastRating(songId: songID, username: username)
                        }
                        self.showAlert = true
                    }
                }
            }.resume()
        }
        private func getCurrentFormattedDate() -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return dateFormatter.string(from: Date())
        }
    }
    
    
    
    //    struct SongView_Previews: PreviewProvider {
    //        static var previews: some View {
    //            SongView(userId: "ozaancelebi2", songId: "0VjIjW4GlUZAMYd2vXMi3b", artistName: "The Weeknd", imageUrl: "https://i.scdn.co/image/ab67616d0000b2738863bc11d2aa12b54f5aeb36" )
    //        }
    //
    //    }
    
    struct DetailedAlbum: Decodable {
        var album_id: String
        var name: String
        var release_date: String
        var total_tracks: Int
        var popularity: Int
        var image_url: String
        var artist_id: String
    }
    
    struct AlbumRating: Decodable {
        var album_ratings_avg_rating: String // Since the JSON has this as a String
    }
    
    struct AlbumRatingResponse: Decodable {
        var data: [Rating] // Assuming similar structure as PerformerRatingResponse
    }
    
    
    
    
    struct AlbumView: View {
        var userId: String
        var albumId: String
        var performerName: String
        @EnvironmentObject var themeManager: ThemeManager
        @State private var album: DetailedAlbum?
        @State private var averageRating: Double?
        @State private var errorMessage: String?
        @State private var selectedRating: Int?
        @State private var showAlert = false
        @State private var alertTitle = ""
        @State private var alertMessage = ""
        @State private var userLastRating: Double? = nil
        @GestureState private var dragOffset: CGFloat = 0
        
        var body: some View {
            ZStack {
                // Background image
                VStack {
                    if let imageUrl = album?.image_url, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: UIScreen.main.bounds.width, height: 400)
                        .ignoresSafeArea()
                    }
                    Spacer()
                }
                
                // Custom scroll content
                VStack {
                    // Spacer to push the content down
                    Spacer().frame(height: 250)
                    
                    // Content container
                    VStack(alignment: .leading, spacing: 0) {
                        // album's name
                        if let name = album?.name {
                            
                            
                            
                            Text(name)
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil) // Allows unlimited lines
                                .fixedSize(horizontal: false, vertical: true) // Allows vertical expansion
                                .frame(maxWidth: .infinity, alignment: .center) // Use the full width
                                .padding(.horizontal, 10)
                                .padding(.top, 55)
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: UIScreen.main.bounds.width, alignment: .leading)
                                .padding(.horizontal, 20)
                                .background(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]), startPoint: .bottom, endPoint: .top))
                            
                        }
                        
                        Divider()
                            .frame(height: 10)
                            .background(Color.black.opacity(0.7)) // Set divider color to white
                        
                        // album details
                        VStack(alignment: .leading, spacing: 60) {
                            HStack(spacing: 10){
                                
                                if let popularity = album?.popularity {
                                    Text("Popularity Score: \(popularity)")
                                        .foregroundColor(.white.opacity(0.85)) // Set text color to white
                                        .font(.custom("Optima", size: 18))
                                        .fontWeight(.semibold) // Adjust the weight as needed
                                        .italic()
                                        .padding(.leading, 15)
                                    
                                }
                                if let total_tracks = album?.total_tracks {
                                    HStack{
                                        Text("Number of tracks:")
                                            .foregroundColor(.white.opacity(0.85)) // Set text color to white
                                            .font(.custom("Optima", size: 18))
                                            .fontWeight(.semibold) // Adjust the weight as needed
                                            .italic()
                                        Text("\(total_tracks)")
                                            .foregroundColor(.white.opacity(0.85)) // Set text color to white
                                            .font(.custom("Optima", size: 18))
                                            .fontWeight(.semibold) // Adjust the weight as needed
                                            .italic()
                                            .padding(.trailing, 15)
                                    }
                                    
                                }
                                Spacer()
                            }
                            .padding(.top, -25)
                            .frame(width: UIScreen.main.bounds.width, height: 70)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]), startPoint: .top, endPoint: .bottom))
                            
                            HStack(spacing: 10){
                                
                                
                                if let release = album?.release_date {
                                    Text("Release date: \(release)")
                                        .foregroundColor(.white.opacity(0.85)) // Set text color to white
                                        .font(.custom("Optima", size: 18))
                                        .fontWeight(.semibold) // Adjust the weight as needed
                                        .italic()
                                        .padding(.leading, 15)
                                }
                                
                                Spacer()
                            }
                            .padding(.top, -92)
                            
                            HStack(spacing: 10){
                                
                                
                                Text("Artist: \(performerName)")
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(nil) // Allows unlimited lines
                                    .fixedSize(horizontal: false, vertical: true) // Allows vertical expansion
                                    .foregroundColor(.white.opacity(0.85)) // Set text color to white
                                    .font(.custom("Optima", size: 28))
                                    .fontWeight(.semibold) // Adjust the weight as needed
                                    .italic()
                                    .padding(.leading, 15)
                                    .padding(.top, -120)
                                
                                
                                Spacer()
                            }
                            
                            ZStack {
                                Rectangle()
                                    .foregroundColor(Color.black.opacity(0.4)) // Adjust the color and opacity as needed
                                    .frame(height: 195) // Adjust the height of the rectangle
                                VStack(spacing: 10){
                                    HStack(spacing: 5) {
                                        Text("Rate This Album: ")
                                            .foregroundColor(.white.opacity(0.85))
                                            .font(.custom("Optima", size: 24))
                                            .fontWeight(.bold)
                                        
                                        Spacer()
                                        
                                        ForEach(1...5, id: \.self) { index in
                                            Button(action: {
                                                selectedRating = index
                                                submitRating(for: albumId, with: index, username: userId)
                                            }) {
                                                Image(systemName: index <= (selectedRating ?? 0) ? "star.fill" : "star")
                                                    .foregroundColor(.yellow)
                                                    .font(.system(size: 30))
                                            }
                                        }
                                        Spacer()
                                        Spacer()
                                        Spacer()
                                        
                                    }
                                    .padding(.leading, 10)
                                    .padding(.vertical, 20)
                                    
                                    HStack(spacing: 5) {
                                        if let averageRating = averageRating {
                                            Text("Average Rating : \(String(format: "%.2f", averageRating))/5")
                                                .foregroundColor(.white.opacity(0.85))
                                                .font(.custom("Optima", size: 24))
                                                .fontWeight(.bold)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.leading, 10)
                                    
                                    HStack(spacing: 5) {
                                        if let userRating = userLastRating {
                                            let intValue = Int(userRating)
                                            Text("Your Last Rating: \(String(intValue))/5")
                                                .foregroundColor(.white.opacity(0.85))
                                                .font(.custom("Optima", size: 24))
                                                .fontWeight(.bold)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.leading, 10)
                                    
                                    
                                }
                                
                            }
                            .frame(height: 50) // Match the height of the RoundedRectangle
                            .padding(.top, -25)
                            
                            
                            
                            Spacer()
                        }
                        .frame(width: UIScreen.main.bounds.width, height: 500)
                        .padding(.horizontal, 20)
                        .padding(.top, 0)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.5), Color.clear]), startPoint: .top, endPoint: .bottom))
                        .background(LinearGradient(gradient: Gradient(colors: [.pink, .yellow]), startPoint: .topLeading, endPoint: .bottomTrailing)) // Gradient background
                        .cornerRadius(10)
                        
                        Spacer()
                    }
                    .frame(minHeight: 600) // This will make sure the white content area is larger
                }
                .offset(y: dragOffset)
                .animation(.spring(), value: dragOffset)
                .gesture(
                    DragGesture().updating($dragOffset, body: { (value, state, transaction) in
                        if value.translation.height > 55 { // Limit drag to 20 pixels
                            state = 55
                        } else {
                            state = value.translation.height
                        }
                    })
                )
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                fetchAlbumDetails()
            }
        }
        
        private func fetchAlbumDetails() {
            fetchAlbum()
            fetchUserLastRating(albumId: albumId, username: userId)
        }
        
        private func fetchAlbum() {
            guard let url = URL(string: "http://127.0.0.1:8000/api/albums/\(albumId)") else {
                self.errorMessage = "Invalid URL for album details"
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Network error: \(error.localizedDescription)"
                        self.alertTitle = "Network Error"
                        self.alertMessage = error.localizedDescription
                        self.showAlert = true
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Server error"
                        self.alertTitle = "Server Error"
                        self.alertMessage = "Failed to load album details"
                        self.showAlert = true
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Data error"
                        self.alertTitle = "Data Error"
                        self.alertMessage = "Invalid data received from the server"
                        self.showAlert = true
                    }
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(DetailedAlbum.self, from: data)
                    DispatchQueue.main.async {
                        self.album = decodedResponse
                        if let encodedName = self.album?.name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                            self.fetchAverageRating(albumName: encodedName)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "Decoding error: \(error.localizedDescription)"
                        self.alertTitle = "Decoding Error"
                        self.alertMessage = error.localizedDescription
                        self.showAlert = true
                    }
                }
            }.resume()
        }
        
        private func fetchUserLastRating(albumId: String, username: String) {
            guard let url = URL(string: "http://127.0.0.1:8000/api/albumrating/album/\(albumId)") else {
                print("Invalid URL for album rating")
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Server error or invalid response for album rating")
                    return
                }
                
                guard let data = data else {
                    print("No data received for album rating")
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(RatingResponse.self, from: data)
                    if let lastRating = decodedResponse.data.filter({ $0.username == username }).last {
                        DispatchQueue.main.async {
                            // Here we parse the string to a Double
                            self.userLastRating = Double(lastRating.rating)
                        }
                    }
                } catch {
                    print("Decoding error for album rating: \(error)")
                }
            }.resume()
        }
        
        private func fetchAverageRating(albumName: String) {
            guard let url = URL(string: "http://127.0.0.1:8000/api/search/album/\(albumName)") else {
                print("Invalid URL for average rating")
                self.errorMessage = "Invalid URL for average rating"
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Server error or invalid response for average rating")
                    return
                }
                
                guard let data = data else {
                    print("No data received for average rating")
                    return
                }
                
                do {
                    // Assuming the JSON structure is an array of album ratings
                    let decodedResponse = try JSONDecoder().decode([AlbumRating].self, from: data)
                    if let firstAlbumRating = decodedResponse.first {
                        DispatchQueue.main.async {
                            // Here we parse the string to a Double
                            if let averageRating = Double(firstAlbumRating.album_ratings_avg_rating) {
                                self.averageRating = averageRating
                            } else {
                                print("Failed to parse average rating to a Double")
                            }
                        }
                    }
                } catch {
                    print("Decoding error for average rating: \(error)")
                }
            }.resume()
        }
        
        func fetchPerformerDetails(artistId: String) {
            guard let url = URL(string: "http://127.0.0.1:8000/api/performers/\(artistId)") else {
                print("Invalid URL")
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Server error or invalid response")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(Performer.self, from: data)
                    DispatchQueue.main.async {
                        print("Performer name: \(decodedResponse.name)")
                        // Handle the fetched data as needed
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
            }.resume()
        }
        
        
        
        private func submitRating(for albumID: String, with rating: Int, username: String) {
            let endpoint: String = "albumrating/"
            
            guard let url = URL(string: "http://127.0.0.1:8000/api/\(endpoint)") else {
                self.errorMessage = "Invalid URL"
                return
            }
            
            let currentDate = getCurrentFormattedDate()
            
            let ratingData: [String: Any] = [
                "album_id": albumID,
                "rating": rating,
                "username": username,
                "date_rated": currentDate // include the date
            ]
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: ratingData) else {
                self.errorMessage = "Error encoding data"
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = "Network error: \(error.localizedDescription)"
                        self.alertTitle = "Error"
                        self.alertMessage = "Network error: \(error.localizedDescription)"
                        self.showAlert = true
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        if !(200...299).contains(httpResponse.statusCode) {
                            self.errorMessage = "Server error: \(httpResponse.statusCode)"
                            self.alertTitle = "Error"
                            self.alertMessage = "Server error: \(httpResponse.statusCode)"
                        } else {
                            self.alertTitle = "Success"
                            self.alertMessage = "Rating submitted successfully"
                            self.selectedRating = rating // Update the rating state if you need to reflect it in the UI
                            
                            // Refresh the user's last rating and the average rating after submission
                            if let albumName = self.album?.name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                                self.fetchAverageRating(albumName: albumName)
                            }
                            self.fetchUserLastRating(albumId: albumID, username: username)
                        }
                        self.showAlert = true
                    }
                }
            }.resume()
        }
        
        private func getCurrentFormattedDate() -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Adjust the format to match your backend expectation
            return dateFormatter.string(from: Date())
        }
    }
    
    //    struct AlbumView_Previews: PreviewProvider {
    //            static var previews: some View {
    //                AlbumView(userId: "ozaancelebi2", albumId: "03Mx6yaV7k4bsEmcTH8J49", performerName: "Ismim Var Bro" )
    //            }
    //
    //        }
    
    
    
    
    struct DetailedPerformer: Decodable {
        var artist_id: String
        var name: String
        var genre: String?
        var popularity: Int?
        var image_url: String
    }
    
    struct PerformerRating: Decodable {
        var performer_ratings_avg_rating: String // Since the JSON has this as a String
    }
    
    struct RatingResponse: Decodable {
        var data: [Rating]
    }
    
    struct Rating: Decodable {
        var id: Int
        var rating: String
        var username: String
        var artist_id: String?
        var date_rated: String
    }
    
    struct PerformerView: View {
        var userId: String
        var artistId: String
        @EnvironmentObject var themeManager: ThemeManager
        @State private var performer: DetailedPerformer?
        @State private var averageRating: Double?
        @GestureState private var dragOffset: CGFloat = 0
        @State private var errorMessage: String?
        @State private var selectedRating: Int?
        @State private var showAlert = false
        @State private var alertTitle = ""
        @State private var alertMessage = ""
        @State private var userLastRating: Double? = nil
        
        
        var body: some View {
            ZStack {
                // Background image
                VStack {
                    if let imageUrl = performer?.image_url, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: UIScreen.main.bounds.width, height: 400)
                        .ignoresSafeArea()
                    }
                    Spacer()
                }
                
                // Custom scroll content
                VStack {
                    // Spacer to push the content down
                    Spacer().frame(height: 250)
                    
                    // Content container
                    VStack(alignment: .leading, spacing: 0) {
                        // Performer's name
                        if let name = performer?.name {
                            Text(name)
                                .padding(.horizontal, 10)
                                .padding(.top, 55)
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: UIScreen.main.bounds.width, alignment: .leading)
                                .padding(.horizontal, 20)
                                .background(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]), startPoint: .bottom, endPoint: .top))
                            
                        }
                        
                        Divider()
                            .frame(height: 10)
                            .background(Color.black.opacity(0.7)) // Set divider color to white
                        
                        // Performer details
                        VStack(alignment: .leading, spacing: 60) {
                            HStack(spacing: 10){
                                
                                if let popularity = performer?.popularity {
                                    Text("Popularity Score: \(popularity)  |")
                                        .foregroundColor(.white.opacity(0.85)) // Set text color to white
                                        .font(.custom("Optima", size: 18))
                                        .fontWeight(.semibold) // Adjust the weight as needed
                                        .italic()
                                        .padding(.leading, 15)
                                    
                                }
                                if let genre = performer?.genre {
                                    HStack{
                                        Text("Genres:")
                                            .foregroundColor(.white.opacity(0.85)) // Set text color to white
                                            .font(.custom("Optima", size: 18))
                                            .fontWeight(.semibold) // Adjust the weight as needed
                                            .italic()
                                        Text("\(genre)")
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(nil) // Allows unlimited lines
                                            .fixedSize(horizontal: false, vertical: true) // Allows vertical expansion
                                            .foregroundColor(.white.opacity(0.85)) // Set text color to white
                                            .font(.custom("Optima", size: 18))
                                            .fontWeight(.semibold) // Adjust the weight as needed
                                            .italic()
                                            .padding(.trailing, 15)
                                    }
                                    
                                }
                                Spacer()
                            }
                            .padding(.top, -25)
                            .frame(width: UIScreen.main.bounds.width, height: 70)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]), startPoint: .top, endPoint: .bottom))
                            
                            ZStack {
                                Rectangle()
                                    .foregroundColor(Color.black.opacity(0.4)) // Adjust the color and opacity as needed
                                    .frame(height: 195) // Adjust the height of the rectangle
                                VStack(spacing: 10){
                                    HStack(spacing: 5) {
                                        Text("Rate This Performer: ")
                                            .foregroundColor(.white.opacity(0.85))
                                            .font(.custom("Optima", size: 24))
                                            .fontWeight(.bold)
                                        
                                        Spacer()
                                        
                                        ForEach(1...5, id: \.self) { index in
                                            Button(action: {
                                                selectedRating = index
                                                submitRating(for: artistId, with: index, username: userId)
                                            }) {
                                                Image(systemName: index <= (selectedRating ?? 0) ? "star.fill" : "star")
                                                    .foregroundColor(.yellow)
                                                    .font(.system(size: 30))
                                            }
                                        }
                                        Spacer()
                                        Spacer()
                                        Spacer()
                                        
                                    }
                                    .padding(.leading, 10)
                                    .padding(.vertical, 20)
                                    
                                    HStack(spacing: 5) {
                                        if let averageRating = averageRating {
                                            Text("Average Rating : \(String(format: "%.2f", averageRating))/5")
                                                .foregroundColor(.white.opacity(0.85))
                                                .font(.custom("Optima", size: 24))
                                                .fontWeight(.bold)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.leading, 10)
                                    
                                    HStack(spacing: 5) {
                                        if let userRating = userLastRating {
                                            let intValue = Int(userRating)
                                            Text("Your Last Rating: \(String(intValue))/5")
                                                .foregroundColor(.white.opacity(0.85))
                                                .font(.custom("Optima", size: 24))
                                                .fontWeight(.bold)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.leading, 10)
                                    
                                    
                                }
                                
                            }
                            .frame(height: 50) // Match the height of the RoundedRectangle
                            
                            
                            
                            Spacer()
                        }
                        .frame(width: UIScreen.main.bounds.width, height: 500)
                        .padding(.horizontal, 20)
                        .padding(.top, 0)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.5), Color.clear]), startPoint: .top, endPoint: .bottom))
                        .background(LinearGradient(gradient: Gradient(colors: [.pink, .yellow]), startPoint: .topLeading, endPoint: .bottomTrailing)) // Gradient background
                        .cornerRadius(10)
                        
                        Spacer()
                    }
                    .frame(minHeight: 600) // This will make sure the white content area is larger
                }
                .offset(y: dragOffset)
                .animation(.spring(), value: dragOffset)
                .gesture(
                    DragGesture().updating($dragOffset, body: { (value, state, transaction) in
                        if value.translation.height > 55 { // Limit drag to 20 pixels
                            state = 55
                        } else {
                            state = value.translation.height
                        }
                    })
                )
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onAppear {
                fetchPerformerDetails()
            }
        }
        private func fetchPerformerDetails() {
            fetchPerformer()
            fetchUserLastRating(artistId: artistId, username: userId)
        }
        
        private func fetchPerformer() {
            guard let url = URL(string: "http://127.0.0.1:8000/api/performers/\(artistId)") else {
                self.errorMessage = "Invalid URL for performer details"
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Network error: \(error.localizedDescription)"
                        self.alertTitle = "Network Error"
                        self.alertMessage = error.localizedDescription
                        self.showAlert = true
                    }
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Server error"
                        self.alertTitle = "Server Error"
                        self.alertMessage = "Failed to load performer details"
                        self.showAlert = true
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Data error"
                        self.alertTitle = "Data Error"
                        self.alertMessage = "Invalid data received from the server"
                        self.showAlert = true
                    }
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(DetailedPerformer.self, from: data)
                    DispatchQueue.main.async {
                        
                        self.performer = decodedResponse
                        // Call to fetchAverageRating should be here, after performer is set
                        if let encodedName = self.performer?.name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                            self.fetchAverageRating(performerName: encodedName)
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "Decoding error: \(error.localizedDescription)"
                        self.alertTitle = "Decoding Error"
                        self.alertMessage = error.localizedDescription
                        self.showAlert = true
                    }
                }
            }.resume()
        }
        
        private func fetchUserLastRating(artistId: String, username: String) {
            guard let url = URL(string: "http://127.0.0.1:8000/api/performerrating/performer/\(artistId)") else {
                print("Invalid URL for performer rating")
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Server error or invalid response for performer rating")
                    return
                }
                
                guard let data = data else {
                    print("No data received for performer rating")
                    return
                }
                
                do {
                    let decodedResponse = try JSONDecoder().decode(RatingResponse.self, from: data)
                    if let lastRating = decodedResponse.data.filter({ $0.username == username }).last {
                        DispatchQueue.main.async {
                            // Here we parse the string to a Double
                            self.userLastRating = Double(lastRating.rating)
                        }
                    }
                } catch {
                    print("Decoding error for performer rating: \(error)")
                }
            }.resume()
        }
        
        private func fetchAverageRating(performerName: String) {
            guard let url = URL(string: "http://127.0.0.1:8000/api/search/performer/\(performerName)") else {
                print("Invalid URL for average rating")
                self.errorMessage = "Invalid URL for average rating"
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Server error or invalid response for average rating")
                    return
                }
                
                guard let data = data else {
                    print("No data received for average rating")
                    return
                }
                
                do {
                    // Assuming the JSON structure is an array of performer ratings
                    let decodedResponse = try JSONDecoder().decode([PerformerRating].self, from: data)
                    if let firstPerformerRating = decodedResponse.first {
                        DispatchQueue.main.async {
                            // Here we parse the string to a Double
                            if let averageRating = Double(firstPerformerRating.performer_ratings_avg_rating) {
                                self.averageRating = averageRating
                            } else {
                                print("Failed to parse average rating to a Double")
                            }
                        }
                    }
                } catch {
                    print("Decoding error for average rating: \(error)")
                }
            }.resume()
        }
        
        private func getCurrentFormattedDate() -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Adjust the format to match your backend expectation
            return dateFormatter.string(from: Date())
        }
        
        
        private func submitRating(for itemID: String, with rating: Int, username: String) {
            let endpoint: String = "performerrating/"
            
            guard let url = URL(string: "http://127.0.0.1:8000/api/\(endpoint)") else {
                self.errorMessage = "Invalid URL"
                return
            }
            
            let currentDate = getCurrentFormattedDate()
            
            let ratingData: [String: Any] = [
                "artist_id": itemID,
                "rating": rating,
                "username": username,
                "date_rated": currentDate // include the date
            ]
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: ratingData) else {
                self.errorMessage = "Error encoding data"
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.errorMessage = "Network error: \(error.localizedDescription)"
                        self.alertTitle = "Error"
                        self.alertMessage = "Network error: \(error.localizedDescription)"
                        self.showAlert = true
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse {
                        if !(200...299).contains(httpResponse.statusCode) {
                            self.errorMessage = "Server error: \(httpResponse.statusCode)"
                            self.alertTitle = "Error"
                            self.alertMessage = "Server error: \(httpResponse.statusCode)"
                        } else {
                            self.alertTitle = "Success"
                            self.alertMessage = "Rating submitted successfully"
                            self.selectedRating = rating // Update the rating state if you need to reflect it in the UI
                            
                            // Refresh the user's last rating and the average rating after submission
                            if let performerName = self.performer?.name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                                self.fetchAverageRating(performerName: performerName)
                            }
                            self.fetchUserLastRating(artistId: itemID, username: username)
                        }
                        self.showAlert = true
                    }
                }
            }.resume()
        }
    }
    
    
    
    
    
    
    
    
    
    
    struct HomeView: View {
        @EnvironmentObject var userSession: UserSession
        @EnvironmentObject var themeManager: ThemeManager
        @State private var searchText: String = ""
        @State private var currentFilter: Filter = .songs // Default filter is "All"
        @State private var showingSongSheet = false
        @State private var showingAlbumSheet = false
        @State private var showingPerformerSheet = false
        @State private var currentItemID: String?
        @State private var currentItemType: ItemType?
        @State private var currentItemIdentifier: String?
        @State private var currentItemImageUrl: String?
        @State private var albums: [Album] = []
        @State private var songs: [Song] = []
        @State private var performers: [Performer] = []
        @State private var tempalbums: [Album] = []
        @State private var tempsongs: [Song] = []
        @State private var tempperformers: [Performer] = []
        
        enum Filter: String, CaseIterable {
            
            case songs = "Songs"
            case albums = "Albums"
            case performers = "Performers"
        }
        
        var body: some View {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                VStack(alignment: .leading, spacing: 16) {
                    ZStack(alignment: .leading) {
                        Image(systemName: "magnifyingglass")
                            .padding(.leading, 8)
                            .foregroundColor(.gray)
                        TextField("Search", text: $searchText)
                            .padding(.leading, 30)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .frame(maxWidth: .infinity)
                            .autocapitalization(.none)
                            .onChange(of: searchText, perform: { _ in
                                fetchSearchResults()
                            })
                    }
                    
                    
                    
                    
                    // Filter buttons
                    HStack {
                        ForEach(Filter.allCases, id: \.self) { filter in
                            Button(action: {
                                currentFilter = filter
                                fetchSearchResults()
                            }) {
                                Text(filter.rawValue)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(currentFilter == filter ? themeManager.themeColor : Color.gray.opacity(0.5))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    // Display filtered results based on the current filter
                    List {
                        ForEach(filteredItems(), id: \.id) { item in
                            HStack {
                                
                                AsyncImage(url: URL(string: item.imageUrl)) { image in
                                    image
                                        .resizable()
                                        .frame(width: 50, height: 50) // Adjust the image size as needed
                                } placeholder: {
                                    ProgressView()
                                }
                                .cornerRadius(8) // Add corner radius to the image
                                
                                
                                Spacer().frame(width: 15)
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                    if item.itemType == .song {
                                        HStack {
                                            if item.isExplicit ?? false {
                                                Text("🅴") // Display circled "E" for explicit songs
                                                    .font(.system(size: 20)) // Adjust the size as needed
                                                    .foregroundColor(.red) // Adjust the color as needed
                                            }
                                            Text("\(item.identifier)")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    } else {
                                        Text("\(item.identifier)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                Button(action: {
                                    currentItemID = item.id
                                    currentItemType = item.itemType  // Set the item type
                                    currentItemIdentifier = item.identifier
                                    currentItemImageUrl = item.imageUrl
                                    
                                    switch currentItemType {
                                    case .performer:
                                        showingPerformerSheet = true
                                    case .album:
                                        showingAlbumSheet = true
                                    case .song:
                                        showingSongSheet = true
                                    default:
                                        break // In case currentItemType is nil
                                    }
                                }) {
                                    Image(systemName: "star.fill") // Or any other icon or text you prefer
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                    }
                    .sheet(isPresented: $showingSongSheet) {
                        if let itemID = currentItemID {
                            let userID = userSession.username
                            let artistName = String(currentItemIdentifier?.dropFirst(6) ?? "no name")
                            let image = currentItemImageUrl
                            
                            SongView(userId: userID!, songId: itemID, artistName: artistName, imageUrl: image ?? "")
                        }
                    }
                    .sheet(isPresented: $showingPerformerSheet) {
                        if let itemID = currentItemID, currentItemType == .performer {
                            let userID = userSession.username
                            PerformerView(userId: userID ?? "userIDNotFound", artistId: itemID)
                        }
                    }
                    .sheet(isPresented: $showingAlbumSheet) {
                        if let itemID = currentItemID, currentItemType == .album {
                            let userID = userSession.username
                            let artistName = String(currentItemIdentifier?.dropFirst(6) ?? "no name")
                            
                            AlbumView(userId: userID!, albumId: itemID, performerName: artistName)
                        }
                    }
                    
                }
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(0)
            }
            .onAppear {
                fetchAllPerformers()
                fetchAllAlbums()
            }
            
        }
        private func fetchAllPerformers() {
            guard let url = URL(string: "http://127.0.0.1:8000/api/performers") else { return }
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    DispatchQueue.main.async {
                        do {
                            let fetchedPerformers = try JSONDecoder().decode([Performer].self, from: data)
                            self.performers = fetchedPerformers
                        } catch {
                            print("Error fetching performers: \(error)")
                        }
                    }
                }
            }
            task.resume()
        }
        
        private func fetchAllAlbums() {
            guard let url = URL(string: "http://127.0.0.1:8000/api/albums") else { return }
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    DispatchQueue.main.async {
                        do {
                            let fetchedAlbums = try JSONDecoder().decode([Album].self, from: data)
                            self.albums = fetchedAlbums
                        } catch {
                            print("Error fetching albums: \(error)")
                        }
                    }
                }
            }
            task.resume()
        }
        
        @State private var combinedResults: [SearchResult] = []
        
        private func fetchSearchResults() {
            // Base URL for the search API
            let baseURL = "http://127.0.0.1:8000/api/search"
            
            // Construct the endpoint URL based on the current filter and searchText
            var endpointURL: URL {
                switch currentFilter {
                case .songs:
                    return URL(string: "\(baseURL)/song/\(searchText)")!
                case .albums:
                    return URL(string: "\(baseURL)/album/\(searchText)")!
                case .performers:
                    return URL(string: "\(baseURL)/performer/\(searchText)")!
                }
            }
            
            let task = URLSession.shared.dataTask(with: endpointURL) { data, response, error in
                if let error = error {
                    print("Error fetching data: \(error)")
                    return
                }
                if let data = data {
                    DispatchQueue.main.async {
                        switch currentFilter {
                        case .performers:
                            do {
                                self.tempperformers = try JSONDecoder().decode([Performer].self, from: data)
                            } catch {
                                print("Error decoding performers JSON: \(error)")
                            }
                        case .songs:
                            do {
                                self.songs = try JSONDecoder().decode([Song].self, from: data)
                            } catch {
                                print("Error decoding songs JSON: \(error)")
                                if let dataString = String(data: data, encoding: .utf8) {
                                    print("Received song data: \(dataString)")
                                }
                            }
                            
                        case .albums:
                            do {
                                self.tempalbums = try JSONDecoder().decode([Album].self, from: data)
                            } catch {
                                print("Error decoding albums JSON: \(error)")
                            }
                        }
                    }
                }
            }
            
            // Start URLSession task
            task.resume()
        }
        
        private func filteredItems() -> [FilterItem] {
            var items: [FilterItem] = []
            print("Number of performers: \(performers.count)")
            switch currentFilter {
                case .songs:
                    items = songs.map { song in
                        let album = albums.first(where: { $0.album_id == song.album_id })
                        let performer = album.flatMap { alb in
                            performers.first(where: { $0.artist_id == alb.artist_id })
                        }

                        let isExplicit = song.explicit == 1  // Check if the song is explicit

                        // Check child mode and exclude explicit songs if child mode is enabled
                        let shouldIncludeSong = userSession.childMode ? !isExplicit : true

                        return shouldIncludeSong ? FilterItem(
                            id: song.song_id,
                            name: song.name,
                            identifier: "Song - \(performer?.name ?? "Unknown Performer")",
                            imageUrl: album?.image_url ?? "default_image_url",
                            itemType: .song,
                            isExplicit: isExplicit
                        ) : nil

                    }
                    .compactMap { $0 } // Remove nil entries
                
                case .albums:
                    items = tempalbums.map { album in
                        let performer = performers.first(where: { $0.artist_id == album.artist_id })
                        
                        return FilterItem(
                            id: album.album_id,
                            name: album.name,
                            identifier: "Album - \(performer?.name ?? "Unknown Performer")",
                            imageUrl: album.image_url,
                            itemType: .album
                        )
                    }
                case .performers:
                    items = tempperformers.map { performer in
                        FilterItem(id: performer.artist_id, name: performer.name, identifier: "Performer", imageUrl: performer.image_url,itemType: .performer)
                    }
                default:
                    break
            }
            
            return items
        }
    }
    
    
    struct FilterItem: Identifiable {
        var id: String
        var name: String
        var identifier: String
        var imageUrl: String
        var performerName: String?
        var itemType: ItemType
        var isExplicit: Bool?  // Include the explicit property

        init(id: String, name: String, identifier: String, imageUrl: String, performerName: String? = nil, itemType: ItemType, isExplicit: Bool? = nil) {
            self.id = id
            self.name = name
            self.identifier = identifier
            self.imageUrl = imageUrl
            self.performerName = performerName
            self.itemType = itemType
            self.isExplicit = isExplicit
        }
    }

    
    struct AlbumSearchResult: Decodable {
        var album_id: String
        var name: String
        var image_url: String
        var artist_id: String
        // Add other album-specific fields...
    }
    
    struct SongSearchResult: Decodable {
        var song_id: String
        var name: String
        var album_id: String
        var firstPerformerId: String?
        
        private enum CodingKeys: String, CodingKey {
            case song_id, name, album_id, performers
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            song_id = try container.decode(String.self, forKey: .song_id)
            name = try container.decode(String.self, forKey: .name)
            album_id = try container.decode(String.self, forKey: .album_id)
            
            // Decode the performers array and extract the first element
            let performerIds = try container.decode([String].self, forKey: .performers)
            firstPerformerId = performerIds.first
        }
    }
    
    
    struct PerformerSearchResult: Decodable {
        var artist_id: String
        var name: String
        var image_url: String
        // Add other performer-specific fields...
    }
    
    
    
    struct SearchResult: Decodable {
        var search_type: String
        var album: AlbumSearchResult?
        var song: SongSearchResult?
        var performer: PerformerSearchResult?
        
        enum CodingKeys: String, CodingKey {
            case search_type
            case album = "album_id"
            case song = "song_id"
            case performer = "artist_id"
        }
    }
    
    
    
    
    struct Song: Identifiable, Decodable {
            var song_id: String
            var name: String
            var album_id: String
            var explicit: Int  // Update the type to Int
            
            // ... other properties ...

            var id: String { song_id }

            private enum CodingKeys: String, CodingKey {
                case song_id, name, album_id, explicit
                // ... other coding keys ...
            }
        }


    
    struct Album: Identifiable, Decodable {
        var album_id: String
        var name: String
        var image_url: String
        var artist_id: String
        // Add other properties as needed
        var id: String { album_id }
    }
    
    struct Performer: Identifiable, Decodable {
        var artist_id: String
        var name: String
        var image_url: String
        // Add other properties as needed
        var id: String { artist_id }
    }
    
    
    
    
    struct UploadMusicFormView: View {
        @Environment(\.presentationMode) var presentationMode
        @EnvironmentObject var themeManager: ThemeManager
        @State private var spotifyLink: String = ""
        @State private var showAlert = false
        @State private var alertMessage = ""
        
        var body: some View {
            NavigationView {
                ZStack {
                    Color.white.ignoresSafeArea()
                    
                    VStack {
                        Spacer().frame(height: 30)
                        
                        Text("Upload Music Into")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        Text("Music Tailor")
                            .font(Font.system(size: 36, design: .rounded))
                            .bold()
                            .foregroundColor(themeManager.themeColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        Text("Enter Spotify Link Below")
                            .font(Font.system(size: 20, design: .rounded))
                            .bold()
                            .foregroundColor(themeManager.themeColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        Form {
                            Section(header: Text("Spotify Song Link").foregroundColor(.black)) {
                                TextField("Enter Spotify Link", text: $spotifyLink)
                            }
                            
                            Section {
                                Button("Submit") {
                                    uploadSpotifyLink()
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(themeManager.themeColor)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Upload Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                        }
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Upload Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                                // Clear the text field when the alert is dismissed
                                spotifyLink = ""
                            })
                        }
                    }
                    .background(themeManager.themeColor.opacity(0.15))
                }
            }
        }
        
        func uploadSpotifyLink() {
            let urlString = "http://127.0.0.1:8000/api/spotify/import"
            guard let url = URL(string: urlString) else {
                alertMessage = "Invalid URL"
                showAlert = true
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: String] = ["spotifyLink": spotifyLink]
            guard let jsonData = try? JSONSerialization.data(withJSONObject: body, options: []) else {
                alertMessage = "Failed to serialize JSON"
                showAlert = true
                return
            }
            request.httpBody = jsonData
            print("Uploading Spotify Link: \(spotifyLink)")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        alertMessage = "Error: \(error.localizedDescription)"
                        showAlert = true
                        return
                    }
                    guard let data = data,
                          let httpResponse = response as? HTTPURLResponse else {
                        alertMessage = "No data received"
                        showAlert = true
                        return
                    }
                    
                    if let responseDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String],
                       let message = responseDict["message"] {
                        alertMessage = message
                    } else {
                        alertMessage = "Invalid response format"
                    }
                    
                    if httpResponse.statusCode == 200 {
                        // Handle successful upload
                        alertMessage = "Successfully uploaded!"
                    } else if httpResponse.statusCode == 409 {
                        // Handle duplicate entry
                        alertMessage = "Song already exists."
                    } else if httpResponse.statusCode == 400 {
                        // Handle invalid link
                        alertMessage = "Invalid Spotify link."
                    } else {
                        // Handle other errors
                        alertMessage = "An error occurred."
                    }
                    
                    showAlert = true
                }
            }.resume()
        }
    }
    
    
    
    
    struct PlaylistsView: View {
        @EnvironmentObject var themeManager: ThemeManager
        // Define a two-column grid layout
        private var gridItems = [GridItem(.flexible()), GridItem(.flexible())]
        
        var body: some View {
            NavigationView {
                ScrollView {
                    // Title HStack
                    VStack {
                        HStack {
                            Text("Your")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.black)
                            
                            Text("Music")
                                .font(Font.system(size: 36, design: .rounded))
                                .bold()
                                .foregroundColor(themeManager.themeColor)
                        }
                        .padding(.bottom, 5) // Add some top padding to the title
                        HStack {
                            Text("Recommendations &")
                                .font(.custom("Arial-BoldMT", size: 25))
                                .bold()
                                .foregroundColor(.clear)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color.pink, Color.orange]), startPoint: .leading, endPoint: .trailing)
                                )
                                .mask(
                                    Text("Recommendations &")
                                        .font(.custom("Arial-BoldMT", size: 25))
                                        .bold()
                                )
                            
                            Text("Analysis")
                                .font(.custom("Arial-BoldMT", size: 25))
                                .bold()
                                .foregroundColor(.clear)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .leading, endPoint: .trailing)
                                )
                                .mask(
                                    Text("Analysis")
                                        .font(.custom("Arial-BoldMT", size: 25))
                                        .bold()
                                )
                        }
                    }
                    .padding(.top, 15) // Add some top padding to the title
                    
                    // Buttons grid
                    LazyVGrid(columns: gridItems, spacing: 20) {
                        NavigationLink(destination: RecommendationView()) {
                            RecommendationButtonLabel("Your Genre Taste")
                        }
                        NavigationLink(destination: EnergyDanceabilityRecommendationView()) {
                            RecommendationButtonLabel("Energy & Dance Vibes")
                        }
                        NavigationLink(destination: MoodyMix()) {
                            RecommendationButtonLabel("Moody Mix For You")
                        }
                        NavigationLink(destination: EnergeticMix()) {
                            RecommendationButtonLabel("Energetic Mix For You")
                        }
                        NavigationLink(destination: RatingsLineChartView()) {
                            AnalysisButtonLabel("Your Daily Average Ratings")
                        }
                        NavigationLink(destination: TopAlbumsAnalysisView()) {
                            AnalysisButtonLabel("Your Top Albums by Era")
                        }
                        NavigationLink(destination: FavoriteSongsAnalysisView()) {
                            AnalysisButtonLabel("Your Favorite Songs")
                        }
                        NavigationLink(destination: ArtistAnalysisView()) {
                            AnalysisButtonLabel("Compare Artist by Ratings")
                        }
                    }
                    .padding() // Add padding around the grid
                }
                .navigationTitle("") // Hide the default navigation bar title
                .navigationBarHidden(true) // Hide the navigation bar to use the custom title
                .background(Color.gray.opacity(0.2).edgesIgnoringSafeArea(.all)) // Background color
            }
        }
        
        // Custom view for the button label
        private func RecommendationButtonLabel(_ title: String) -> some View {
            Text(title)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.center) // Ensure the text is centered
                .padding() // Add padding inside the button
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 120) // Set a minimum height for buttons
                .background(LinearGradient(gradient: Gradient(colors: [.pink, .yellow]), startPoint: .topLeading, endPoint: .bottomTrailing)) // Gradient background
                .cornerRadius(15) // Rounded corners
                .shadow(radius: 5) // Add a shadow for a 3D effect
        }
        
        // Custom view for the button label
        private func AnalysisButtonLabel(_ title: String) -> some View {
            Text(title)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.center) // Ensure the text is centered
                .padding() // Add padding inside the button
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 120) // Set a minimum height for buttons
                .background(LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing)) // Gradient background
                .cornerRadius(15) // Rounded corners
                .shadow(radius: 5) // Add a shadow for a 3D effect
        }
    }
    
    
    
    
    struct FriendsView: View {
        @EnvironmentObject var themeManager: ThemeManager
        
        var body: some View {
            NavigationView {
                ZStack {
                    // Set the entire screen's background to pink
                    Color.gray.opacity(0.2).edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 10) {
                        HStack {
                            Text("Your")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.black)
                            
                            Text("Friends")
                                .font(Font.system(size: 36, design: .rounded))
                                .bold()
                                .foregroundColor(themeManager.themeColor)
                        }
                        .padding(.bottom, 20)
                        
                        NavigationLink(destination: AddFriendView()) {
                            Text("Follow Friends")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .background(themeGradient)
                                .cornerRadius(10)
                        }
                        .padding(.bottom, 10)
                        
                        NavigationLink(destination: RequestView()) {
                            Text("See Requests")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .background(themeGradient)
                                .cornerRadius(10)
                        }
                        .padding(.bottom, 10)
                        
                        NavigationLink(destination: ManageView()) {
                            Text("Manage Your Friends")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .background(themeGradient)
                                .cornerRadius(10)
                        }
                        .padding(.bottom, 10)
                                              
                        Spacer()
                    }
                    .padding() // Adjust padding if needed
                }
                .navigationBarHidden(true) // Optionally hide the navigation bar if you want
            }
        }
        
        var themeGradient: LinearGradient {
            LinearGradient(gradient: Gradient(colors: [themeManager.themeColor, themeManager.themeColor.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        
    }
    
    
    
    
    struct ProfileView: View {
            @EnvironmentObject var themeManager: ThemeManager
            @EnvironmentObject var userSession: UserSession
            @State private var profileImage: UIImage? = nil
            @State private var selectedImage: UIImage?
            @State private var showingSettings = false
            @State private var email: String = ""
            @State private var dateOfBirth: Date = Date()
            @State private var language: String = ""
            @State private var subscription: String = ""
            @State private var rateLimit: String = ""
            @State private var theme: String = ""
            @State private var showAlert = false
            @State private var alertMessage = ""
            
            private let dateFormatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                return formatter
            }()
            
            var body: some View {
                NavigationView {
                    VStack {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("Your Personal")
                                    .font(.largeTitle)
                                    .bold()
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                Spacer()

                                Button(action: {
                                    userSession.fetchAndUpdateUserData()
                                }) {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.title)
                                        .foregroundColor(themeManager.themeColor)
                                }
                                .padding(.trailing, 20)
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(themeManager.themeColor.opacity(0.7))
                                        .frame(width: 40, height: 40)
                                    Button(action: {
                                        showingSettings.toggle()
                                    }) {
                                        Image(systemName: "gear")
                                            .font(.title)
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(.trailing, 20)
                                .sheet(isPresented: $showingSettings) {
                                    SettingsView(profileImage: $profileImage) // Show the settings view when the button is tapped
                                }
                            }
                            
                            
                            HStack {
                                Text("Music Tailor")
                                    .font(Font.system(size: 32, design: .rounded))
                                    .bold()
                                    .foregroundColor(themeManager.themeColor)
                                    .padding(.leading, 20)
                                VStack {
                                    Text("Profile")
                                        .font(.custom("Arial-BoldMT", size: 30))
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                }
                                Spacer()
                            }
                        }
                        .padding(.bottom, 10)
                        .background(themeManager.themeColor.opacity(0.15))
                        
                        NavigationLink(destination: PublicProfileView()) {
                            Text("Go to Your Public Profile!")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(themeManager.themeColor)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        if let image = selectedImage ?? profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .shadow(radius: 7)
                        } else {
                            Image(systemName: "person")
                                .padding(.top, 50)
                                .font(.system(size: 120))
                                .foregroundColor(themeManager.themeColor.opacity(0.15))
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .shadow(radius: 7)
                                .padding(.top, 30)
                        }
                        
                        // User's name and username
                        Text("\(userSession.name ?? "") \(userSession.surname ?? "")")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                            .padding(.bottom, 1)
                        
                        Text("@\(userSession.username ?? "")")
                            .foregroundColor(themeManager.themeColor)
                        
                        
                        // Description text
                        //                    Text("This is a brief description about yourself. You can customize it based on your preferences.")
                        //                        .font(.custom("Avenir Next", size: 18))
                        //                        .italic()
                        //                        .padding(.horizontal, 20)
                        //                        .multilineTextAlignment(.center)
                        //
                        
                        ScrollView {
                            // Editable user information fields
                            Group {
                                TextField("Email", text: $email)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, -10)
                                DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, -10)
                                TextField("Language", text: $language)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, -10)
                                HStack {
                                    Text("Subscription:")
                                        .bold()
                                    Text(userSession.subscription)
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, -10)
                                HStack {
                                    Text("Rate Limit:")
                                        .bold()
                                    Text(userSession.rateLimit)
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, -10)
                                .padding(.bottom, 10)
                            }
                            .padding()
                            
                            //Spacer()
                            
                            // Update Button
                            Button(action: updateUserInformation) {
                                Text("Update")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(themeManager.themeColor)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            
                            
                            .alert(isPresented: $showAlert) {
                                Alert(
                                    title: Text("Update Successful"),
                                    message: Text(alertMessage),
                                    dismissButton: .default(Text("OK"))
                                )
                            }
                            .padding(.bottom, 20)
                            .onAppear(perform: fetchUserData)
                            
                            Spacer()
                        }
                    }
                    .padding(.bottom, 20)
                    .onAppear(perform: fetchUserData)
                    .onAppear {
                        userSession.fetchAndUpdateUserData() // Fetch and update user data when the view appears
                        }
                    .onChange(of: userSession.theme) { _ in
                        fetchUserData() // Fetch data when the theme changes
                    }
                }
            }
            
        
        
        private func fetchUserData() {
            guard let url = URL(string: "http://127.0.0.1:8000/api/users/\(userSession.username ?? "")") else {
                print("Invalid URL")
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error fetching user data: \(error)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Error: Invalid response from server")
                    return
                }
                
                guard let data = data else {
                    print("Error: No data received")
                    return
                }
                
                do {
                    if let fetchedData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                            self.updateUserData(with: fetchedData)
                        }
                    }
                } catch {
                    print("Error: Could not decode JSON")
                }
                
                do {
                    let fetchedUser = try JSONDecoder().decode(User.self, from: data)
                    DispatchQueue.main.async {
                        self.updateUserImage(with: fetchedUser)
                    }
                } catch {
                    print("Error: Could not decode user data")
                }
            }
            
            task.resume()
        }
        
        private func loadProfileImage(from urlString: String?) {
            guard let urlString = urlString, let url = URL(string: urlString) else { return }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error fetching image: \(error)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    print("Loading profile image: Error: Invalid response from server")
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    print("Error: No data or invalid data received")
                    return
                }
                
                DispatchQueue.main.async {
                    self.profileImage = image
                }
            }.resume()
        }
        
        private func updateUserData(with data: [String: Any]) {
            DispatchQueue.main.async {
                self.email = data["email"] as? String ?? ""
                self.language = data["language"] as? String ?? ""
                self.subscription = data["subscription"] as? String ?? ""
                self.rateLimit = data["rate_limit"] as? String ?? ""
                self.theme = data["theme"] as? String ?? ""
                
                if let dobString = data["date_of_birth"] as? String, let dob = self.dateFormatter.date(from: dobString) {
                    self.dateOfBirth = dob
                }
                
                if let imageURL = data["image"] as? String {
                    self.loadProfileImage(from: imageURL)
                }
            }
        }
        
        private func updateUserImage(with user: User) {
            DispatchQueue.main.async {
                if let image = user.image {
                    self.loadProfileImage(from: image)
                }
            }
        }
        
        private func updateUserInformation() {
            guard let url = URL(string: "http://127.0.0.1:8000/api/users/\(userSession.username ?? "")") else {
                print("Invalid URL")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let updatedUser = User(
                username: userSession.username,
                email: email,
                email_verified_at: nil, // Handle this depending on your backend requirements
                name: userSession.name,
                surname: userSession.surname,
                password: nil, // Handle password updates separately for security reasons
                date_of_birth: dateFormatter.string(from: dateOfBirth),
                language: language,
                subscription: subscription,
                rate_limit: rateLimit,
                theme: theme
            )
            
            do {
                let jsonData = try JSONEncoder().encode(updatedUser)
                request.httpBody = jsonData
                
                let task = URLSession.shared.dataTask(with: request) { [self] data, response, error in
                    if let error = error {
                        print("Error updating user data: \(error)")
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        print("Error: Invalid response from server")
                        return
                    }
                    
                    if httpResponse.statusCode == 200 {
                        // Update is successful
                        DispatchQueue.main.async {
                            self.alertMessage = "Your personal information is successfully updated!"
                            self.showAlert = true
                            self.fetchUserData()
                        }
                    } else {
                        print("Error: Update failed with status code \(httpResponse.statusCode)")
                        // Handle different status codes or server responses as needed
                    }
                }
                task.resume()
            } catch {
                print("Error encoding user data")
            }
        }
        
        
    }
    
    // User struct for encoding
    struct User: Codable {
        var username: String?
        var email: String?
        var email_verified_at: String?
        var name: String?
        var surname: String?
        var password: String?
        var date_of_birth: String
        var language: String
        var subscription: String
        var rate_limit: String
        var theme: String?
        var image: String?
    }
    
    
    
    
    struct SettingsView: View {
        @EnvironmentObject var themeManager: ThemeManager
        @EnvironmentObject var userSession: UserSession
        @State private var navigateToLogin = false
        @State private var showingImagePicker = false
        @Binding var profileImage: UIImage?
        @State private var navigateToPremium = false
        @State private var showingChangeThemeView = false
        @State private var childModeEnabled = false
        
        
        var body: some View {
            NavigationView {
                ZStack {
                    // Pink ombre circles in each corner
                    Circle()
                        .fill(currentThemeGradient)
                        .frame(width: 300, height: 300)
                        .position(x: 0, y: 0) // Top left corner
                    
                    Circle()
                        .fill(currentThemeGradient)
                        .frame(width: 300, height: 300)
                        .position(x: UIScreen.main.bounds.width, y: 0) // Top right corner
                    
                    Circle()
                        .fill(currentThemeGradient)
                        .frame(width: 300, height: 300)
                        .position(x: 0, y: UIScreen.main.bounds.height) // Bottom left corner
                    
                    Circle()
                        .fill(currentThemeGradient)
                        .frame(width: 300, height: 300)
                        .position(x: UIScreen.main.bounds.width, y: UIScreen.main.bounds.height) // Bottom right corner
                    // Content of your view
                    
                    VStack(spacing: 20) {
                        VStack(alignment: .center, spacing: 0) {
                            Spacer().frame(height: 125)
                            HStack{
                                Text("Tailor")
                                    .font(Font.system(size: 36, design: .rounded))
                                    .bold()
                                    .foregroundColor(themeManager.themeColor)
                                Text("Your")
                                    .font(.largeTitle)
                                    .bold()
                                    .foregroundColor(.black)
                            }
                            HStack{
                                Spacer()
                                Text("Experience")
                                    .font(.largeTitle)
                                    .bold()
                                    .foregroundColor(.black)
                                Spacer()
                                
                            }
                            
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        
                        // Hidden NavigationLink that listens to navigateToPremium
                        NavigationLink(
                            destination: PremiumView(),
                            isActive: $navigateToPremium
                        ) {
                            EmptyView()
                        }
                        
                        // Button that sets navigateToPremium to true
                        Button(action: {
                            navigateToPremium = true
                        }) {
                            Text("See Subscription Plans!")
                                .foregroundColor(.white)
                                .padding()
                                .background(themeManager.themeColor)
                                .cornerRadius(10)
                        }
                        .padding(.top, 20)
                        
                        Button(action: {
                            // Show the image picker when the button is pressed
                            showingImagePicker.toggle()
                        }) {
                            Text("Change Profile Picture")
                                .foregroundColor(.white)
                                .padding()
                                .background(themeManager.themeColor)
                                .cornerRadius(10)
                        }
                        .padding(.top, 20)
                        .sheet(isPresented: $showingImagePicker) {
                            ImagePicker(image: $profileImage, parentView: self)
                        }
                        
                        Button("Change Theme") {
                            showingChangeThemeView = true
                        }
                        .buttonStyle(SettingsButtonStyle())
                        .sheet(isPresented: $showingChangeThemeView) {
                            ChangeThemeView()
                        }
                        
                        Button("Limit Your Activity") {
                            // Action for Limit Your Activity
                        }
                        
                        .buttonStyle(SettingsButtonStyle())
                        
                        HStack (spacing: -35){
                            Spacer(minLength: 350)


                            Text("Child Mode")
                                .foregroundColor(.white)
                                .padding()
                                .background(themeManager.themeColor)
                                .cornerRadius(10)
                                .frame(width: 200)
                                                        
                            Toggle("", isOn: $userSession.childMode)
                                .toggleStyle(SwitchToggleStyle(tint: themeManager.themeColor))
                                .onChange(of: userSession.childMode) { newValue in
                                    userSession.setChildMode(newValue)
                                }
                            Spacer(minLength: 400)

                        }

                        
                        
                        NavigationLink(
                            destination: LoginView()
                                .navigationBarBackButtonHidden(true)
                                .navigationBarHidden(true),
                            isActive: $navigateToLogin
                        ) {
                            EmptyView()
                        }
                        .hidden() // Use .hidden() instead of opacity and background
                        
                        Button(action: {
                            // Set the flag to true to trigger the navigation
                            navigateToLogin = true
                        }) {
                            Text("Log Out")
                                .foregroundColor(.white)
                                .padding()
                                .background(themeManager.themeColor)
                                .cornerRadius(10)
                        }
                        .padding(.top, 20)
                        
                        
                        Spacer()
                    }
                    .background(themeManager.themeColor.opacity(0.1))
                }
                
            }
            .navigationBarTitle(Text(""), displayMode: .inline) // Add this line to hide the default navigation title
            
            var currentThemeGradient: LinearGradient {
                LinearGradient(gradient: Gradient(colors: [themeManager.themeColor, themeManager.themeColor.opacity(0)]), startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        }
        
        
        func uploadImageURL(_ imageURL: URL, completion: @escaping (Bool) -> Void) {
            guard let uploadUrl = URL(string: "http://127.0.0.1:8000/api/users/\(userSession.username ?? "")") else {
                print("Invalid upload URL")
                completion(false)
                return
            }
            
            var request = URLRequest(url: uploadUrl)
            request.httpMethod = "PUT"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let jsonBody: [String: String] = ["image": imageURL.absoluteString]
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
                request.httpBody = jsonData
                
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("Error uploading image URL: \(error)")
                        completion(false)
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                        print("Error: Invalid response from server")
                        completion(false)
                        return
                    }
                    
                    completion(true)
                }
                
                task.resume()
            } catch {
                print("Error: Could not create JSON data")
                completion(false)
            }
        }
        
        
        
    }
    
    struct SettingsButtonStyle: ButtonStyle {
        @EnvironmentObject var themeManager: ThemeManager
        func makeBody(configuration: Self.Configuration) -> some View {
            
            configuration.label
            
                .foregroundColor(.white)
            
                .padding()
            
                .background(themeManager.themeColor)
            
                .cornerRadius(8)
            
                .frame(maxWidth: .infinity)
            
                .padding(.horizontal)
            
        }
        
    }
    
    struct ImagePicker: UIViewControllerRepresentable {
        @Binding var image: UIImage?
        var parentView: SettingsView  // Add a reference to SettingsView
        
        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            return picker
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
        
        // Coordinator class
        class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
            let parent: ImagePicker
            
            init(_ parent: ImagePicker) {
                self.parent = parent
            }
            
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
                // Dismiss the picker first
                picker.dismiss(animated: true)
                
                // Handle the selected image
                if let uiImage = info[.originalImage] as? UIImage {
                    parent.image = uiImage
                }
                
                // Attempt to get the URL of the selected image
                if let imageUrl = info[.imageURL] as? URL {
                    // Call the uploadImageURL method from SettingsView
                    parent.parentView.uploadImageURL(imageUrl) { success in
                        DispatchQueue.main.async {
                            if success {
                                print("Image URL successfully uploaded")
                                // Optionally, update the UI or state based on successful upload
                            } else {
                                print("Failed to upload image URL")
                                // Handle the failure case
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserSession.mock)
            .environmentObject(ThemeManager()) // Add ThemeManager as an environment object
    }
}
