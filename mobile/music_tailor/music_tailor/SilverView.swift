//
//  SilverView.swift
//  music_tailor
//
//  Created by Şimal on 20.12.2023.
//

import SwiftUI

struct SilverView: View {
    @EnvironmentObject var userSession: UserSession
    @State private var navigateToPurchase = false
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                Text("Music Tailor")
                    .font(.largeTitle)
                    .padding()

                Text("SILVER")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .padding()

                VStack(alignment: .leading, spacing: 10) {
                    FeatureView2(feature: "Playlist Management", description: "Create, edit, and organize personal playlists.")
                    FeatureView2(feature: "Sound Equalizer Settings", description: "Customize sound profiles for different music genres.")
                    FeatureView2(feature: "Exclusive Radio Stations", description: "Access to a variety of genre-specific online radio stations.")
                    FeatureView2(feature: "Offline Mode", description: "Download a limited number of songs for offline listening.")
                }
                Button(action: {
                                   self.navigateToPurchase = true
                               }) {
                                   Text("Purchase for $3.99 a month")
                                       .font(.headline)
                                       .foregroundColor(.white)
                                       .padding()
                                       .frame(maxWidth: .infinity)
                                       .background(Color.gray)
                                       .cornerRadius(10)
                               }
                               .padding()
                // Hidden NavigationLink
                NavigationLink(destination: PurchaseView(subscriptionType: "Silver"), isActive: $navigateToPurchase) {
                            EmptyView()
                        }
            }
            .padding()
        }
    }
}

struct FeatureView2: View {
    var feature: String
    var description: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(feature)
                .font(.headline)
                .foregroundColor(.gray)
            Text(description)
                .font(.subheadline)
        }
        .padding()
        .background(Color.black.opacity(0.1))
        .cornerRadius(8)
    }
}


#Preview {
    SilverView()
}
