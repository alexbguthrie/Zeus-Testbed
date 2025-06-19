//
//  SampleData.swift
//  Zeus-Testbed
//
//  Utility to generate mock file data for the Smart Files feature.
//

import Foundation

struct SampleData {
    // Keep tags for previewing UI components
    static let tags: [Tag] = [
        Tag(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, name: "Work", colorHex: "#007AFF"),
        Tag(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!, name: "Personal", colorHex: "#FF9500"),
        Tag(id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!, name: "Important", colorHex: "#FF3B30"),
        Tag(id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!, name: "Ideas", colorHex: "#34C759"),
        Tag(id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!, name: "Reference", colorHex: "#AF52DE")
    ]
    
    // FileItems now require real URLs, so we can't create meaningful static mock files here.
    // The InAppFileStorageManager.mock now creates a temporary directory.
    // Previews that need files should create them in a temporary location or use the mock manager.
    static let files: [FileItem] = []
} 