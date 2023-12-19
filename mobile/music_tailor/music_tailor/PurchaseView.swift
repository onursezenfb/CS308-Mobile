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

    var body: some View {
        VStack (alignment: .center, spacing: 20){
            Text("Complete Your Purchase")
                
                .font(.largeTitle)
                .bold()

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
                    if allFieldsCompleted() {
                        purchaseMessage = "Purchase Complete!"
                    } else {
                        purchaseMessage = "Please fill all the card fields!"
                    }
                }
                .buttonStyle(PurchaseButtonStyle())
            }

            if let message = purchaseMessage {
                Text(message)
                    .foregroundColor(message == "Purchase Complete!" ? .green : .red)
            }

            Spacer()
        }
    }

    private func allFieldsCompleted() -> Bool {
        return !cardNumber.isEmpty && !expiryDate.isEmpty && !cvv.isEmpty && !cardHolderName.isEmpty
    }
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


#Preview {
    PurchaseView()
}
