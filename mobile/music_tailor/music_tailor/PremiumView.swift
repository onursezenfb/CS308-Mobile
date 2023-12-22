import SwiftUI

struct PremiumView: View {
    var username: String
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var themeManager: ThemeManager
    
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
            HStack(spacing: 20) {
                NavigationLink(destination: GoldView()) {
                    Text("Gold Membership")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow) // Adjust color as needed
                        .cornerRadius(10)
                    
                    // Silver Membership Button
                    NavigationLink(destination: SilverView()) {
                                        Text("Silver Membership")
                                            .foregroundColor(.white)
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color.gray) // Adjust color as needed
                                            .cornerRadius(10)
                                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
    }
    
    // Define this struct for preview in Xcode
    struct PremiumView_Previews: PreviewProvider {
        static var previews: some View {
            PremiumView(username: "SampleUser")
        }
          
    }
}
