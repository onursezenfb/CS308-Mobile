import SwiftUI





struct LoginView: View {
    
    @EnvironmentObject var userSession: UserSession
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String? = nil
    @State private var wrongCredentials: Bool? = false
    @State private var isPasswordVisible = false
    @State private var loggedIn = false

    
    
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
                    
                    
                    ZStack(alignment: .leading) {
                        Image(systemName: "envelope")
                            .padding(.leading, 8)
                            .foregroundColor(.gray)
                        TextField("E-mail", text: $email)
                            .padding(.leading, 30)
                            .padding(8)
                            .frame(width: 300, height: 60)
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(8)
                            .frame(maxWidth: .infinity)
                            .autocapitalization(.none)

                    }
                    .frame(width: 300, height: 60)
                    .cornerRadius(10)
                    
                    ZStack(alignment: .leading) {
                        Image(systemName: "lock")
                            .font(.system(size: 20))
                            .padding(.leading, 9)
                            .foregroundColor(.gray)
                        HStack {
                            if isPasswordVisible {
                                TextField("Password", text: $password)
                            } else {
                                SecureField("Password", text: $password)
                            }
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                VStack {
                                    if isPasswordVisible {
                                        Image(systemName: "eye")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20, height: 20) // Set a fixed size for the icon
                                    } else {
                                        Image(systemName: "eye.slash")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 20, height: 20) // Set a fixed size for the icon
                                    }
                                }
                                .foregroundColor(.gray)
                                .padding(12)
                                .background(Color.black.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.leading, 30) // Adjust the padding to move the text inside the text field
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .frame(width: 300, height: 60)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(8)
                    }
                    .padding()
                    .frame(width: 300, height: 60)
                    .cornerRadius(10)
                    .autocapitalization(.none)
                    
                    Spacer().frame(height: 10)
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
                    
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding(.top, -14)
                            .padding(.bottom, -2)

                    }
                    else{
                        Spacer().frame(height: 20)
                    }
                    
                    Button(action: {
                        validateCredentials(email: email, password: password)
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
                        
                        NavigationLink(destination: SignUpView(email: "").navigationBarBackButtonHidden(true)) {
                            Text("Sign up")
                                .foregroundColor(.pink)
                                .bold()
                        }
                        
                        
                        Spacer()
                    }
                    .padding(.horizontal, 50)
                    .padding(.vertical, 5)
                    
                    
 
                    
                    
                    NavigationLink(destination: ContentView().navigationBarBackButtonHidden(true), isActive: $loggedIn)

                    {
                     EmptyView()
                    }
                                    .opacity(0)
                                    .background(Color.clear)
                    
                }
                
            }
            
            
            
        }
    }
    
    func validateCredentials(email: String, password: String) {
        // Step 1: POST Request for Credential Validation
        let loginURL = "http://127.0.0.1:8000/api/user/mobilelogin"
        guard let loginUrl = URL(string: loginURL) else { return }

        var loginRequest = URLRequest(url: loginUrl)
        loginRequest.httpMethod = "POST"
        loginRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let loginBody: [String: String] = ["email": email, "password": password]
        guard let loginJsonData = try? JSONSerialization.data(withJSONObject: loginBody, options: []) else { return }
        loginRequest.httpBody = loginJsonData

        URLSession.shared.dataTask(with: loginRequest) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                // Step 2: GET Request for User Session Details
                let sessionURL = "http://127.0.0.1:8000/api/users"
                guard let sessionUrl = URL(string: sessionURL) else { return }

                var sessionRequest = URLRequest(url: sessionUrl)
                sessionRequest.httpMethod = "GET"
                sessionRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

                URLSession.shared.dataTask(with: sessionRequest) { data, response, error in
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                        do {
                            if let users = try JSONSerialization.jsonObject(with: data!, options: []) as? [[String: Any]],
                               let user = users.first(where: { ($0["email"] as? String) == email }) {
                                DispatchQueue.main.async {
                                    // Update user session details
                                    self.userSession.username = user["username"] as? String
                                    self.userSession.email = user["email"] as? String
                                    self.userSession.name = user["name"] as? String
                                    self.userSession.surname = user["surname"] as? String
                                    loggedIn = true
                                }
                            }
                        } catch {
                            DispatchQueue.main.async {
                                errorMessage = "Error decoding JSON: \(error)"
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            errorMessage = "Unable to fetch user session. Status code: \(httpResponse.statusCode)"
                        }
                    }
                }.resume()

            } else if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Login error: \(error.localizedDescription)"
                }
            } else {
                DispatchQueue.main.async {
                    errorMessage = "Invalid credentials."
                }
            }
        }.resume()
    }
}
    
    
    
    
    
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(UserSession())
    }
}


