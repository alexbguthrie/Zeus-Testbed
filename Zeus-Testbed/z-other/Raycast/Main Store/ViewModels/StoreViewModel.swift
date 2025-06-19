//
//  AppStoreViewModel.swift | Zeus
//  Alex Guthrie

import Foundation
import Combine

class StoreViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var apps: [StoreApp] = [
        StoreApp(name: "Zen Browser", description: "Search and open tabs from bookmarks and history in Zen Browser.", author: "Lucas", imageName: "circle.grid.cross"), // replace with your images
        StoreApp(name: "PastePal", description: "Clipboard manager for Mac power users.", author: "DevMate", imageName: "doc.on.clipboard"),
        StoreApp(name: "Pomodoro Timer", description: "A simple, effective Pomodoro timer.", author: "FocusLab", imageName: "timer"),
        StoreApp(name: "Weather Now", description: "Instant weather updates, right in Raycast.", author: "Weatherly", imageName: "cloud.sun")
    ]
    
    var filteredApps: [StoreApp] {
        guard !searchText.isEmpty else { return apps }
        return apps.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
            || $0.description.localizedCaseInsensitiveContains(searchText)
            || $0.author.localizedCaseInsensitiveContains(searchText)
        }
    }
}
