//
//  Tag.swift
//  Zeus-Testbed
//
// Model for a tag, used to categorize files.
//

import Foundation

struct Tag: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let colorHex: String?
} 