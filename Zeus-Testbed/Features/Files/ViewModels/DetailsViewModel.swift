//
//  DetailsViewModel.swift
//  Zeus-Testbed
//
// Manages the state for the DetailsView, primarily the currently selected file.
//

import SwiftUI
import Combine

class DetailsViewModel: ObservableObject {
    @Published var file: FileItem?
    @Published var allTags: [Tag] = []
    @Published var isShowingTagPopover = false
    
    private let storage: FileStorageProvider
    private var cancellables = Set<AnyCancellable>()

    init(storage: FileStorageProvider, selectedFile: FileItem? = nil) {
        self.storage = storage
        self.file = selectedFile
        loadAllTags()
    }

    func update(with file: FileItem?) {
        self.file = file
        loadAllTags()
    }
    
    func addTag(_ tag: Tag, to file: FileItem) {
        var updatedFile = file
        guard !updatedFile.tags.contains(where: { $0.id == tag.id }) else { return }
        
        updatedFile.tags.append(tag)
        saveAndReload(file: updatedFile)
    }
    
    func removeTag(_ tag: Tag, from file: FileItem) {
        var updatedFile = file
        updatedFile.tags.removeAll { $0.id == tag.id }
        saveAndReload(file: updatedFile)
    }
    
    func createAndAssignTag(named name: String, to file: FileItem, notificationService: NotificationService) {
        let newTag = Tag(id: UUID(), name: name, colorHex: Color.randomHex())
        
        var updatedFile = file
        updatedFile.tags.append(newTag)
        
        do {
            try storage.saveTag(newTag)
            try storage.saveFile(updatedFile)
            
            self.file = updatedFile
            loadAllTags()
            NotificationCenter.default.post(name: .didChangeFileData, object: nil)
            notificationService.show(type: .success, message: "Tag '\(name)' created and assigned.")
            
        } catch {
            notificationService.show(type: .error, message: "Could not create tag.")
        }
    }
    
    private func saveAndReload(file: FileItem) {
        do {
            try storage.saveFile(file)
            self.file = file
            NotificationCenter.default.post(name: .didChangeFileData, object: nil)
        } catch {
            print("Error saving file after tag modification: \(error)")
        }
    }
    
    private func loadAllTags() {
        do {
            self.allTags = try storage.fetchTags().sorted(by: { $0.name < $1.name })
        } catch {
            print("Error loading all tags: \(error)")
        }
    }
}

extension Color {
    static func randomHex() -> String {
        let r = Int.random(in: 0..<256)
        let g = Int.random(in: 0..<256)
        let b = Int.random(in: 0..<256)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}


#if DEBUG
extension DetailsViewModel {
    static var noFileSelected: DetailsViewModel {
        DetailsViewModel(storage: InAppFileStorageManager.mock)
    }
    
    static var fileSelected: DetailsViewModel {
        let storage = InAppFileStorageManager.mock
        // Create a dummy file for the preview
        let dummyURL = storage.filesDirectory.appendingPathComponent("dummy.txt")
        try? "Hello World".data(using: .utf8)?.write(to: dummyURL)
        let file = FileItem(url: dummyURL)
        try? storage.saveFile(file)
        
        return DetailsViewModel(storage: storage, selectedFile: file)
    }
}
#endif 