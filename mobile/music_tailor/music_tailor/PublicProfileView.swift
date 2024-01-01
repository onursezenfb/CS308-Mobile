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
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, -10)
                            .padding(.bottom, 10)
                        }
                        .padding()
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

struct PublicProfileView_Previews: PreviewProvider {
    static var previews: some View {
        PublicProfileView()
            .environmentObject(UserSession.mock)
            .environmentObject(ThemeManager()) // Add ThemeManager as an environment object
    }
}
