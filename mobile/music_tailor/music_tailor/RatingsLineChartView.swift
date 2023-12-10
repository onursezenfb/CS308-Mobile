//
//  RatingsLineChartView.swift
//  music_tailor
//
//  Created by selin ceydeli on 12/10/23.
//

import SwiftUI
import Charts

struct DailyAverageRating: Identifiable {
    let id = UUID()
    let date: Date
    let averageRating: Double
}

struct RatingsLineChartView: View {
    @EnvironmentObject var userSession: UserSession // Access user session
    @State private var dailyAverageRatings: [DailyAverageRating] = []
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            // Chart Title
            HStack {
                Text("Daily")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.black)
                
                Text("Average Ratings")
                    .font(Font.system(size: 36, design: .rounded))
                    .bold()
                    .foregroundColor(.pink)
            }
            // Use Chart view to create a line chart
            Chart(dailyAverageRatings) { rating in
                LineMark(
                    x: .value("Date", rating.date),
                    y: .value("Average Rating", rating.averageRating)
                )
                .interpolationMethod(.catmullRom) // Smooths the line
            }
            .padding()
        }
        .onAppear {
            // Use the username from the user session when view appears
            if let username = userSession.username {
                loadChartData(for: username)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func loadChartData(for username: String) {
        guard let url = URL(string: "http://127.0.0.1:8000/api/songrating/user/\(username)/monthly-averages") else {
            alertMessage = "Invalid URL"
            showAlert = true
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.alertMessage = "Network error: \(error.localizedDescription)"
                    self.showAlert = true
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    self.alertMessage = "Error fetching data: Server returned an error"
                    self.showAlert = true
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.alertMessage = "Error fetching data: Data was nil"
                    self.showAlert = true
                }
                return
            }
            
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    let ratings = jsonResult.compactMap { (key, value) -> DailyAverageRating? in
                        guard let date = dateFormatter.date(from: key),
                              let averageRating = Double(value) else {
                            return nil
                        }
                        return DailyAverageRating(date: date, averageRating: averageRating)
                    }.sorted(by: { $0.date < $1.date })
                    
                    DispatchQueue.main.async {
                        self.dailyAverageRatings = ratings
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.alertMessage = "Error parsing data: \(error.localizedDescription)"
                    self.showAlert = true
                }
            }
        }
        task.resume()
    }


}
