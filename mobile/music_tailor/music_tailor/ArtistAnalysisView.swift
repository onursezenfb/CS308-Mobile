//
//  ArtistAnalysisView.swift
//  music_tailor
//
//  Created by selin ceydeli on 12/10/23.
//

import SwiftUI
import Charts

struct PerformerRating: Identifiable {
    let id = UUID()
    let name: String
    let averageRating: Double
}

struct ArtistAnalysisView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var performerNamesInput: String = ""
    @State private var performerRatings: [PerformerRating] = []
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            
            HStack {
                Text("Compare")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.black)
                
                Text("Artists")
                    .font(Font.system(size: 36, design: .rounded))
                    .bold()
                    .foregroundColor(themeManager.themeColor)
            }
            
            // Description Text
            Text("Discover how your favorite artists compare! 🌟")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top)

            Text("Enter artist names, separated by commas, to see their average ratings.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom)

            // Text Field for Entering Performer Names
            TextField("Enter Performer Names", text: $performerNamesInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
    
            // Update Button
            Button(action: loadPerformerRatings) {
                Text("Load Ratings")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(themeManager.themeColor)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(performerNamesInput.isEmpty)

            if isLoading {
                ProgressView()
            } else {
                Chart(performerRatings) { rating in
                    BarMark(
                        x: .value("Performer", rating.name),
                        y: .value("Average Rating", rating.averageRating)
                    )
                    .foregroundStyle(by: .value("Performer", rating.name))
                }
                .frame(height: 300)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func loadPerformerRatings() {
        isLoading = true
        let performerNames = performerNamesInput.components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        let url = URL(string: "http://127.0.0.1:8000/api/performerrating/average-performer-ratings")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = ["artistNames": performerNames, "months": 6] // Default to the last 6 months
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            self.alertMessage = "Error encoding request: \(error.localizedDescription)"
            self.showAlert = true
            self.isLoading = false
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }
            if let error = error {
                self.alertMessage = "Network error: \(error.localizedDescription)"
                self.showAlert = true
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                self.alertMessage = "Error fetching data: Server returned an error"
                self.showAlert = true
                return
            }

            guard let data = data else {
                self.alertMessage = "Error fetching data: Data was nil"
                self.showAlert = true
                return
            }

            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data) as? [String: String] {
                    let ratings = jsonResult.compactMap { key, value -> PerformerRating? in
                        guard let averageRating = Double(value) else { return nil }
                        return PerformerRating(name: key, averageRating: averageRating)
                    }
                    DispatchQueue.main.async {
                        self.performerRatings = ratings
                    }
                } else {
                    self.alertMessage = "Error parsing data: Invalid format"
                    self.showAlert = true
                }
            } catch {
                self.alertMessage = "Error parsing data: \(error.localizedDescription)"
                self.showAlert = true
            }
        }.resume()
    }
}

struct PerformerRatingView_Previews: PreviewProvider {
    static var previews: some View {
        ArtistAnalysisView()
    }
}
