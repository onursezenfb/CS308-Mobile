import SwiftUI

enum ItemType {
    case song, album, performer
}
struct ContentView: View {
    @EnvironmentObject var userSession: UserSession
    @State private var selectedTab: Int = 0

    
    
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
                    .accentColor(.pink)
                }
            }
    }
    
    struct DetailedSong: Decodable {
        var song_id: String
        var name: String
        var album_id: String
        var duration: Int?
        var tempo: String?
        var key: String?
        var lyrics: String?
        var mode: String?
        var explicit: Int?
        var danceability: String?
        var energy: String?
        var loudness: String?
        var speechiness: String?
        var instrumentalness: String?
        var liveness: String?
        var valence: String?
        var time_signature: String?
        
        // Add other properties as needed
    }
    
    
    struct DetailedPerformer: Decodable {
        var artist_id: String
        var name: String
        var genre: String?  // Changed to String
        var popularity: Int?
        var image_url: String
    }

    struct PerformerView: View {
        var artistId: String
        @State private var performer: DetailedPerformer?
        
        var body: some View {
            Group {
                VStack(alignment: .leading, spacing: 10) {
                    AsyncImage(url: URL(string: performer!.image_url)) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 100, height: 100)
                    
                    Text(performer!.name)
                        .font(.title)
                    
                    if let popularity = performer?.popularity {
                        Text("Popularity: \(popularity)")
                    }
                    
                    if let genre = performer?.genre {
                        Text("Genres: \(genre)") // Use genre directly as it is now a String
                    }
                    
                }
                
            }
            .onAppear {
                fetchPerformerDetails()
            }
        }
        
        private func fetchPerformerDetails() {
            guard let url = URL(string: "http://127.0.0.1:8000/api/performers/\(artistId)") else {
                print("Invalid URL")
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error fetching data: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("Server error: \(response.debugDescription)")
                    return
                }
                
                if let data = data {
                    do {
                        var decodedResponse = try JSONDecoder().decode(DetailedPerformer.self, from: data)
                        
                        // Convert the genre string to an array
                        if let genreString = decodedResponse.genre,
                           let data = genreString.data(using: .utf8),
                           let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [String] {
                            decodedResponse.genre = jsonArray.joined(separator: ", ")
                        }
                        
                        DispatchQueue.main.async {
                            self.performer = decodedResponse
                        }
                    } catch {
                        print("Decoding error: \(error.localizedDescription)")
                        print(String(data: data, encoding: .utf8) ?? "No data string")
                    }
                }
            }
        }
    }

