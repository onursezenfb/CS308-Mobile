import SwiftUI

struct LoginView: View {
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
                        validateCredentials(username: email, password: password)
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
                    
                    
 
                    
                    
                    NavigationLink(destination: ContentView(username: "ozaancelebi", email: email, name: "Ozan", surname: "Çelebi", password: password).navigationBarBackButtonHidden(true), isActive: $loggedIn)
                    {
                                        EmptyView()
                                    }
                                    .opacity(0)
                                    .background(Color.clear)
                    
                }
                
            }
            
            
            
        }
    }
    
    func validateCredentials(username: String, password: String) {
        let apiURL = "http://127.0.0.1:8000/api/users"
        guard let url = URL(string: apiURL) else { return }

        let parameters: [String: String] = [
            "email": email
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                if (200..<300).contains(httpResponse.statusCode) {
                    do {
                        if let users = try JSONSerialization.jsonObject(with: data!, options: []) as? [[String: Any]] {
                            if let user = users.first(where: { ($0["email"] as? String) == email && ($0["language"] as? String) == password }) {
                                // Login successful
                                print("Login successful!")
                                DispatchQueue.main.async {
                                    loggedIn = true
                                }
                            } else {
                                // Invalid email or language
                                print("Invalid email or language.")
                                DispatchQueue.main.async {
                                    wrongCredentials = true
                                    errorMessage = "Invalid email or language."
                                }
                            }
                        }
                    } catch {
                        print("Error decoding JSON:", error)
                    }
                } else {
                    // Login failed
                    print("Error fetching users. Status code: \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        wrongCredentials = true
                        errorMessage = "Error fetching users."
                    }
                }
            }
        }.resume()
    }

}
    
    
    
    
    
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}


