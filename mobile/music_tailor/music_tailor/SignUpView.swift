import SwiftUI

struct SignUpView: View {
    @State var email: String
    @State private var username = ""
    @State private var password = ""
    @State private var wrongUsername = 0
    @State private var wrongPassword = 0
    @State private var emailError: String? = nil
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
                            .frame(width: 302, height: 5, alignment: .leading)
                        Text("Music Tailor")
                            .font(Font.system(size: 36, design: .rounded))
                            .bold()
                            .foregroundColor(.pink)
                            .frame(width: 302, height: 50, alignment: .leading)
                        
                    
                    
                        ZStack(alignment: .leading) {
                            Image(systemName: "envelope")
                                .padding(.leading, 8)
                                .foregroundColor(.gray)
                            TextField("Enter your e-mail", text: $email)
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
                    
                        

                        
                    if let error = emailError {
                                    Text(error)
                                        .foregroundColor(.pink)
                                        .frame(width: 300, height: 23, alignment: .topLeading)
                                        .font(Font.system(size: 15.5, design: .default))
                                }
                    else{
                        Spacer().frame(height: 30)
                    }
                    
                    
                    NavigationLink(destination: PasswordView(email: $email).navigationBarBackButtonHidden(true), isActive: $isNavigating) {
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
                        NavigationLink(destination: LoginView().navigationBarBackButtonHidden(true)) {
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
            }else {
                emailError = nil
                isNavigating = true
            }
            
            
        } else {
            // Invalid email format
            emailError = "Please enter a valid e-mail address."
        }
    }

    
}


struct PasswordView: View {
    @Binding var email: String
    @State private var username = ""
    @State private var password = ""
    @State private var isPasswordValid = false
    @State private var passwordError: String? = nil
    @State private var confirmPassword = ""
    @State private var confirmPasswordError: String? = nil
    @State private var isConfirmPasswordValid = false
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    @State private var goBack = false

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
                    Text("Secure Your Beats:")
                        .font(.custom("Arial-BoldMT", size: 34))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .frame(height: 15)
                        .padding(.leading, 8)
                    HStack{
                        Text("Tailor")
                            .font(Font.system(size: 36, design: .rounded))
                            .bold()
                            .foregroundColor(.pink)
                        VStack{
                            Text("Your Password")
                                .font(.custom("Arial", size: 30))
                                .foregroundColor(.black)
                                .frame(height: 15, alignment: .leading)
                        }
                        .padding(.top, 4.5)

                        
                    }
                    .padding(.leading, -5)

                    
                        
                        
                        
