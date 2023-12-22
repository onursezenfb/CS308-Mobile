//
//  ChangeThemeView.swift
//  music_tailor
//
//  Created by selin ceydeli on 12/22/23.
//

import SwiftUI

struct ChangeThemeView: View {
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedTheme: String
   
    // A dictionary to map theme names to actual colors
    let themeColors = [
        "Pink": Color.pink,
        "Red": Color.red,
        "Blue": Color.blue,
        "Green": Color.green,
        "Yellow": Color.yellow,
        "Purple": Color.purple 
    ]

    
    init() {
        _selectedTheme = State(initialValue: UserSession().theme ?? "Pink") // Default value from UserSession
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Ombre circles in each corner
                Circle()
                    .fill(currentThemeGradient)
                    .frame(width: 300, height: 300)
                    .position(x: 0, y: 0) // Top left corner
                
                Circle()
                    .fill(currentThemeGradient)
                    .frame(width: 300, height: 300)
                    .position(x: UIScreen.main.bounds.width, y: 0) // Top right corner
                
                Circle()
                    .fill(currentThemeGradient)
                    .frame(width: 300, height: 300)
                    .position(x: 0, y: UIScreen.main.bounds.height) // Bottom left corner
                
                Circle()
                    .fill(currentThemeGradient)
                    .frame(width: 300, height: 300)
                    .position(x: UIScreen.main.bounds.width, y: UIScreen.main.bounds.height) // Bottom right corner
                
                VStack(spacing: 20) {
                    Spacer().frame(height: 125)
                    
                    // Title
                    HStack {
                        Text("Change")
                            .font(Font.system(size: 36, design: .rounded))
                            .bold()
                            .foregroundColor(themeManager.themeColor) // Use theme color
                        Text("Theme")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.black)
                    }
                    
                    // Theme Selection Grid
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                        ForEach(themeColors.keys.sorted(), id: \.self) { themeName in
                            Button(action: {
                                self.selectedTheme = themeName
                            }) {
                                VStack {
                                    Circle()
                                        .fill(themeColors[themeName] ?? .pink)
                                        .frame(width: 60, height: 60)
                                    Text(themeName)
                                        .font(.caption)
                                }
                            }
                            .padding()
                            .background(selectedTheme == themeName ? Color.gray.opacity(0.3) : Color.clear)
                            .cornerRadius(5)
                        }
                    }
                    .padding()
                    
                    // Submit button
                    Button(action: {
                        applyTheme()
                    }) {
                        Text("Apply Theme")
                            .foregroundColor(.white)
                            .padding()
                            .background(themeManager.themeColor) // Use theme color
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
            }
        }
        .navigationBarTitle(Text(""), displayMode: .inline)
        .onAppear {
            // Optionally update the theme if it's changed elsewhere in the app
            selectedTheme = userSession.theme ?? "Pink"
        }
    }
    
    private func updateTheme() {
        guard let url = URL(string: "http://127.0.0.1:8000/api/users/\(userSession.username ?? "")") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let userUpdate = UserUpdate(theme: selectedTheme)

        do {
            let jsonData = try JSONEncoder().encode(userUpdate)
            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error updating theme: \(error)")
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Error: Invalid response from server")
                    return
                }

                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        print("Theme updated successfully")
                        // Handle successful theme update
                    }
                } else {
                    print("Error: Update failed with status code \(httpResponse.statusCode)")
                }
            }
            task.resume()
        } catch {
            print("Error encoding theme update data")
        }
    }

    // This function is called when the "Apply Theme" button is clicked
    private func applyTheme() {
        themeManager.applyTheme(named: selectedTheme)
        updateTheme() // Call to update the theme on the server
        userSession.theme = selectedTheme // Update the theme in UserSession
    }

    var currentThemeGradient: LinearGradient {
        LinearGradient(gradient: Gradient(colors: [themeManager.themeColor, themeManager.themeColor.opacity(0)]), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

// UserUpdate struct to encode only the theme information
struct UserUpdate: Codable {
    var theme: String
}

// Preview
struct ChangeThemeView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeThemeView().environmentObject(ThemeManager())
    }
}
