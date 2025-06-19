//
//  ExtensionStoreViewModel.swift | Zeus
//  Created by Alex Guthrie

import SwiftUI
import Combine

class ExtensionStoreViewModel: ObservableObject {
    @Published var selectedFilter: String = "All Extensions"
    let filters = ["All Extensions", "Recently Added"]
    
    @Published var apps: [ExtensionApp] = [
        ExtensionApp(
            name: "Kill Process", description: "Terminate processes sorted by CPU or memory usage",
            author: "Roland Leth", authorAvatar: "person.circle.fill", // Use user asset
            iconName: "square.fill", iconColor: Color.yellow,
            commands: 0, installs: 311_669
        ),
        ExtensionApp(
            name: "Google Chrome", description: "Search open tabs, bookmarks and history in Google Chrome.",
            author: "Codely", authorAvatar: "person.crop.circle", // Use org asset
            iconName: "globe", iconColor: Color.orange,
            commands: 7, installs: 201_770
        ),
        ExtensionApp(
            name: "Color Picker", description: "Pick and organize colors, everywhere on your Mac",
            author: "Thomas Paul Mann", authorAvatar: "person.circle", iconName: "eyedropper", iconColor: Color.pink,
            commands: 8, installs: 219_804
        ),
        ExtensionApp(
            name: "Spotify Player", description: "Spotify's most common features, now at your fingertips. Search for music and podcasts, browse your library, and control the playback.",
            author: "Artem Konovalov", authorAvatar: "person.circle.fill", iconName: "music.note", iconColor: Color.green,
            commands: 34, installs: 216_974
        ),
        // Add more as needed...
    ]
}