                    ZStack(alignment: .leading) {
                        Image(systemName: "lock")
                            .padding(.leading, 8)
                            .foregroundColor(.gray)
                        HStack {
                            if isPasswordVisible {
                                TextField("Enter your password", text: $password)
                            } else {
                                SecureField("Enter your password", text: $password)
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

                    

                    ZStack(alignment: .leading) {
                        Image(systemName: "lock.fill")
                            .padding(.leading, 8)
                            .foregroundColor(.gray)
                        HStack {
                            if isConfirmPasswordVisible {
                                TextField("Confirm your password", text: $confirmPassword)
                            } else {
                                SecureField("Confirm your password", text: $confirmPassword)
                            }
                            Button(action: {
                                isConfirmPasswordVisible.toggle()
                            }) {
                            VStack {
                                if isConfirmPasswordVisible {
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
                    
                    if let error = passwordError {
                                    Text(error)
                                        .foregroundColor(.red)
                                        .padding(.bottom, 10)
                                }
                    else{
                        if let error = confirmPasswordError {
                                        Text(error)
                                            .foregroundColor(.red)
                                            .padding(.bottom, 10)
                                    }
                        else{
                            Spacer().frame(height: 30)
                        }
                    }
                    NavigationLink(destination: UsernameView(email: $email, password: password).navigationBarBackButtonHidden(true), isActive: $isConfirmPasswordValid) {
                        EmptyView()
                    }
                    .opacity(0)
                    .background(Color.clear)

                    
                    HStack{
                        Button(action: {
                            goBack = true
                        }) {
                            Text("Back")
                                .foregroundColor(.white)
                                .frame(width: 75, height: 50)
                                .background(Color.pink)
                                .cornerRadius(10)
                        }
                        Button(action: {
                            validatePassword(password: password)
                            validateConfirmPassword(confirmPassword: confirmPassword)
                        }) {
                            Text("Next")
                                .foregroundColor(.white)
                                .frame(width: 217, height: 50)
                                .background(Color.pink)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.vertical, 5)

                    NavigationLink(destination: SignUpView(email: email).navigationBarBackButtonHidden(true), isActive: $goBack) {
                            EmptyView()
                        }
                        .opacity(0)
                        .background(Color.clear)
                    
                }
    
            }
        }
    }
    
    func validatePassword(password: String) {
        if password.count < 8 {
            // Password must be at least 8 characters long.
            passwordError = "Must be at least 8 characters."
            isPasswordValid = false
            return
        }
        
        let lowercaseLetterRegex = ".*[a-z]+.*"
        let uppercaseLetterRegex = ".*[A-Z]+.*"
        let digitRegex = ".*\\d+.*"
        let specialCharacterRegex = ".*[^a-zA-Z\\d]+.*"
        
        if !NSPredicate(format: "SELF MATCHES %@", lowercaseLetterRegex).evaluate(with: password) {
            // Password must contain at least one lowercase letter.
            passwordError = "Must contain at least 1 lowercase letter."
            isPasswordValid = false
            return
        }
        
        if !NSPredicate(format: "SELF MATCHES %@", uppercaseLetterRegex).evaluate(with: password) {
            // Password must contain at least one uppercase letter.
            passwordError = "Must contain at least 1 uppercase letter."
            isPasswordValid = false
            return
        }
        
        if !NSPredicate(format: "SELF MATCHES %@", digitRegex).evaluate(with: password) {
            // Password must contain at least one digit.
            passwordError = "Must contain at least 1 digit."
            isPasswordValid = false
            return
        }
        
        if !NSPredicate(format: "SELF MATCHES %@", specialCharacterRegex).evaluate(with: password) {
            // Password must contain at least one special character.
            passwordError = "Must contain at least 1 special character."
            isPasswordValid = false
            return
        }
        
        // Password meets all criteria.
        passwordError = nil
        isPasswordValid = true
    }
    func validateConfirmPassword(confirmPassword: String) {
            if confirmPassword == password && isPasswordValid == true{
                // Confirm password matches the password
                confirmPasswordError = nil
                isConfirmPasswordValid = true
            } else {
                // Confirm password does not match the password
                confirmPasswordError = "Passwords do not match."
                isConfirmPasswordValid = false
            }
        }

    
}


struct UsernameView: View {
    @Binding var email: String
    let password: String
    @State private var username = ""
    @State private var name = ""
    @State private var surname = ""
    @State private var goBack = false
    @State private var usernameError: String? = nil
    @State private var isEverythingValid = false


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
                    Text("Ready to Tune In:")
                        .font(.custom("Arial-BoldMT", size: 36))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .frame(height: 15)
                        .padding(.leading, -7)
                        .padding(.bottom, 30)
                    
                    Text("Complete Your Profile")
                        .font(.custom("Arial", size: 30))
                        .foregroundColor(.black)
                        .frame(height: 0, alignment: .leading)
                        .padding(.leading, -17)
                    
                    HStack{
                        VStack{
                            Text("For")
                                .font(.custom("Arial", size: 30))
                                .foregroundColor(.black)
                                .frame(height: 0, alignment: .leading)
                        }
                        .padding(.top, 4.5)
                        Text("Music Tailor")
                            .font(Font.system(size: 36, design: .rounded))
                            .bold()
                            .foregroundColor(.pink)
                        
                        
                        
                    }
                    .padding(.leading, -58)
                    
                    
                    
                    
                    
                    ZStack(alignment: .leading) {
                        Image(systemName: "person")
                            .padding(.leading, 8)
                            .foregroundColor(.gray)
                        TextField("Enter your name", text: $name)
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
                    .padding()
                    .frame(width: 300, height: 60)
                    .cornerRadius(10)
                    .autocapitalization(.none)
                    
                    
                    
                    Spacer().frame(height: 10)
                    
                    ZStack(alignment: .leading) {
                        Image(systemName: "person.fill")
                            .padding(.leading, 8)
                            .foregroundColor(.gray)
                        TextField("Enter your surname", text: $surname)
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
                    .padding()
                    .frame(width: 300, height: 60)
                    .cornerRadius(10)
                    .autocapitalization(.none)
                    
                    
                    Spacer().frame(height: 10)
                    
                    ZStack(alignment: .leading) {
                        Image(systemName: "pencil.line")
                            .padding(.leading, 8)
                            .foregroundColor(.gray)
                        TextField("Enter your username", text: $username)
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
                    .padding()
                    .frame(width: 300, height: 60)
                    .cornerRadius(10)
                    .autocapitalization(.none)
                    
                    if let error = usernameError {
                                    Text(error)
                                        .foregroundColor(.red)
                                        .padding(.bottom, 10)
                                }
                    else{
                        Spacer().frame(height: 30)
                    }
                    
                    NavigationLink(destination: LoginView().navigationBarBackButtonHidden(true), isActive: $isEverythingValid) {
                        EmptyView()
                    }
                    .opacity(0)
                    .background(Color.clear)
                    
                    HStack{
                        Button(action: {
                            goBack = true
                        }) {
                            Text("Back")
                                .foregroundColor(.white)
                                .frame(width: 75, height: 50)
                                .background(Color.pink)
                                .cornerRadius(10)
                        }
                        Button(action: {
                            checkFields()
                        }) {
                            Text("Next")
                                .foregroundColor(.white)
                                .frame(width: 217, height: 50)
                                .background(Color.pink)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.vertical, 5)

                    NavigationLink(destination: PasswordView(email: $email).navigationBarBackButtonHidden(true), isActive: $goBack) {
                                        EmptyView()
                                    }
                                    .opacity(0)
                                    .background(Color.clear)
                    
                }
            }
        }
    }
    
    func checkFields() {
            if username.count >= 3 && !name.isEmpty && !surname.isEmpty {
                // All fields are valid
                isEverythingValid = true
                usernameError = nil
                
                //add to database
            } else {
                // Set an error message based on the specific condition not met
                if name.isEmpty || surname.isEmpty || username.isEmpty {
                    usernameError = "All fields must be filled."
                }
                else {
                    usernameError = "Username must be at least 3 characters."
                }
                isEverythingValid = false
            }
        }
}


#Preview {
    SignUpView(email: "")
 //   PasswordView(email: .constant("ozancelebi@gmail.com"))
//    UsernameView(email: .constant("ozancelebi@gmail.com"), password: "Ozan1234.")

}
