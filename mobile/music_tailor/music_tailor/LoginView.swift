import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isUsernameWrong = false
    @State private var isPasswordWrong = false
    @State private var showingLoginScreen = false
    @State private var errorMessage: String? = nil
    
    
    var body: some View {
        NavigationView{
            ZStack{
                Color.pink
                    .ignoresSafeArea()
                Circle()
                    .scale(1.7)
                    .foregroundColor(.white.opacity(0.15))
                Circle()
                    .scale(1.35)
                    .foregroundColor(.white)
                VStack{
                    Text("Welcome Back To")
                        .font(.largeTitle)
                        .bold()
                        .frame(width: 300, height: 5, alignment: .leading)
                    Text("Music Tailor")
                        .font(Font.system(size: 36, design: .rounded))
                        .bold()
                        .foregroundColor(.pink)
                        .frame(width: 300, height: 50, alignment: .leading)
                    
                    
                    TextField("E-mail", text: $username)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                        .border(Color.red, width: isUsernameWrong ? 2 : 0)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                        .border(Color.red, width: isPasswordWrong ? 2 : 0)
                    
                    
                    HStack{
                        Button(action: {
                            // function
                        }) {
                            Text("Forgot your password?")
                                .foregroundColor(.pink)
                                .bold()
                            
                        }
                        Spacer()
                        
                    }
                    .padding(.horizontal, 50)
                    .padding(.bottom, 10)
                    
                    
                    
                    Button(action: {
                        validateCredentials(username: username, password: password)
                    }) {
                        Text("Login")
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color.pink)
                            .cornerRadius(10)
                    }
                    
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.black)
                        
                        NavigationLink(destination: SignUpView()) {
                            Text("Sign up")
                                .foregroundColor(.pink)
                                .bold()
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 50)
                    .padding(.vertical, 5)
                    
                    NavigationLink(destination: HomeView(username: username), isActive: $showingLoginScreen){
                        EmptyView()
                    }
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding(.bottom, 10)
                    }
                    
                    
                    
                    
                }
                
            }
            .navigationBarHidden(true)
        }
    }
    
    func validateCredentials(username: String, password: String) {
        var errorMessages: [String] = []
        
        isUsernameWrong = !username.contains("@")
        if isUsernameWrong {
            errorMessages.append("Please enter a valid email address.")
        }
        
        if password.count < 6 {
            errorMessages.append("Your password should contain at least 6 characters.")
        }
        
        let specialCharacterPattern = "[^a-zA-Z0-9]"
        let regex = try? NSRegularExpression(pattern: specialCharacterPattern, options: [])
        let range = NSRange(location: 0, length: password.utf16.count)
        
        if regex?.firstMatch(in: password, options: [], range: range) == nil {
            errorMessages.append("Your password should contain at least one special character.")
        }
        
        isPasswordWrong = !errorMessages.isEmpty && !isUsernameWrong
        
        if errorMessages.isEmpty {
            showingLoginScreen = true
        } else {
            errorMessage = errorMessages.joined(separator: "\n")
        }
    }
    
    
    
    struct HomeView: View {
        @State private var selectedTab: Int = 0
        @State private var searchText: String = ""
        @State private var showUploadMusicForm: Bool = false
        var username: String
        
        var body: some View {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .padding(.leading, 8)
                    TextField("Search", text: $searchText)
                        .padding(8)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
                .padding([.leading, .trailing, .top])
                
                // Tabs
                TabView(selection: $selectedTab) {
                    
                    // Main Home Content
                    VStack {
                        Spacer()  // Pushes content to the middle
                        Text("Hello, \(username)!")
                            .font(.largeTitle)
                        Spacer()  // Pushes content to the middle
                    }

                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                    .tag(0)
                    
                    // Upload Music
                    VStack {
                                        Spacer()
                                    }
                                    .tabItem {
                                        Image(systemName: "square.and.arrow.up")
                                        Text("Upload Music")
                                    }
                                    .tag(1)
                    
                    // Your Playlists
                    Text("Your Playlists")
                    .tabItem {
                        Image(systemName: "music.note.list")
                        Text("Your Playlists")
                    }
                    .tag(2)
                    
                    // Profile
                    Text("Profile")
                    .tabItem {
                        Image(systemName: "person.circle")
                        Text("Profile")
                    }
                    .tag(3)
                    
                    // Friends
                    Text("Friends")
                    .tabItem {
                        Image(systemName: "person.2")
                        Text("Friends")
                    }
                    .tag(4)
                    
                }
                .onChange(of: selectedTab) { value in
                                if value == 1 {
                                    showUploadMusicForm = true
                                }
                            }
                            .background(
                                NavigationLink("", destination: UploadMusicForm(), isActive: $showUploadMusicForm)
                                    .hidden()
                            )
            }
        }
    }


    
    struct UploadMusicForm: View {
        @State private var performerName: String = ""
        @State private var songName: String = ""
        @State private var jobLocation: String = ""
        @State private var contactEmail: String = ""
        @State private var musicURL: String = ""
        @State private var genre: String = ""
        
        var body: some View {
            NavigationView {
                ZStack {
                    Color.pink
                        .ignoresSafeArea()
                    Circle()
                        .scale(1.7)
                        .foregroundColor(.white.opacity(0.15))
                        .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
                    Circle()
                        .scale(1.35)
                        .foregroundColor(.white)
                        .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
                    
                    Form {
                        Section(header: Text("Music Details").foregroundColor(.black)) {
                            TextField("Performer Name", text: $performerName)
                            TextField("Song Name", text: $songName)
                            TextField("Job Location", text: $jobLocation)
                            TextField("Contact Email", text: $contactEmail)
                            TextField("Apple Music/Spotify URL", text: $musicURL)
                            TextField("Genre (Comma Separated)", text: $genre)
                        }
                        Button("Submit") {
                            // handle the submission of the form
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(Color.pink)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .padding()
                }
                .navigationTitle("Upload Music")
                .navigationBarItems(trailing: Button("Dismiss") {
                    // Handle dismissal of the view, if needed
                })
            }
        }
    }
    
    
    
    
    struct LoginView_Previews: PreviewProvider {
        static var previews: some View {
            LoginView()
        }
    }

}
