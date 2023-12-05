//
//  AddFriendView.swift
//  music_tailor
//
//  Created by Şimal on 2.12.2023.
//

import SwiftUI

struct AddFriendView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Back")
                    }
                    .foregroundColor(.pink)
                    .padding()
                }
                Spacer()
            }

            Text("Add a Friend")
                .font(.largeTitle)
                .bold()
                .padding()
                .foregroundColor(.pink)

            SearchBar(text: $searchText)
                .padding()

            // List of search results or potential friends to add
            List {
                ForEach(0..<10) { item in
                    Text("Friend \(item)")
                }
            }
            Spacer()
        }
    }
}

// The rest of your code remains the same


struct SearchBar: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UISearchBarDelegate {
        var parent: SearchBar

        init(_ parent: SearchBar) {
            self.parent = parent
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            parent.text = searchText
        }
    }
}

