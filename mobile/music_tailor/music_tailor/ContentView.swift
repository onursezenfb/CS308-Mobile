import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    var username: String
    var email: String
    var name: String
    var surname: String
    var password: String


    var body: some View {
        NavigationView {
            
            VStack {
                
                TabView(selection: $selectedTab) {
                    HomeView(username: username, email: email, name: name, surname: surname, password: password)
                        .tabItem {
                            Image(systemName: "house")
                            Text("Home")
                        }
                        .tag(0)
                    
                    UploadMusicFormView(username: username, email: email, name: name, surname: surname, password: password)
                        .tabItem {
                            Image(systemName: "square.and.arrow.up")
                            Text("Upload Music")
                        }
                        .tag(1)
                    
                    PlaylistsView(username: username, email: email, name: name, surname: surname, password: password)
                        .tabItem {
                            Image(systemName: "music.note.list")
                            Text("Your Playlists")
                        }
                        .tag(2)
                    
                    FriendsView(username: username, email: email, name: name, surname: surname, password: password)
                        .tabItem {
                            Image(systemName: "person.2")
                            Text("Friends")
                        }
                        .tag(3)
                    
                    ProfileView(username: username, email: email, name: name, surname: surname, password: password)
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
}


struct HomeView: View {
    var username: String
    var email: String
    var name: String
    var surname: String
    var password: String
    @State private var searchText: String = ""
    @State private var currentFilter: Filter = .all // Default filter is "All"

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
                            
                        }
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
                    return FilterItem(id: song.song_id, name: song.name, identifier: "Song - \(performer.name)", imageUrl: album.image_url)
                }
                return nil
            }
        case .albums:
            items = albums.map { album in
                if let performer = performers.first(where: { $0.artist_id == album.artist_id }) {
                    return FilterItem(id: album.album_id, name: album.name, identifier: "Album - \(performer.name)", imageUrl: album.image_url)
                }
                return FilterItem(id: album.album_id, name: album.name, identifier: "Album", imageUrl: album.image_url)
            }
        case .performers:
            items = performers.map { performer in
                FilterItem(id: performer.artist_id, name: performer.name, identifier: "Performer", imageUrl: performer.image_url)
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

    init(id: String, name: String, identifier: String, imageUrl: String, performerName: String? = nil) {
        self.id = id
        self.name = name
        self.identifier = identifier
        self.imageUrl = imageUrl
        self.performerName = performerName
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
    
    
    
    var username: String
    var email: String
    var name: String
    var surname: String
    var password: String    
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
    var username: String
    var email: String
    var name: String
    var surname: String
    var password: String
    var body: some View {
        // PlaylistsView implementation
        Text("Your Playlists Content")
    }
}

struct FriendsView: View {
    var username: String
    var email: String
    var name: String
    var surname: String
    var password: String
    var body: some View {
        // FriendsView implementation
        Text("Friends Content")
    }
}

struct ProfileView: View {
    var username: String
    var email: String
    var name: String
    var surname: String
    var password: String
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
                
                Text(name + " " + surname)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 10)
                    .padding(.bottom, 1)

                Text("@" + username)
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
        ContentView(username: "ozaancelebi", email: "ozancelebi26@gmail.com", name: "Ozan", surname: "Çelebi", password: "Ozan1234.")
     //   ProfileView(username: "ozaancelebi", email: "ozancelebi26@gmail.com", name: "Ozan", surname: "Çelebi", password: "Ozan1234.")
    }
}
