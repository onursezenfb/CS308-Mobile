//
//  FreeView.swift
//  music_tailor
//
//  Created by selin ceydeli on 12/26/23.
//

import SwiftUI

struct FreeView: View {
    @State private var navigateToHome = false
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
                    FeatureView3(feature: "Recommendations & Analaysis", description: "See personal recommendations and analysis tailored for you.")
                    FeatureView3(feature: "Add Friends", description: "Manage and add friends.")
                    FeatureView3(feature: "Limited Rating", description: "Use your rating option for a limited of times.")
                    FeatureView3(feature: "Offline Mode", description: "Download a limited number of songs for offline listening.")
                }

                Button(action: {
                            userSession.updateSubscription(to: "Free")
                            presentationMode.wrappedValue.dismiss()
                        })  {
                    Text("Continue for free!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                NavigationLink(destination: ContentView(), isActive: $navigateToHome) {
                    EmptyView()
                }
            }
            .padding()
        }
    }
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
