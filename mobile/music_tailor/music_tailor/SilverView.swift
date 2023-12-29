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
    enum AlertType {
            case silverMember, downgradeToSilver, none
        }
    @State private var alertType: AlertType = .none

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
                    if userSession.subscription == "Silver" {
                        alertType = .silverMember
                    } else if userSession.subscription == "Gold" {
                        alertType = .downgradeToSilver
                    } else {
                        navigateToPurchase = true
                    }
                }) {
                    Text("Purchase for $8.99 a month")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .cornerRadius(10)
                }
                .alert(isPresented: Binding<Bool>(
                    get: { alertType != .none },
                    set: { if !$0 { alertType = .none } }
                )) {
                    switch alertType {
                    case .silverMember:
                        return Alert(title: Text("Already a Member"), message: Text("You are already a Silver member!"), dismissButton: .default(Text("OK")))
                    case .downgradeToSilver:
                        return Alert(
                            title: Text("Downgrade to Silver"),
                            message: Text("Are you sure you want to downgrade to Silver?"),
                            primaryButton: .destructive(Text("Yes")) {
                                navigateToPurchase = true
                            },
                            secondaryButton: .cancel()
                        )
                    default:
                        return Alert(title: Text("Error"), message: Text("Unexpected error occurred."))
                    }
                }

                NavigationLink(destination: PurchaseView(subscriptionType: "Silver", rateLimitType: "1000"), isActive: $navigateToPurchase) {
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


struct SilverView_Previews: PreviewProvider {
    static var previews: some View {
        SilverView().environmentObject(UserSession.mock)
    }
}
