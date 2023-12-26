//
//  GoldView.swift
//  music_tailor
//
//  Created by Şimal on 19.12.2023.
//

import SwiftUI

struct GoldView: View {
    @EnvironmentObject var userSession: UserSession
    @State private var navigateToPurchase = false
    var body: some View {
        
        ScrollView {
            VStack(alignment: .center, spacing: 20) {
                Text("Music Tailor")
                    .font(.largeTitle)
                    .padding()

                Text("GOLD")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                    .padding()

                VStack(alignment: .leading, spacing: 10) {
                    FeatureView(feature: "All Silver Features", description: "Includes everything in the Silver package.")
                    FeatureView(feature: "Advanced Playlist Collaboration", description: "Share and collaborate on playlists with friends or the MusicTailor community.")
                    FeatureView(feature: "Unlimited Offline Access", description: "Download an unlimited number of songs for offline playback.")
                    FeatureView(feature: "Concert and Event Alerts", description: "Notifications about concerts and events based on user preferences.")
                }

                Button(action: {
                    self.navigateToPurchase = true
                }) {
                    Text("Purchase for $8.99 a month")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow)
                        .cornerRadius(10)
                }
                .padding()
                NavigationLink(destination: PurchaseView(subscriptionType: "Gold"), isActive: $navigateToPurchase) {
                    EmptyView()
                }
            }
            .padding()
        }
    }
}

struct FeatureView: View {
    var feature: String
    var description: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(feature)
                .font(.headline)
                .foregroundColor(.yellow)
            Text(description)
                .font(.subheadline)
        }
        .padding()
        .background(Color.black.opacity(0.1))
        .cornerRadius(8)
    }
}

struct GoldView_Previews: PreviewProvider {
    static var previews: some View {
        GoldView()
    }
}
