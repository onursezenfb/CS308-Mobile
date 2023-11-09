import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    var username: String

    var body: some View {
        NavigationView {
            VStack {
                TabView(selection: $selectedTab) {
                    HomeView(username: username)
                        .tabItem {
                            Image(systemName: "house")
                            Text("Home")
                        }
                        .tag(0)
                    
                    UploadMusicFormView(username: username)
                        .tabItem {
                            Image(systemName: "square.and.arrow.up")
                            Text("Upload Music")
                        }
                        .tag(1)
                    
                    PlaylistsView(username: username)
                        .tabItem {
                            Image(systemName: "music.note.list")
                            Text("Your Playlists")
                        }
                        .tag(2)
                    
                    FriendsView(username: username)
                        .tabItem {
                            Image(systemName: "person.2")
                            Text("Friends")
                        }
                        .tag(3)
                    
                    ProfileView(username: username)
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
    @State private var searchText: String = ""

    var body: some View {
        ZStack{
            Color.white
                .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 16) {
                ZStack(alignment: .leading) {
                    Image(systemName: "magnifyingglass")
                        .padding(.leading, 8)
                        .foregroundColor(.gray)
                    TextField("Search", text: $searchText)
                        .padding(.leading, 30) // Adjust the padding to move the text inside the text field
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity)

                }
                
                Spacer()
                Text("Hello, \(username)!")
                    .font(.largeTitle)
                    .padding()
                Spacer()
                Spacer()
            }
            .padding()
            .background(Color.white.opacity(0.8))
            .cornerRadius(0)
        }
    }
}



struct UploadMusicFormView: View {
    var username: String
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

    var body: some View {
        // PlaylistsView implementation
        Text("Your Playlists Content")
    }
}

struct FriendsView: View {
    var username: String

    var body: some View {
        // FriendsView implementation
        Text("Friends Content")
    }
}

struct ProfileView: View {
    var username: String

    var body: some View {
        // ProfileView implementation
        Text("Profile Content")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(username: "Dummy")
    }
}
