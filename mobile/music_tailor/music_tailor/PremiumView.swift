import SwiftUI

struct PremiumView: View {
    var username: String
    @EnvironmentObject var userSession: UserSession


    // Define a fixed width for the buttons
    private let buttonWidth: CGFloat = 190 // You can adjust this value as needed

    var body: some View {
        VStack {
            // Greeting and Title
            Text("Hello, \(userSession.username ?? "User")! Tailor Your Tunes to Perfection with Music Tailor Premium!")
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
                .padding()
            
            // Subtitle
            Text("Choose one to see all of the details!")
                .font(.headline)
                .padding(.bottom, 20)
            
            // Membership Buttons
            VStack {
                HStack(spacing: 20) {
                    // Gold Membership Button
                    NavigationLink(destination: GoldView()) {
                        Text("Gold Membership")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: buttonWidth) // Apply fixed width
                            .background(Color.yellow)
                            .cornerRadius(10)
                    }

                    // Silver Membership Button
                    NavigationLink(destination: SilverView()) {
                        Text("Silver Membership")
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: buttonWidth) // Apply fixed width
                            .background(Color.gray)
                            .cornerRadius(10)
                    }
                }

                // Free Membership Button
                NavigationLink(destination: FreeView()) {
                    Text("Free Membership")
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: buttonWidth) // Apply fixed width
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                .padding(.top, 20) // Add space above the Free button
            }
            .padding(.horizontal, 20) // Adjust the horizontal padding if needed
        }
    }
    
    // Define this struct for preview in Xcode
    struct PremiumView_Previews: PreviewProvider {
        static var previews: some View {
            PremiumView(username: "SampleUser")
        }
    }
}
