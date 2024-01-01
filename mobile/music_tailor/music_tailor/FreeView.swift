//
//  FreeView.swift
//  music_tailor
//
//  Created by selin ceydeli on 12/26/23.
//

import SwiftUI

struct FreeView: View {
    @State private var subscription: String = ""
    @State private var rateLimit: String = ""
    @State private var navigateToHome = false
    @State private var showAlert = false // State variable for showing alert
    @EnvironmentObject var userSession: UserSession
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                Text("Music Tailor")
                    .font(.largeTitle)
                    .padding()

                Text("FREE")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding()

                VStack(alignment: .leading, spacing: 10) {
                    FeatureView3(feature: "Recommendations & Analysis", description: "See personal recommendations and analysis tailored for you.")
                    FeatureView3(feature: "Add Friends", description: "Manage and add friends.")
                    FeatureView3(feature: "Limited Rating", description: "Use your rating option for a limited of times.")
                    FeatureView3(feature: "Offline Mode", description: "Download a limited number of songs for offline listening.")
                }

                Button(action: {
                            if userSession.subscription == "Silver" || userSession.subscription == "Gold" {
                                showAlert = true // Show alert for downgrading
                            } else {
                                downgradeAndNavigate()
                            }
                        })  {
                    Text("Continue for free!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .alert(isPresented: $showAlert) {
                                Alert(
                                    title: Text("Downgrade to Free"),
                                    message: Text("Are you sure you want to downgrade your plan?"),
                                    primaryButton: .destructive(Text("Yes")) {
                                        downgradeAndNavigate()
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                            .padding()
                
                NavigationLink(destination: PremiumView(), isActive: $navigateToHome) {
                    EmptyView()
                }
            }
            .padding()
        }
    }
    
    private func downgradeAndNavigate() {
        userSession.updateSubscription(to: "Free")
        userSession.updateRateLimit(to: "100")
        subscription = "Free"
        rateLimit = "100"
        updateUserInformation()
        userSession.fetchAndUpdateUserData() // Fetch the latest user data
        navigateToHome = true
    }
    
    private func updateUserInformation() {
        guard let url = URL(string: "http://127.0.0.1:8000/api/users/\(userSession.username ?? "")") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let updatedUser = FreeUser(
            subscription: subscription, // Use the updated subscription here
            rate_limit: rateLimit
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
                    DispatchQueue.main.async {
                        print("Successfull subscription plan update!")
                    }
                } else {
                    print("Error: Update failed with status code \(httpResponse.statusCode)")
                }
            }
            task.resume()
        } catch {
            print("Error encoding user data")
        }
    }
}

// User struct for encoding
struct FreeUser: Codable {
    var subscription: String
    var rate_limit: String
}

struct FeatureView3: View {
    var feature: String
    var description: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(feature)
                .font(.headline)
                .foregroundColor(.blue)
            Text(description)
                .font(.subheadline)
        }
        .padding()
        .background(Color.black.opacity(0.1))
        .cornerRadius(8)
    }
}


struct FreeView_Previews: PreviewProvider {
    static var previews: some View {
        FreeView().environmentObject(UserSession.mock) // Add UserSession.mock for preview
    }
}
