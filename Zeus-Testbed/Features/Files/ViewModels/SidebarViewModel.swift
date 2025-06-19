//
//  SidebarViewModel.swift
//  Zeus-Testbed
//
// Manages the state for the sidebar, including the list of tags and smart groups, and the current selection.
//

import Foundation
import SwiftUI
import Combine

class SidebarViewModel: ObservableObject {
    @Published var smartGroups: [SmartGroup] = []
    @Published var tags: [Tag] = []
    @Published var selectedSmartGroupID: String?
    @Published var selectedTagID: UUID?
    
    private var storage: FileStorageProvider
    private var cancellables = Set<AnyCancellable>()
    
    init(storage: FileStorageProvider) {
        self.storage = storage
        setupSmartGroups()
        loadTags()
        
        // Set default selection
        selectedSmartGroupID = smartGroups.first?.id
        
        NotificationCenter.default.publisher(for: .didChangeFileData)
            .sink { [weak self] _ in
                self?.loadTags()
            }
            .store(in: &cancellables)
    }
    
    private func setupSmartGroups() {
        self.smartGroups = SmartGroup.all
    }
    
    private func loadTags() {
        self.tags = (try? storage.fetchTags().sorted(by: { $0.name < $1.name })) ?? []
    }
}

// MARK: - Smart Groups
struct SmartGroup: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
    
    static let all = [
        SmartGroup(id: "all", name: "All Files", icon: "square.grid.2x2.fill"),
        SmartGroup(id: "recents", name: "Recents", icon: "clock.fill"),
        SmartGroup(id: "favorites", name: "Favorites", icon: "star.fill")
    ]
}

// MARK: - Preview
#if DEBUG
extension SidebarViewModel {
    static var mock: SidebarViewModel {
        let storage = InAppFileStorageManager.mock
        return SidebarViewModel(storage: storage)
    }
}
#endif

// Helper for color hex to Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 204, 204, 204)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 
