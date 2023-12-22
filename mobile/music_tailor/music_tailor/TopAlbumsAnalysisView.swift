import SwiftUI
import Charts

struct AlbumAnalysis: Identifiable, Codable {
    let id = UUID()
    let name: String
    let image_url: String
    let average_rating: String
    
    // Computed property to convert string to Double
    var averageRating: Double? {
        return Double(average_rating)
    }
}

struct TopAlbumsAnalysisView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var userSession: UserSession
    @State private var selectedEra: String = "20s" // Default era
    @State private var topAlbums: [AlbumAnalysis] = []
    @State private var showAlert = false
    @State private var alertMessage = ""
    let eras = ["50s", "60s", "70s", "80s", "90s", "20s"]

    var body: some View {
        VStack {
            // Chart Title
            HStack {
                Text("Your Top")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.black)
                
                Text("Albums by Era")
                    .font(Font.system(size: 36, design: .rounded))
                    .bold()
                    .foregroundColor(themeManager.themeColor)
            }
            VStack(alignment: .leading) {
                Text("Select an Era")
                    .font(.headline)
                    .foregroundColor(themeManager.themeColor)
                    .padding([.top, .leading]) // Add padding to top and leading edges

                Picker("Select Era", selection: $selectedEra) {
                    ForEach(eras, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal) // Apply horizontal padding to the picker for consistent spacing
            }
            .padding(.horizontal) // Apply horizontal padding to the entire VStack if needed
            
            // Define an array of colors
            let barColors: [Color] = [.red, .green, .blue, .orange, .purple, .pink, .yellow, .gray, .cyan, .mint]

            Chart {
                ForEach(Array(topAlbums.enumerated()), id: \.element.id) { index, album in
                    if let averageRating = album.averageRating {
                        BarMark(
                            x: .value("Album Name", album.name),
                            y: .value("Average Rating", averageRating)
                        )
                        .foregroundStyle(barColors[index % barColors.count]) // Cycle through the array of colors
                        .annotation {
                            Text("\(averageRating, specifier: "%.2f")")
                                .font(.caption)
                        }
                    }
                }
            }
            .frame(height: 300) // Set the height for the chart

            // Load data when the selected era changes
            .onChange(of: selectedEra) { newEra in
                loadTopAlbums(for: newEra)
            }
        }
        .onAppear {
            // Load the initial data for the default era
            loadTopAlbums(for: selectedEra)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func loadTopAlbums(for era: String) {
        guard let username = userSession.username, !username.isEmpty else {
            self.alertMessage = "Username is not set"
            self.showAlert = true
            return
        }

        guard let url = URL(string: "http://127.0.0.1:8000/api/albumrating/top-rated/\(username)/\(era)") else {
            self.alertMessage = "Invalid URL"
            self.showAlert = true
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
                let decodedAlbums = try JSONDecoder().decode([AlbumAnalysis].self, from: data)
                DispatchQueue.main.async {
                    self.topAlbums = decodedAlbums
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

// Preview in Xcode
struct TopAlbumsAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        TopAlbumsAnalysisView()
            .environmentObject(UserSession()) // Provide a UserSession object for the preview
    }
}
