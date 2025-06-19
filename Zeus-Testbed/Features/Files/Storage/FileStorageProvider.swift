//
//  FileStorageProvider.swift
//  Zeus-Testbed
//
// Protocol defining the contract for file storage services.
//

import Foundation

protocol FileStorageProvider {
    // MARK: - File Operations
    func fetchFiles() throws -> [FileItem]
    func saveFile(_ file: FileItem) throws
    func deleteFiles(withIDs ids: Set<UUID>) throws
    func renameFile(withID id: UUID, newName: String) throws
    func duplicateFile(withID id: UUID) throws
    
    // MARK: - Tag Operations
    func fetchTags() throws -> [Tag]
    func saveTag(_ tag: Tag) throws
    func deleteTag(withId id: UUID) throws
    
    // MARK: - Utility
    func deleteAllFiles() throws
} 