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
        
        @State private var showingRatingSheet = false
        @State private var currentItemID: String?
        
        @State private var currentItemType: ItemType?
        @State private var albums: [Album] = []
        @State private var songs: [Song] = []
        @State private var performers: [Performer] = []
        
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
                                        showingRatingSheet = true
                                    }) {
                                                            Image(systemName: "star.fill") // Or any other icon or text you prefer
                                                                .foregroundColor(.yellow)
                                                        }
                            }
                        }
                    }
                    .sheet(isPresented: $showingRatingSheet) {
                        if let itemType = currentItemType, let itemID = currentItemID {
                            RatingSheetView(itemID: itemID, itemType: itemType)
                        }
                    }

            }
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(0)
            }
            .onAppear {
                fetchSearchResults()
            }
            
        }
        
        private func fetchSearchResults() {
            // Define the API endpoint URLs based on the current filter and searchText
            var endpointURL: URL
            switch currentFilter {
            case .songs:
                endpointURL = URL(string: "http://127.0.0.1:8000/api/songs/name/\(searchText)")!
            case .albums:
                endpointURL = URL(string: "http://127.0.0.1:8000/api/albums/name/\(searchText)")!
            case .performers:
                endpointURL = URL(string: "http://127.0.0.1:8000/api/performers/name/\(searchText)")!
            case .all:
                // Handle the case when "All" is selected
                return
            }
            
            // Create URLSession tasks for the current filter
            let task = URLSession.shared.dataTask(with: endpointURL) { data, response, error in
                if let data = data {
                    switch currentFilter {
                    case .songs:
                        do {
                            let response = try JSONDecoder().decode(Response<Song>.self, from: data)
                            songs = response.data
                        } catch {
                            print("Error decoding songs JSON: \(error)")
                        }
                    case .albums:
                        do {
                            let response = try JSONDecoder().decode(Response<Album>.self, from: data)
                            albums = response.data
                        } catch {
                            print("Error decoding albums JSON: \(error)")
                        }
                    case .performers:
                        do {
                            let response = try JSONDecoder().decode(Response<Performer>.self, from: data)
                            performers = response.data
                        } catch {
                            print("Error decoding performers JSON: \(error)")
                        }
                    case .all:
                        break
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
                items = songs.compactMap { song in
                    if let album = albums.first(where: { $0.album_id == song.album_id }),
                       let performer = performers.first(where: { $0.artist_id == album.artist_id }) {
                        return FilterItem(id: song.song_id, name: song.name, identifier: "Song - \(performer.name)", imageUrl: album.image_url,itemType: .song)
                    }
                    return nil
                }
            case .albums:
                items = albums.map { album in
                    if let performer = performers.first(where: { $0.artist_id == album.artist_id }) {
                        return FilterItem(id: album.album_id, name: album.name, identifier: "Album - \(performer.name)", imageUrl: album.image_url,itemType: .album)
                    }
                    return FilterItem(id: album.album_id, name: album.name, identifier: "Album", imageUrl: album.image_url,itemType: .album)
                }
            case .performers:
                items = performers.map { performer in
                    FilterItem(id: performer.artist_id, name: performer.name, identifier: "Performer", imageUrl: performer.image_url,itemType: .performer)
                }
            case .all:
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
    
    
    
    struct Album: Identifiable, Decodable {
        var album_id: String
        var name: String
        var image_url: String
        var artist_id: String
        // Add other album properties as needed
        
        // Conform to Identifiable by providing a unique identifier
        var id: String { album_id }
    }
    
    struct Song: Identifiable, Decodable {
        var song_id: String
        var name: String
        var album_id: String
        var rating: Double?
        // Add image_url property
        // Add other song properties as needed
        
        // Conform to Identifiable by providing a unique identifier
        var id: String { song_id }
    }
    
    struct Performer: Identifiable, Decodable {
        var artist_id: String
        var name: String
        var image_url: String // Add image_url property
        // Add other performer properties as needed
        
        // Conform to Identifiable by providing a unique identifier
        var id: String { artist_id }
    }
    
    
    struct Response<T: Decodable>: Decodable {
        var data: [T]
    }
    
    
    
    
    
    struct UploadMusicFormView: View {
        
        /*
         
         spotify linki
         
         
         */
        
        
        
       
        @State private var songName: String = ""
        @State private var publicationDate: String = "" // for publ_date
        @State private var performers: String = "" // for performers (stored as JSON)
        @State private var songWriter: String = ""
        @State private var genre: String = ""
        @State private var recordingType: String = "" // for recording_type (live/studio/radio)
        @State private var songLengthSeconds: String = "" // for song_length_seconds
        @State private var tempo: String = "" // for tempo
        @State private var mood: String = ""
        @State private var language: String = ""
        @State private var systemEntryDate: String = "" // for system_entry_date (timestamp)
        @State private var albumName: String = "" // for album_id
        var body: some View {
            NavigationView {
                ZStack {
                    Color.white
                        .ignoresSafeArea()
                    
                    VStack{
                        Spacer().frame(height: 30)
                        
                        HStack{
                            VStack{
                                Text("Upload Music Into")
                                    .font(.largeTitle)
                                    .bold()
                                    .foregroundColor(.black)
                                    .frame(width: 300, height: 5, alignment: .leading)
                                Text("Music Tailor")
                                    .font(Font.system(size: 36, design: .rounded))
                                    .bold()
                                    .foregroundColor(.pink)
                                    .frame(width: 300, height: 50, alignment: .leading)
                            }
                            Spacer().frame(width: 40)
                        }
                        
                        
                        Form() {
                            Section(header: Text("ENTER  Details").foregroundColor(.black)) {
                                TextField("Song Name", text: $songName)
                                TextField("Performers (Comma Separated)", text: $performers)
                                TextField("Album Name", text: $albumName)
                                TextField("Song Writer", text: $songWriter)
                                TextField("Genres (Comma Separated)", text: $genre)
                                TextField("Language", text: $language)
                                TextField("Publication Date (YYYY-MM-DD)", text: $publicationDate)
                                TextField("Recording Type (live/studio/radio)", text: $recordingType)
                                TextField("Song Length (seconds)", text: $songLengthSeconds)
                                TextField("Tempo (BPM)", text: $tempo)
                                TextField("Mood", text: $mood)
                                
                                Button("Submit") {
                                    // Handle the submission of the form
                                    // Get the current date and time
                                    let currentDate = Date()
                                    
                                    // Create a date formatter to format the date as "YYYY-MM-dd HH:mm:ss"
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
                                    
                                    // Update the systemEntryDate state variable with the formatted date
                                    systemEntryDate = dateFormatter.string(from: currentDate)
                                    
                                    // Now you can use the systemEntryDate value in your database operation or wherever needed
                                    print("System Entry Date: \(systemEntryDate)")
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.pink)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                        
                    }
                    .background(Color.pink.opacity(0.15))
                    .cornerRadius(0)
                    
                    
                }
                
            }
        }
    }
    
    
    
    
    
    struct PlaylistsView: View {
       
        @State private var showRecommendations = false
        @State private var showRecommendations2 = false
        var body: some View {
            VStack(spacing: 10) {
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
                
                Button(action: {
                               showRecommendations = true
                           }) {
                               Text("Fav Genre Recommendations")
                                   .font(.headline)
                                   .foregroundColor(.white)
                                   .padding()
                                   .background(Color.pink)
                                   .cornerRadius(10)
                           }
                Button(action: {
                               showRecommendations2 = true
                           }) {
                               Text("Energic Recommendations")
                                   .font(.headline)
                                   .foregroundColor(.white)
                                   .padding()
                                   .background(Color.pink)
                                   .cornerRadius(10)
                           }
                
                Button(action: {
                    // Action for "Your Playlists" button
                }) {
                    Text("Your Playlists")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.pink)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: RecommendationView(), isActive: $showRecommendations) {
                                EmptyView()
                            }.hidden()
                NavigationLink(destination: EnergyDanceabilityRecommendationView(), isActive: $showRecommendations2) {
                                EmptyView()
                            }.hidden()
                
                Spacer()
            }
            .padding() // Adjust padding if needed
            .background(
                Rectangle()
                    .fill(Color.pink.opacity(0.2))
                    .cornerRadius(20)
                // Adjust the size as per your requirements
                    .frame(width: 500, height: 700)
            )
        }
    }
    
    
    struct FriendsView: View {
        
        
        var body: some View {
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
                
                Button(action: {
                    // Action for "Add Friends" button
                }) {
                    NavigationLink(destination: AddFriendView()) {
                        Text("Add Friends")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.pink)
                            .cornerRadius(10)
                    }
                }
                
                Button(action: {
                    // Action for "Manage Your Friends" button
                }) {
                    Text("Manage Your Friends")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.pink)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding() // Adjust padding if needed
            .background(
                Rectangle()
                    .fill(Color.pink.opacity(0.2))
                    .cornerRadius(20)
                    .frame(width: 500, height: 700) // Ensures the rectangle takes the full width available
            )
        }
    }
    
    
    
    
    
    
    struct ProfileView: View {
        @EnvironmentObject var userSession: UserSession
        
        @State private var profileImage: UIImage? = nil
        @State private var selectedImage: UIImage? // Add this line
        @State private var showingSettings = false // Added state for showing settings
        
        var body: some View {
            NavigationView {
                VStack {
                    VStack(spacing: 0) { // Set spacing to 0 to remove the space between text elements
                        HStack {
                            Text("Your Personal")
                                .font(.custom("Arial-BoldMT", size: 30))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(.leading, 20)
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
                        
                        VStack {
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
                    }
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
                    
                    Text("\(userSession.name ?? "") \(userSession.surname ?? "")")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                            .padding(.bottom, 1)

                        Text("@\(userSession.username ?? "")")
                            .foregroundColor(.gray)
                    
                    Divider()
                        .background(Color.pink.opacity(0.15)) // Set background color of the part divided by the divider to pink
                        .padding(.vertical, 20)
                    
                    Text("This is a brief description about yourself. You can customize it based on your preferences.")
                        .font(.custom("Avenir Next", size: 18))
                        .italic()
                        .padding(.horizontal, 20)
                        .multilineTextAlignment(.center)
                    
                    
                    Spacer()
                }
            }
            .navigationBarTitle(Text(""), displayMode: .inline) // Add this line to hide the default navigation title
        }
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
    
    

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
                .environmentObject(UserSession())
        }
    }

    
}
