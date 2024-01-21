//
//  PurchaseView.swift
//  music_tailor
//
//  Created by Şimal on 20.12.2023.
//

import SwiftUI

struct PurchaseView: View {
    @State private var cardNumber = ""
    @State private var expiryDate = ""
    @State private var cvv = ""
    @State private var cardHolderName = ""
    @State private var purchaseMessage: String?
    @State private var navigateToContentView = false
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userSession: UserSession
    @State private var subscription: String = ""
    @State private var rateLimit: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var subscriptionType: String
    var rateLimitType: String
    init(subscriptionType: String, rateLimitType: String) {
        self.subscriptionType = subscriptionType
        self.rateLimitType = rateLimitType
    }


    var body: some View {
        VStack (alignment: .center, spacing: 20){
            Text("Purchase \(subscriptionType) Membership")
                            .font(.headline)

            Spacer()
            
            CreditCardView(cardNumber: $cardNumber, expiryDate: $expiryDate, cardHolderName: $cardHolderName)
                .padding()

            Form {
                Section(header: Text("Card Details")) {
                    TextField("Card Number", text: $cardNumber)
                    TextField("Expiry Date (MM/YY)", text: $expiryDate)
                    TextField("CVV", text: $cvv)
                    TextField("Card Holder Name", text: $cardHolderName)
                }

                Button("Confirm Purchase") {
                                    let validationResponse = validateInputs()
                                    if validationResponse.isValid {
                                        // Proceed with the purchase
                                        // ...
                                        purchaseMessage = "Purchase Complete!"
                                        subscription = subscriptionType
                                        rateLimit = rateLimitType
                                        userSession.updateSubscription(to: subscriptionType)
                                        userSession.updateRateLimit(to: rateLimit)
                                        updateUserInformation()
                                        userSession.fetchAndUpdateUserData() // Fetch the latest user data
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            self.presentationMode.wrappedValue.dismiss()
                                        }
                                    } else {
                                        self.alertMessage = validationResponse.message
                                        self.showAlert = true
                                    }
                                }
                                .buttonStyle(PurchaseButtonStyle())
            }
            .alert(isPresented: $showAlert) {
                        Alert(title: Text("Alert"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }

            if let message = purchaseMessage {
                Text(message)
                    .foregroundColor(message == "Purchase Complete!" ? .green : .red)
            }

            Spacer()
            if navigateToContentView {
                NavigationLink(destination: ContentView(), isActive: $navigateToContentView) {
                                EmptyView()
                            }
                        }
                
        }
    }
    
    private func validateInputs() -> (isValid: Bool, message: String) {
            // Check if all fields are completed
            if cardNumber.isEmpty || expiryDate.isEmpty || cvv.isEmpty || cardHolderName.isEmpty {
                return (false, "Please fill all the areas!")
            }

            var errorMessages: [String] = []

            // Validate card number
            if cardNumber.count != 16 || !cardNumber.allSatisfy({ $0.isNumber }) {
                errorMessages.append("Please enter a valid card number!")
            }

            // Validate expiry date
            let expiryComponents = expiryDate.split(separator: "/").map(String.init)
            if expiryComponents.count != 2 || !expiryComponents.allSatisfy({ $0.count == 2 && $0.allSatisfy({ $0.isNumber }) }) {
                errorMessages.append("Please enter a valid expiration date!")
            }

            // Validate CVV
            if cvv.count != 3 || !cvv.allSatisfy({ $0.isNumber }) {
                errorMessages.append("Please enter a valid CVV!")
            }

            // Validate card holder name
            if cardHolderName.contains(where: { $0.isNumber }) {
                errorMessages.append("Please enter a valid card holder name!")
            }

            // Check if there's more than one error
            if errorMessages.count > 1 {
                return (false, "Please check your inputs again!")
            } else if let errorMessage = errorMessages.first {
                return (false, errorMessage)
            }

            return (true, "")
        }

    private func allFieldsCompleted() -> Bool {
        return !cardNumber.isEmpty && !expiryDate.isEmpty && !cvv.isEmpty && !cardHolderName.isEmpty
    }
    
    private func updateUserInformation() {
        guard let url = URL(string: "http://127.0.0.1:8000/api/users/\(userSession.username ?? "")") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let updatedUser = PurchaseUser(
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
                        self.alertMessage = "Your subscription plan is successfully updated!"
                        self.showAlert = true
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
struct PurchaseUser: Codable {
    var subscription: String
    var rate_limit: String
}


struct CreditCardView: View {
    @Binding var cardNumber: String
    @Binding var expiryDate: String
    @Binding var cardHolderName: String
    

    var body: some View {
        VStack {
            // Card Number
            
            HStack {
                Text("Card Number:")
                Spacer()
                Text(formatCardNumber(number: cardNumber))
            }

            // Expiry Date
            HStack {
                Text("Expiry Date:")
                Spacer()
                Text(expiryDate)
            }

            // Card Holder's Name
            HStack {
                Text("Card Holder:")
                Spacer()
                Text(cardHolderName.uppercased())
            }
        }
        .padding()
        .frame(width: 300, height: 180)
        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .top, endPoint: .bottom))
        .cornerRadius(15)
        .foregroundColor(.white)
        .font(.headline)
    }

    private func formatCardNumber(number: String) -> String {
        var formattedNumber = ""
        for (index, character) in number.enumerated() {
            if index % 4 == 0 && index > 0 {
                formattedNumber.append(" ")
            }
            formattedNumber.append(character)
        }
        return formattedNumber
    }
}


struct PurchaseButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.pink, Color.purple]), startPoint: .leading, endPoint: .trailing))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}



// Implement other custom views as needed


struct PurchaseView_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseView(subscriptionType: "Free", rateLimitType: "100") // Provide a default value for previews
    }
}
