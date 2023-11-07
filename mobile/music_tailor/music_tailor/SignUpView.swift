import SwiftUI

struct SignUpView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var passwordMatch: Bool = true
    @State private var isValid: Bool = true
    @State private var signedUp: Bool = false

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
                    Text("Get started with")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.black)
                        .frame(width: 300, height: 5, alignment: .leading)
                    Text("Music Tailor")
                        .font(Font.system(size: 36, design: .rounded))
                        .bold()
                        .foregroundColor(.pink)
                        .frame(width: 300, height: 50, alignment: .leading)
                    
                    TextField("Username", text: $username)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)

                    SecureField("Password", text: $password)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                        .border(isValid ? .clear : .red, width: 2)
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                        .border(passwordMatch ? .clear : .red, width: 2)
                    
                    Spacer().frame(height: 20)

                    Button(action: {
                        if password == confirmPassword {
                            passwordMatch = true
                            if isValidPassword(password) {
                                isValid = true
                                signedUp = true
                            } else {
                                isValid = false
                            }
                        } else {
                            passwordMatch = false
                        }
                    }) {
                        Text("Sign Up")
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color.pink)
                            .cornerRadius(10)
                    }

                    if signedUp {
                        NavigationLink(destination: LoginView()) {
                            Text("You signed up! Click and go to the login page to start.")
                                .foregroundColor(.pink)
                                .bold()
                        }
                        .padding()
                    }
                    
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.black)
                        
                        NavigationLink(destination: LoginView()) {
                            Text("Login")
                                .foregroundColor(.pink)
                                .bold()
                        }
                        .navigationBarBackButtonHidden(true) // Hide the back button
                        Spacer()
                    }
                    .padding(.horizontal, 50)
                    .padding(.vertical, 5)
                }
            }
        }
    }
    
    func isValidPassword(_ password: String) -> Bool {
        // Check for at least 6 characters
        guard password.count >= 6 else { return false }
        
        // Check for at least one special character
        let specialCharacterPattern = "[^a-zA-Z0-9]"
        let regex = try? NSRegularExpression(pattern: specialCharacterPattern, options: [])
        let range = NSRange(location: 0, length: password.utf16.count)
        
        return regex?.firstMatch(in: password, options: [], range: range) != nil
    }
}

#Preview {
    SignUpView()
}

