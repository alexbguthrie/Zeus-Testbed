import Foundation
import Combine
import SwiftUI

class InAppFileStorageManager: FileStorageProvider, ObservableObject {
    private let fileManager: FileManager
    private let rootDirectory: URL
    let filesDirectory: URL
    let metadataDirectory: URL

    convenience init() {
        self.init(directoryName: "smart_files")
    }

    init(directoryName: String) {
        self.fileManager = FileManager.default
        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        self.rootDirectory = appSupportURL.appendingPathComponent("com.zeus-testbed.smartfiles")
        self.filesDirectory = rootDirectory.appendingPathComponent(directoryName)
        self.metadataDirectory = rootDirectory.appendingPathComponent("metadata")
        createDirectoriesIfNeeded()
    }

    func importFiles(from result: Result<[URL], Error>, notificationService: NotificationService) {
        switch result {
        case .success(let urls):
            var importCount = 0
            for sourceURL in urls {
                // Gain access to the security-scoped resource
                guard sourceURL.startAccessingSecurityScopedResource() else {
                    print("Could not access security scoped resource for url: \(sourceURL)")
                    continue
                }

                let destinationURL = self.filesDirectory.appendingPathComponent(sourceURL.lastPathComponent)
                
                do {
                    // Copy the file to the app's sandbox
                    try fileManager.copyItem(at: sourceURL, to: destinationURL)
                    
                    // Create the metadata file
                    let file = FileItem(url: destinationURL)
                    try saveFile(file)
                    importCount += 1
                    
                } catch {
                    notificationService.show(type: .error, message: "Could not import \(sourceURL.lastPathComponent).")
                }
                
                // Release the resource
                sourceURL.stopAccessingSecurityScopedResource()
            }
            if importCount > 0 {
                notificationService.show(type: .success, message: "Successfully imported \(importCount) file\(importCount > 1 ? "s" : "").")
            }
        case .failure(let error):
            notificationService.show(type: .error, message: "Failed to import files: \(error.localizedDescription)")
        }
    }

    // MARK: - Directory Management
    private func createDirectoriesIfNeeded() {
        try? fileManager.createDirectory(at: filesDirectory, withIntermediateDirectories: true, attributes: nil)
        try? fileManager.createDirectory(at: metadataDirectory, withIntermediateDirectories: true, attributes: nil)
    }

    // MARK: - File Operations
    func fetchFiles() throws -> [FileItem] {
        let urls = try fileManager.contentsOfDirectory(at: metadataDirectory, includingPropertiesForKeys: nil)
        return try urls.filter { $0.pathExtension == "json" && $0.lastPathComponent.starts(with: "file_") }.map { url in
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(FileItem.self, from: data)
        }
    }

    func saveFile(_ file: FileItem) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(file)
        let url = metadataDirectory.appendingPathComponent("file_\(file.id.uuidString).json")
        try data.write(to: url)
    }

    func deleteFiles(withIDs ids: Set<UUID>) throws {
        for id in ids {
            let metadataUrl = metadataDirectory.appendingPathComponent("file_\(id.uuidString).json")
            if fileManager.fileExists(atPath: metadataUrl.path) {
                // First, decode the metadata to find the file's actual URL
                let data = try Data(contentsOf: metadataUrl)
                let file = try JSONDecoder().decode(FileItem.self, from: data)
                
                // Delete the actual file if the URL exists
                if let fileUrl = file.url, fileManager.fileExists(atPath: fileUrl.path) {
                    try fileManager.removeItem(at: fileUrl)
                }
                
                // Delete the metadata file
                try fileManager.removeItem(at: metadataUrl)
            }
        }
    }

    func renameFile(withID id: UUID, newName: String) throws {
        let metadataUrl = metadataDirectory.appendingPathComponent("file_\(id.uuidString).json")
        guard fileManager.fileExists(atPath: metadataUrl.path) else { return }

        // Decode metadata, update name, and handle physical file rename
        let data = try Data(contentsOf: metadataUrl)
        var file = try JSONDecoder().decode(FileItem.self, from: data)

        if let oldUrl = file.url, fileManager.fileExists(atPath: oldUrl.path) {
            let newUrl = oldUrl.deletingLastPathComponent().appendingPathComponent(newName)
            try fileManager.moveItem(at: oldUrl, to: newUrl)
            file.url = newUrl // Update URL in metadata
        }
        
        file.name = newName
        file.modifiedAt = Date() // Update modification date
        
        // Save the updated metadata
        try saveFile(file)
    }

    func duplicateFile(withID id: UUID) throws {
        let metadataUrl = metadataDirectory.appendingPathComponent("file_\(id.uuidString).json")
        guard fileManager.fileExists(atPath: metadataUrl.path) else { return }

        // Decode original file
        let data = try Data(contentsOf: metadataUrl)
        let originalFile = try JSONDecoder().decode(FileItem.self, from: data)

        // Create new duplicated file item
        let newName = "\(originalFile.name) copy"
        var duplicatedFile = FileItem(
            name: newName,
            type: originalFile.type,
            size: originalFile.size,
            isFavorite: false, // Duplicates aren't favorited by default
            tags: originalFile.tags,
            parentID: originalFile.parentID
        )
        
        // Handle physical file duplication
        if let originalUrl = originalFile.url, fileManager.fileExists(atPath: originalUrl.path) {
            let duplicatedUrl = originalUrl.deletingLastPathComponent().appendingPathComponent(duplicatedFile.name)
            try fileManager.copyItem(at: originalUrl, to: duplicatedUrl)
            duplicatedFile.url = duplicatedUrl
        }
        
        // Save new metadata for the duplicated file
        try saveFile(duplicatedFile)
    }

    // MARK: - Tag Operations
    func fetchTags() throws -> [Tag] {
        let urls = try fileManager.contentsOfDirectory(at: metadataDirectory, includingPropertiesForKeys: nil)
        return try urls.filter { $0.pathExtension == "json" && $0.lastPathComponent.starts(with: "tag_") }.map { url in
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(Tag.self, from: data)
        }
    }

    func saveTag(_ tag: Tag) throws {
        let data = try JSONEncoder().encode(tag)
        let url = metadataDirectory.appendingPathComponent("tag_\(tag.id.uuidString).json")
        try data.write(to: url)
    }
    
    func deleteTag(withId id: UUID) throws {
        let url = metadataDirectory.appendingPathComponent("tag_\(id.uuidString).json")
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }
    
    // MARK: - Utility
    func deleteAllFiles() throws {
        let fileUrls = try fileManager.contentsOfDirectory(at: filesDirectory, includingPropertiesForKeys: nil)
        for url in fileUrls {
            try fileManager.removeItem(at: url)
        }
        let metadataUrls = try fileManager.contentsOfDirectory(at: metadataDirectory, includingPropertiesForKeys: nil)
        for url in metadataUrls {
            try fileManager.removeItem(at: url)
        }
    }

    #if DEBUG
    static var mock: InAppFileStorageManager {
        let manager = InAppFileStorageManager(directoryName: "mock_previews")
        
        // Clear any previous mock data
        try? manager.deleteAllFiles()
        
        // Create sample data
        let sampleFiles = SampleData.files
        let sampleTags = SampleData.tags
        
        for file in sampleFiles {
            try? manager.saveFile(file)
        }
        
        for tag in sampleTags {
            try? manager.saveTag(tag)
        }
        
        return manager
    }
    #endif 
} 