/*
    struct SongView: View {
        var songId: String
        @State private var song: DetailedSong?

        var body: some View {
            Group {
                if let song = song {
                    let album = albums.first(where: { $0.album_id == song.album_id })
                    let performer = album.flatMap { alb in
                        performers.first(where: { $0.artist_id == alb.artist_id })
                    }
             
                    VStack(alignment: .leading, spacing: 10) {
                        AsyncImage(url: URL(string: album.albumImageUrl)) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)
                        
                        Text(song.name)
                            .font(.title)
                        // ... other song details ...
                    }
                } else {
                    Text("Loading...")
                }
            }
            .onAppear {
                fetchSongDetails()
            }
        }

        private func fetchSongDetails() {
            guard let url = URL(string: "http://127.0.0.1:8000/api/songs/\(songId)") else { return }
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    if let decodedResponse = try? JSONDecoder().decode(Song.self, from: data) {
                        DispatchQueue.main.async {
                            self.song = decodedResponse
                        }
                    }
                }
            }.resume()
        }
    }

*/
    
    

    struct RatingSheetView: View {
        @Environment(\.presentationMode) var presentationMode
        var itemID: String
        var itemType: ItemType
        @State private var selectedRating: Int?
        @State private var errorMessage: String?
        @EnvironmentObject var userSession: UserSession


        
        private var ratingTitle: String {
                switch itemType {
                case .song:
                    return "Rate this Song"
                case .album:
                    return "Rate this Album"
                case .performer:
                    return "Rate this Performer"
                }
        }
        func getCurrentFormattedDate() -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Adjust the format to match your backend expectation
            return dateFormatter.string(from: Date())
        }
        
        
        var body: some View {
            NavigationView {
                VStack {
                    Text(ratingTitle)
                    // Display rating options (0 to 5)
                    HStack{
                        ForEach(0..<6) { rating in
                                Button("\(rating)") {
                                    if let username = userSession.username {
                                        submitRating(for: itemID, with: rating, username: username, itemType: itemType)
                                    }
                                }
                            .padding()  // Style as needed
                        }
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                    }
                }
                .navigationTitle("Rate")
                .navigationBarItems(trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                })
            }
        }
        
        func submitRating(for itemID: String, with rating: Int, username: String, itemType: ItemType) {
            let endpoint: String
            let key: String

            switch itemType {
            case .song:
                endpoint = "songrating"
                key = "song_id"
            case .album:
                endpoint = "albumrating"
                key = "album_id"
            case .performer:
                endpoint = "performerrating"
                key = "artist_id"
            }

            guard let url = URL(string: "http://127.0.0.1:8000/api/\(endpoint)") else {
                self.errorMessage = "Invalid URL"
                return
            }

            let currentDate = getCurrentFormattedDate()
            
            let ratingData: [String: Any] = [
                key: itemID,
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
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Network error: \(error.localizedDescription)"
                    }
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                    DispatchQueue.main.async {
                        self.errorMessage = "Server error: \(httpResponse.statusCode)"
                    }
                    return
                }

                DispatchQueue.main.async {
                    // Handle successful submission
                }
            }.resume()
        }

    }


    
    
    struct HomeView: View {
        @State private var searchText: String = ""
        @State private var currentFilter: Filter = .all // Default filter is "All"
        @State private var showingSongSheet = false
        @State private var showingAlbumSheet = false
        @State private var showingPerformerSheet = false
        @State private var currentItemID: String?
        @State private var currentItemType: ItemType?
        @State private var albums: [Album] = []
        @State private var songs: [Song] = []
        @State private var performers: [Performer] = []
        @State private var tempalbums: [Album] = []
        @State private var tempsongs: [Song] = []
        @State private var tempperformers: [Performer] = []

        enum Filter: String, CaseIterable {
            case all = "All"
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
                                    .background(currentFilter == filter ? Color.pink : Color.gray.opacity(0.5))
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
                                    Text("\(item.identifier)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Button(action: {
                                    currentItemID = item.id
                                    currentItemType = item.itemType  // Set the item type
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
                        if let itemType = currentItemType, let itemID = currentItemID {
                            
                        }
                    }
                    .sheet(isPresented: $showingPerformerSheet) {
                        if let itemType = currentItemType, let itemID = currentItemID {
                            PerformerView(artistId: currentItemID ?? "000")
                        }
                    }
                    .sheet(isPresented: $showingAlbumSheet) {
                        if let itemType = currentItemType, let itemID = currentItemID {
                            
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
                case .all:
                    return URL(string: "\(baseURL)/\(searchText)")!
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
                        case .all:
                            do {
                                combinedResults = try JSONDecoder().decode([SearchResult].self, from: data)
                            } catch {
                                print("Error decoding combined JSON: \(error)")
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
            
            switch currentFilter {
                case .songs:
                    items = songs.map { song in
                        let album = albums.first(where: { $0.album_id == song.album_id })
                        let performer = album.flatMap { alb in
                            performers.first(where: { $0.artist_id == alb.artist_id })
                        }
                        
                        return FilterItem(
                            id: song.song_id,
                            name: song.name,
                            identifier: "Song - \(performer?.name ?? "Unknown Performer")",
                            imageUrl: album?.image_url ?? "default_image_url",
                            itemType: .song
                        )
                    }
                    
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
        var performerName: String? // Optional, to store the performer's name
        var itemType: ItemType
        
        init(id: String, name: String, identifier: String, imageUrl: String, performerName: String? = nil,itemType: ItemType) {
            self.id = id
            self.name = name
            self.identifier = identifier
            self.imageUrl = imageUrl
            self.performerName = performerName
            self.itemType = itemType
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
//        var image_url: String
        // Add other properties as needed
        var id: String { song_id }
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
                            .foregroundColor(.pink)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        Text("Enter Spotify Link Below")
                            .font(Font.system(size: 20, design: .rounded))
                            .bold()
                            .foregroundColor(.pink)
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
                                .background(Color.pink)
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
                    .background(Color.pink.opacity(0.15))
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
                                .foregroundColor(.pink)
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
                                .foregroundColor(.pink)
                        }
                        .padding(.bottom, 20)
                        
                        NavigationLink(destination: AddFriendView()) {
                            Text("Add Friends")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .background(LinearGradient(gradient: Gradient(colors: [.pink, .red]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .cornerRadius(10)
                        }
                        .padding(.bottom, 10)
                        
                        Button(action: {
                            // Action for "Manage Your Friends" button
                        }) {
                            Text("Manage Your Friends")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .background(LinearGradient(gradient: Gradient(colors: [.pink, .red]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .cornerRadius(10)
                        }
                        
                        Spacer()
                    }
                    .padding() // Adjust padding if needed
                }
                .navigationBarHidden(true) // Optionally hide the navigation bar if you want
            }
        }
    }

    
    
    
    struct ProfileView: View {
        @EnvironmentObject var userSession: UserSession
        @State private var profileImage: UIImage? = nil
        @State private var selectedImage: UIImage?
        @State private var showingSettings = false
        @State private var email: String = ""
        @State private var dateOfBirth: Date = Date()
        @State private var language: String = ""
        @State private var subscription: String = ""
        @State private var rateLimit: String = ""
        
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
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color.pink.opacity(0.7))
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
                                .foregroundColor(.pink)
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
                    .background(Color.pink.opacity(0.15))
                   
                    
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
                            .foregroundColor(Color.pink.opacity(0.15))
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
                        .foregroundColor(.pink)
                    
                    
                    // Description text
//                    Text("This is a brief description about yourself. You can customize it based on your preferences.")
//                        .font(.custom("Avenir Next", size: 18))
//                        .italic()
//                        .padding(.horizontal, 20)
//                        .multilineTextAlignment(.center)
//                    


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
                        TextField("Subscription", text: $subscription)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 20)
                            .padding(.vertical, -10)
                        TextField("Rate Limit", text: $rateLimit)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 20)
                            .padding(.vertical, -10)
                    }
                    .padding()

                    Spacer()
                    
                    // Update Button
                    Button(action: updateUserInformation) {
                        Text("Update")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.pink)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.bottom, 20)
                .onAppear(perform: fetchUserData)
                
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
            }

            task.resume()
        }

        private func updateUserData(with data: [String: Any]) {
            DispatchQueue.main.async {
                self.email = data["email"] as? String ?? ""
                self.language = data["language"] as? String ?? ""
                self.subscription = data["subscription"] as? String ?? ""
                self.rateLimit = data["rate_limit"] as? String ?? ""

                if let dobString = data["date_of_birth"] as? String, let dob = self.dateFormatter.date(from: dobString) {
                    self.dateOfBirth = dob
                }
            }
        }

        
        private func updateUserInformation() {
            guard let url = URL(string: "http://127.0.0.1:8000/api/users/update") else {
                print("Invalid URL")
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let updatedUser = User(
                username: userSession.username,
                email: email,
                email_verified_at: nil, // You may need to handle this depending on your backend requirements
                name: userSession.name,
                surname: userSession.surname,
                password: nil, // You may need to handle password updates separately for security reasons
                date_of_birth: dateFormatter.string(from: dateOfBirth),
                language: language,
                subscription: subscription,
                rate_limit: rateLimit
            )
            
            do {
                let jsonData = try JSONEncoder().encode(updatedUser)
                request.httpBody = jsonData
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("Error updating user data: \(error)")
                        return
                    }
                    
                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                        print("Error: Invalid response from server")
                        return
                    }
                    
                    // Handle the successful response here
                    if let data = data {
                        if let responseString = String(data: data, encoding: .utf8) {
                            print("Response String: \(responseString)")
                        }
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
    }
        
    
    
    
    struct SettingsView: View {
        @State private var navigateToLogin = false
        @State private var showingImagePicker = false
        @Binding var profileImage: UIImage? //
        
        
        
        var body: some View {
            NavigationView {
                ZStack {
                    // Pink ombre circles in each corner
                    Circle()
                        .fill(PinkGradient)
                        .frame(width: 300, height: 300)
                        .position(x: 0, y: 0) // Top left corner
                    
                    Circle()
                        .fill(PinkGradient)
                        .frame(width: 300, height: 300)
                        .position(x: UIScreen.main.bounds.width, y: 0) // Top right corner
                    
                    Circle()
                        .fill(PinkGradient)
                        .frame(width: 300, height: 300)
                        .position(x: 0, y: UIScreen.main.bounds.height) // Bottom left corner
                    
                    Circle()
                        .fill(PinkGradient)
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
                                    .foregroundColor(.pink)
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
                        
                        Button(action: {
                            // Show the image picker when the button is pressed
                            showingImagePicker.toggle()
                        }) {
                            Text("Change Profile Picture")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.pink)
                                .cornerRadius(10)
                        }
                        .padding(.top, 20)
                        .sheet(isPresented: $showingImagePicker) {
                            ImagePicker(image: $profileImage) // Change this line
                        }
                        
                        
                        Button("Change Theme") {
                            // Action for Change Theme
                        }
                        .buttonStyle(SettingsButtonStyle())
                        
                        Button("Limit Your Activity") {
                            // Action for Limit Your Activity
                        }
                        
                        .buttonStyle(SettingsButtonStyle())
                        
                        
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
                                .background(Color.pink)
                                .cornerRadius(10)
                        }
                        .padding(.top, 20)
                        
                        
                        Spacer()
                    }
                    .background(.pink.opacity(0.1))
                }
                
            }
            .navigationBarTitle(Text(""), displayMode: .inline) // Add this line to hide the default navigation title
            
            var PinkGradient: LinearGradient {
                LinearGradient(gradient: Gradient(colors: [Color.pink, Color.pink.opacity(0)]), startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        }
    }
    struct SettingsButtonStyle: ButtonStyle {
        
        func makeBody(configuration: Self.Configuration) -> some View {
            
            configuration.label
            
                .foregroundColor(.white)
            
                .padding()
            
                .background(Color.pink)
            
                .cornerRadius(8)
            
                .frame(maxWidth: .infinity)
            
                .padding(.horizontal)
            
        }
        
    }
    struct ImagePicker: UIViewControllerRepresentable {
        
        @Binding var image: UIImage?
        
        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            return picker
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
            let parent: ImagePicker
            
            init(_ parent: ImagePicker) {
                self.parent = parent
            }
            
            
            
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
                if let uiImage = info[.originalImage] as? UIImage {
                    parent.image = uiImage
                }
                
                picker.dismiss(animated: true)
            }
        }
        
        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserSession.mock)
    }
}
