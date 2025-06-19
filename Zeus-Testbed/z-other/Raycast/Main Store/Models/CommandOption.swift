//
//  CommandOption.swift | Zeus
//  Alex Guthrie
//
//  Command Options, for the Search Bar
//
import Foundation

struct CommandOption: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let shortcut: String?
    let action: () -> Void
}
