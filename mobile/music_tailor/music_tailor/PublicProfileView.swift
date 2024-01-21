//
//  PublicProfile.swift
//  music_tailor
//
//  Created by selin ceydeli on 1/1/24.
//

import SwiftUI

struct PublicProfileView: View {
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
        @State private var playlists: [Playlist] = []
        @State private var showingCreatePlaylistSheet = false
        @State private var newPlaylistName = ""
        @State private var showingPlaylistDetail = false
        @State private var selectedPlaylist: Playlist?

        
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
                            Text("Your Public")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            Spacer()
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
                    
                   
                    ScrollView {
                        // Editable user information fields
                        Group {
                            HStack {
                                Text("Your Stories")
                                    .bold()
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, -10)
                            HStack {
                                Text("Your Playlists")
                                    .bold()
                                Spacer()
                                
                                Button(action: {
                                                        showingCreatePlaylistSheet = true
                                                    }) {
                                                        Image(systemName: "plus.circle.fill")
                                                            .foregroundColor(themeManager.themeColor)
                                                            .padding()
                                                    }
                                                    .sheet(isPresented: $showingCreatePlaylistSheet) {
                                                        Text("Enter Playlist Name")
                                                            .font(.headline)
                                                            .padding()

                                                        TextField("Playlist Name", text: $newPlaylistName)
                                                            .autocapitalization(.none)
                                                            .textFieldStyle(    RoundedBorderTextFieldStyle())
                                                            .padding()

                                                        Button("Create") {
                                                            createPlaylist(named: newPlaylistName)
                                                            showingCreatePlaylistSheet = false
                                                            newPlaylistName = ""
                                                        }
                                                        .disabled(newPlaylistName.trimmingCharacters(in: .whitespaces).isEmpty)
                                                        .padding()

                                                        Button("Cancel") {
                                                            showingCreatePlaylistSheet = false
                                                            newPlaylistName = ""
                                                        }
                                                        .padding()
                                                    }
                                
                                
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, -10)
                            .padding(.bottom, 10)
                            
                            // Inside PublicProfileView

                            

/*
                            List(playlists, id: \.id) { playlist in
                                                        HStack {
                                                            Image(systemName: "photo")
                                                                .resizable()
                                                                .frame(width: 50, height: 50)
                                                                .background(Color.gray.opacity(0.3))
                                                                .cornerRadius(5)
                                                            Text(playlist.playlist_name)
                                                        }
                                                    }
*/
                            // Wrap this in your existing ScrollView
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                ForEach(playlists, id: \.id) { playlist in
                                    Button(action: {
                                        selectedPlaylist = playlist
                                        showingPlaylistDetail = true
                                    }) {
                                        PlaylistItemView(playlist: playlist, onDelete: deletePlaylist)
                                    }
                                }
                            }
                                            .padding(.horizontal)
                                        }
                        .padding()
                        Spacer()
                    }
                }
                .padding(.bottom, 20)
                .onAppear(perform: fetchUserData)
                .onAppear {
                    fetchProfileImage() // Fetch the profile image when the view appears
                    userSession.fetchAndUpdateUserData()
                    fetchUserData()
                    fetchPlaylists() // Ensure this is called
                }
                .onChange(of: userSession.theme) { _ in
                    fetchUserData() // Fetch data when the theme changes
                    
                }
                .onChange(of: userSession.username) { _ in
                    fetchProfileImage() // Fetch the profile image again if the username changes
                }
                .sheet(isPresented: $showingPlaylistDetail) {
                            if let selectedPlaylist = selectedPlaylist {
                                PlaylistDetailView(playlist: selectedPlaylist)
                                    .environmentObject(userSession)
                                    // Add any other necessary environment objects here
                            }
                        }
                
            }
        }
        
    private func fetchProfileImage() {
            guard let username = userSession.username,
                  let url = URL(string: "http://127.0.0.1:8000/api/users/\(username)/getimg") else {
                print("Invalid URL")
                return
            }

            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Error fetching image: \(error)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200,
                      let mimeType = httpResponse.mimeType, mimeType.hasPrefix("image"),
                      let data = data,
                      let image = UIImage(data: data) else {
                    print("Error: Invalid response from server or data")
                    return
                }

                DispatchQueue.main.async {
                    self.profileImage = image
                }
            }

            task.resume()
        }

    
    private func fetchUserData() {
        print("Fetching user data...")
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
                let fetchedUser = try JSONDecoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    self.updateUserImage(with: fetchedUser)
                }
            } catch {
                print("Error: Could not decode user data: \(error)")
            }
        }
        
        task.resume()
    }

    
    private func fetchPlaylists() {
        print("Fetching playlists...")
        let username = userSession.username ?? ""
        guard let url = URL(string: "http://127.0.0.1:8000/api/playlists/\(username)") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }

            if let data = data {
                do {
                    let response = try JSONDecoder().decode(PlaylistsResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.playlists = response.playlists
                        print("Playlists fetched: \(self.playlists)")
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
            } else {
                print("No data received")
            }
        }.resume()
    }
    
    private func deletePlaylist(playlist: Playlist) {
        guard let url = URL(string: "http://127.0.0.1:8000/api/playlist/\(playlist.id)") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    // Remove the playlist from the list
                    self.playlists.removeAll { $0.id == playlist.id }
                }
            } else {
                // Handle errors
                print("Error deleting playlist: \(error?.localizedDescription ?? "Unknown error")")
            }
        }.resume()
    }


    private func createPlaylist(named name: String) {
        let url = URL(string: "http://127.0.0.1:8000/api/playlists/create-with-user")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["username": userSession.username ?? "", "playlist_name": name]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("HTTP Error: Status code \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            // Print the raw JSON response as a string for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON String: \(jsonString)")
            }

            // Attempt to decode the data into the Playlist struct
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                        DispatchQueue.main.async {
                            self.fetchPlaylists()  // Refetch playlists
                            self.newPlaylistName = ""
                        }
                    } else {
                        // Handle any errors, such as decoding errors or unsuccessful HTTP responses
                        print("Decoding error: \(error?.localizedDescription ?? "Unknown error")")
                    }
        }.resume()
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
        
        let updatedUser = PublicUser(
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
struct PublicUser: Codable {
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

struct PlaylistsResponse: Codable {
    var success: Bool?
    var playlists: [Playlist]
}


struct Playlist: Codable, Identifiable {
    var id: Int
    var playlist_name: String
    var created_at: String
    var updated_at: String
    var pivot: Pivot

    private enum CodingKeys: String, CodingKey {
        case id, playlist_name, created_at, updated_at, pivot
    }
}

struct Pivot: Codable {
    var username: String
    var playlist_id: Int
}

struct PlaylistItemView: View {
    let playlist: Playlist
    var onDelete: (Playlist) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            // Default image for playlists
            Image(systemName: "music.note.list")
                .resizable()
                .scaledToFit()
                .padding(30)
                .background(Color.gray.opacity(0.3))
                .frame(height: 150)
                .cornerRadius(10)
                .shadow(radius: 5)

            HStack {
                VStack(alignment: .leading) {
                    Text(playlist.playlist_name)
                        .font(.headline)
                        .lineLimit(1)
                    // Additional playlist details can go here
                }
                Spacer()
                Button(action: { onDelete(playlist) }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}


struct PublicProfileView_Previews: PreviewProvider {
    static var previews: some View {
        PublicProfileView()
            .environmentObject(UserSession.mock)
            .environmentObject(ThemeManager()) // Add ThemeManager as an environment object
    }
}
