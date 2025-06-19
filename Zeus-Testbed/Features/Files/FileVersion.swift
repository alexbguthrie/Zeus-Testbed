//
//  FileVersion.swift
//  Zeus-Testbed
//
//  Model representing a version of a file in the Smart Files system.
//

import Foundation

/// Model for a file version, tracking metadata for text/code files.
struct FileVersion: Codable, Hashable {
    let id: UUID
    let timestamp: Date
    let username: String
    let changelog: String
    
    init(id: UUID = UUID(), timestamp: Date = Date(), username: String, changelog: String) {
        self.id = id
        self.timestamp = timestamp
        self.username = username
        self.changelog = changelog
    }
} 