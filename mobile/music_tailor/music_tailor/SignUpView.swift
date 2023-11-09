import SwiftUI

struct SignUpView: View {
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var wrongUsername = 0
    @State private var wrongPassword = 0
    @State private var showingLoginScreen = false
    @State private var emailError: String? = nil
    @State private var isEmailValid: Bool = false
    @State private var isNavigating: Bool = false


    
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
                        
                    
                    
                        ZStack(alignment: .leading) {
                            Image(systemName: "envelope")
                                .padding(.leading, 8)
                                .foregroundColor(.pink)
                            TextField("Enter your e-mail", text: $email)
                                .padding(.leading, 30) // Adjust the padding to move the text inside the text field
                                .padding(8)
                                .frame(width: 300, height: 60)
                                .background(Color.black.opacity(0.05))
                                .cornerRadius(8)
                                .frame(maxWidth: .infinity)

                        }
                        .padding()
                        .frame(width: 300, height: 60)
                        .cornerRadius(10)
                    
                        

                        
                    if let error = emailError {
                                    Text(error)
                                        .foregroundColor(.pink)
                                        .frame(width: 300, height: 10, alignment: .leading)
                                        .font(Font.system(size: 15.5, design: .default))
                                }
                    else{
                        Spacer().frame(height: 25.5)
                    }
                    
                    
                    NavigationLink(destination: PasswordView(), isActive: $isNavigating) {
                                        EmptyView()
                                    }
                                    .opacity(0)
                                    .background(Color.clear)
                    Button(action: {
                        validateEmail(email: email)
                    }) {
                        Text("Next")
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color.pink)
                            .cornerRadius(10)
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
    
    func validateEmail(email: String) {
        if email.contains("@") {
            // Email exists in the database
            if email.lowercased() == "already@gmail.com"{
                emailError = "This e-mail is already used."
                isEmailValid = false
            }else {
                emailError = nil
                isEmailValid = true
                isNavigating = true
            }
            
            
        } else {
            // Invalid email format
            emailError = "Please enter a valid e-mail address."
            isEmailValid = false
        }
    }

    
}


struct PasswordView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var confirmpassword = ""
    @State private var wrongUsername = 0
    @State private var wrongPassword = 0
    @State private var showingLoginScreen = false
    @State private var emailError: String? = nil

    
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
                        
                    
                    

                    TextField("Enter your password", text: $password)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)

                        
                    if let error = emailError {
                                    Text(error)
                                        .foregroundColor(.red)
                                        .padding(.bottom, 10)
                                }
                    else{
                        Spacer().frame(height: 20)
                    }
                    TextField("Confirm your password", text: $password)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                    if let error = emailError {
                                    Text(error)
                                        .foregroundColor(.red)
                                        .padding(.bottom, 10)
                                }
                    else{
                        Spacer().frame(height: 20)
                    }

                    Button(action: {
                        //func
                    }) {
                        Text("Next")
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(Color.pink)
                            .cornerRadius(10)
                    }
                    /*
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
                     */
                    .padding(.horizontal, 50)
                    .padding(.vertical, 5)
                    
                    
                }
    
            }
        }
    }
    
    func validateEmail(email: String) {
        // Check if the email exists in the database
        if email.contains("@") {
            // Email exists in the database
            if email.lowercased() == "already@gmail.com"{
                emailError = "This email is already used."
            }else {
                
            }
            
            
        } else {
            // Invalid email format
            emailError = "Please enter a valid email address."
        }
    }

    
}

#Preview {
    SignUpView()
}
