//
//  AppItem.swift | Zeus
//  Alex Guthrie
import SwiftUI
import Foundation

struct StoreApp: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let author: String
    let imageName: String // Use systemName or asset name
}

struct ExtensionApp: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let author: String
    let authorAvatar: String // Image asset or SF Symbol
    let iconName: String     // App icon asset or SF Symbol
    let iconColor: Color
    let commands: Int
    let installs: Int
}
