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
        
        if !isPasswordWrong && !isUsernameWrong {
            NavigationLink(destination: ContentView(username: username), isActive: $showingLoginScreen){
                EmptyView()
            }
        }
    }
}
    
    
    
    
    
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}


