//
//  FileItem.swift
//  Zeus-Testbed
//
//  Model representing a file or folder in the Smart Files system.
//

import Foundation

/// Enum representing the type of file or folder.
enum FileType: String, Codable, CaseIterable {
    case folder
    case text
    case markdown
    case code
    case image
    case pdf
    case other

    static func from(url: URL) -> FileType {
        // Determine file type based on extension or other properties
        // This is a simplified example
        let fileExtension = url.pathExtension.lowercased()
        switch fileExtension {
        case "txt": return .text
        case "md": return .markdown
        case "swift", "js", "py", "html": return .code
        case "png", "jpg", "jpeg", "gif": return .image
        case "pdf": return .pdf
        default: return .other
        }
    }
}

/// Model for a file or folder, including metadata and version info.
struct FileItem: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var type: FileType
    var url: URL?
    var size: Int64?
    var modifiedAt: Date
    var isFavorite: Bool
    var tags: [Tag]
    var isProtected: Bool
    var createdAt: Date
    var accessedAt: Date?
    var versions: [FileVersion]?
    var isFolder: Bool { type == .folder }
    var parentID: UUID?
    
    init(id: UUID = UUID(),
         name: String,
         type: FileType,
         url: URL? = nil,
         size: Int64? = 0,
         modifiedAt: Date = Date(),
         isFavorite: Bool = false,
         isProtected: Bool = false,
         tags: [Tag] = [],
         createdAt: Date = Date(),
         accessedAt: Date? = nil,
         versions: [FileVersion]? = nil,
         parentID: UUID? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.url = url
        self.size = size
        self.modifiedAt = modifiedAt
        self.isFavorite = isFavorite
        self.isProtected = isProtected
        self.tags = tags
        self.createdAt = createdAt
        self.accessedAt = accessedAt
        self.versions = versions
        self.parentID = parentID
    }

    // Custom decoder to handle missing `isProtected` key
    enum CodingKeys: String, CodingKey {
        case id, name, type, url, size, modifiedAt, isFavorite, tags, isProtected, createdAt, accessedAt, versions, parentID
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(FileType.self, forKey: .type)
        url = try container.decodeIfPresent(URL.self, forKey: .url)
        size = try container.decodeIfPresent(Int64.self, forKey: .size)
        modifiedAt = try container.decode(Date.self, forKey: .modifiedAt)
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        tags = try container.decodeIfPresent([Tag].self, forKey: .tags) ?? []
        isProtected = try container.decodeIfPresent(Bool.self, forKey: .isProtected) ?? false
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        accessedAt = try container.decodeIfPresent(Date.self, forKey: .accessedAt)
        versions = try container.decodeIfPresent([FileVersion].self, forKey: .versions)
        parentID = try container.decodeIfPresent(UUID.self, forKey: .parentID)
    }

    // Convenience initializer for creating a FileItem from a URL
    init(url: URL) {
        let name = url.lastPathComponent
        let type = FileType.from(url: url)
        let modifiedAt = (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date()
        let size = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize.map(Int64.init) ?? 0

        self.init(
            name: name,
            type: type,
            url: url,
            size: size,
            modifiedAt: modifiedAt,
            isProtected: false
        )
    }
    
    var sizeString: String {
        ByteCountFormatter.string(fromByteCount: size ?? 0, countStyle: .file)
    }
} 