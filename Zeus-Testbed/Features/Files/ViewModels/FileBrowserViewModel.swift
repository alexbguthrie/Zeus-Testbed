//
//  FileBrowserViewModel.swift
//  Zeus-Testbed
//
// Manages the state for the file browser, including the file list, selection, and layout mode.
//

import SwiftUI
import Combine

class FileBrowserViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var filteredFiles: [FileItem] = []
    @Published var selectedFiles = Set<UUID>()
    @Published var isLoading = false
    @Published var isShowingNewFolderAlert = false
    @Published var newFolderName = ""
    @Published var searchQuery = ""
    
    // Advanced Search & Filtering
    @Published var activeFilters = SearchFilters()

    // Sidebar Selection
    @Published private(set) var activeSmartGroupID: String? = "all"
    @Published private(set) var activeTagID: UUID? = nil
    
    // Properties for inline renaming
    @Published var fileToRename: FileItem? = nil
    @Published var isRenaming = false
    
    // Properties for Hierarchical Navigation
    @Published private(set) var navigationPath: [FileItem] = []
    @Published private var currentFolderID: UUID? = nil
    
    // Properties for Drag-and-Drop
    @Published var draggedFileID: UUID? = nil
    @Published var dropTargetFileID: UUID? = nil
    
    // Properties for Batch Operations
    @Published var isMultiSelectMode = false
    @Published var lastBatchOperation: BatchOperation? = nil

    private var storage: FileStorageProvider
    private let protectionService: FileProtectionService
    var allFiles: [FileItem] = [] // Holds all files from storage
    private var allFilesForCurrentFolder: [FileItem] = []
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(storage: FileStorageProvider, protectionService: FileProtectionService = FileProtectionService()) {
        self.storage = storage
        self.protectionService = protectionService
        self.loadFiles()
        
        setupBindings()
    }
    
    private func setupBindings() {
        NotificationCenter.default.publisher(for: .didChangeFileData)
            .sink { [weak self] _ in
                self?.loadFiles()
            }
            .store(in: &cancellables)
            
        let searchQueryPublisher = $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()

        let filtersPublisher = $activeFilters
        
        Publishers.CombineLatest(searchQueryPublisher, filtersPublisher)
            .sink { [weak self] (query, filters) in
                self?.filterFiles(with: query, filters: filters)
            }
            .store(in: &cancellables)
    }

    // MARK: - Sidebar Selection Updates
    func updateSmartGroup(id: String?) {
        activeSmartGroupID = id ?? "all"
        filterFiles(with: searchQuery, filters: activeFilters)
    }

    func updateTag(id: UUID?) {
        activeTagID = id
        filterFiles(with: searchQuery, filters: activeFilters)
    }

    // MARK: - Public Methods
    func loadFiles(notificationService: NotificationService? = nil) {
        isLoading = true
        selectedFiles.removeAll() // Clear selection on reload
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Simulate network delay
            do {
                let fetchedFiles = try self.storage.fetchFiles()
                self.allFiles = fetchedFiles.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
                
                // Filter files to show only children of the current folder
                self.allFilesForCurrentFolder = self.allFiles
                    .filter { $0.parentID == self.currentFolderID }
                    .sorted { $0.isFolder && !$1.isFolder || ($0.isFolder == $1.isFolder && $0.name.localizedStandardCompare($1.name) == .orderedAscending) }
                
                self.filterFiles(with: self.searchQuery, filters: self.activeFilters)
                
            } catch {
                notificationService?.show(type: .error, message: "Failed to load files.")
                print("Error fetching files: \(error)")
                self.allFiles = []
                self.allFilesForCurrentFolder = []
                self.filteredFiles = []
            }
            self.isLoading = false
        }
    }
    
    private func filterFiles(with query: String, filters: SearchFilters) {
        var sourceFiles: [FileItem]
        if let group = activeSmartGroupID, group != "all" {
            sourceFiles = allFiles
        } else {
            sourceFiles = query.isEmpty ? allFilesForCurrentFolder : allFiles
        }

        if query.isEmpty && !filters.isActive && activeSmartGroupID == "all" && activeTagID == nil {
            filteredFiles = allFilesForCurrentFolder
            return
        }

        var filtered = sourceFiles

        // --- Apply Smart Group Filter ---
        if let group = activeSmartGroupID {
            switch group {
            case "favorites":
                filtered = filtered.filter { $0.isFavorite }
            case "recents":
                filtered = filtered.sorted { $0.modifiedAt > $1.modifiedAt }
                filtered = Array(filtered.prefix(20))
            default:
                break
            }
        }

        // --- Apply Tag Selection ---
        if let tagID = activeTagID {
            filtered = filtered.filter { file in
                file.tags.contains(where: { $0.id == tagID })
            }
        }
        
        // --- Apply Text Search Query ---
        if !query.isEmpty {
            filtered = filtered.filter { $0.name.localizedCaseInsensitiveContains(query) }
        }
        
        // --- Apply File Type Filter ---
        if !filters.fileTypes.isEmpty {
            filtered = filtered.filter { filters.fileTypes.contains($0.type) }
        }
        
        // --- Apply Tag Filter (AND logic) ---
        if !filters.tags.isEmpty {
            filtered = filtered.filter { file in
                let fileTagNames = Set(file.tags.map { $0.name })
                return filters.tags.isSubset(of: fileTagNames)
            }
        }
        
        // --- Apply Date Range Filter ---
        if let dateRange = filters.dateRange {
            let startDate = dateRange.startDate()
            filtered = filtered.filter { $0.modifiedAt >= startDate }
        }
        
        self.filteredFiles = filtered
    }
    
    func createNewFolder(notificationService: NotificationService) {
        guard !newFolderName.isEmpty else { return }
        
        let newFolder = FileItem(name: newFolderName, type: .folder, parentID: currentFolderID)
        
        do {
            try storage.saveFile(newFolder)
            loadFiles(notificationService: notificationService) // Refresh the view
            notificationService.show(type: .success, message: "Folder '\(newFolderName)' created.")
        } catch {
            notificationService.show(type: .error, message: "Failed to create folder.")
        }
        
        // Reset state
        newFolderName = ""
        isShowingNewFolderAlert = false
    }

    func deleteFiles(withIDs ids: Set<UUID>, notificationService: NotificationService) {
        do {
            try storage.deleteFiles(withIDs: ids)
            loadFiles(notificationService: notificationService) // Refresh the view
            notificationService.show(type: .success, message: "Successfully deleted \(ids.count) item(s).")
        } catch {
            notificationService.show(type: .error, message: "Failed to delete items.")
        }
    }
    
    func duplicateFile(withID id: UUID, notificationService: NotificationService) {
        do {
            try storage.duplicateFile(withID: id)
            loadFiles(notificationService: notificationService)
            notificationService.show(type: .success, message: "File duplicated successfully.")
        } catch {
            notificationService.show(type: .error, message: "Failed to duplicate file.")
        }
    }
    
    func toggleFavorite(for file: FileItem, notificationService: NotificationService) {
        var updatedFile = file
        updatedFile.isFavorite.toggle()
        
        do {
            try storage.saveFile(updatedFile)
            loadFiles(notificationService: notificationService)
            let message = updatedFile.isFavorite ? "Added to Favorites." : "Removed from Favorites."
            notificationService.show(type: .success, message: message)
        } catch {
            notificationService.show(type: .error, message: "Failed to update favorite status.")
        }
    }

    func createNewFile(named name: String, type: FileType, template: String?, notificationService: NotificationService) {
        let url = storage.filesDirectory.appendingPathComponent(name)
        let data = (template ?? "").data(using: .utf8) ?? Data()

        do {
            try data.write(to: url)
            var newFile = FileItem(name: name, type: type, url: url, size: Int64(data.count), parentID: currentFolderID)
            try storage.saveFile(newFile)
            loadFiles(notificationService: notificationService)
            notificationService.show(type: .success, message: "Created \(name)")
        } catch {
            notificationService.show(type: .error, message: "Failed to create file.")
        }
    }

    func toggleProtection(for file: FileItem, notificationService: NotificationService) {
        if file.isProtected {
            protectionService.authenticate { [weak self] success in
                guard let self else { return }
                if success {
                    self.setProtection(false, for: file, notificationService: notificationService)
                } else {
                    notificationService.show(type: .error, message: "Authentication failed.")
                }
            }
        } else {
            setProtection(true, for: file, notificationService: notificationService)
        }
    }

    private func setProtection(_ value: Bool, for file: FileItem, notificationService: NotificationService) {
        var updated = file
        updated.isProtected = value
        do {
            try storage.saveFile(updated)
            loadFiles(notificationService: notificationService)
            let msg = value ? "Protection enabled." : "Protection removed."
            notificationService.show(type: .success, message: msg)
        } catch {
            notificationService.show(type: .error, message: "Failed to update protection.")
        }
    }
    
    func selectFile(fileID: UUID, isWithCommandKey: Bool, notificationService: NotificationService) {
        if isRenaming {
            // Commit any pending rename if user clicks away
            if let file = fileToRename, file.id != fileID {
                // ... existing code ...
            }
        } else {
            if let file = filteredFiles.first(where: { $0.id == fileID }), file.isProtected {
                protectionService.authenticate { [weak self] success in
                    guard let self else { return }
                    if success {
                        self.performSelection(fileID: fileID, isWithCommandKey: isWithCommandKey)
                    } else {
                        notificationService.show(type: .error, message: "Authentication failed.")
                    }
                }
                return
            }

            if isWithCommandKey {
                if selectedFiles.contains(fileID) {
                    selectedFiles.remove(fileID)
                } else {
                    selectedFiles.insert(fileID)
                }
                DispatchQueue.main.async {
                    self.isMultiSelectMode = self.selectedFiles.count > 1
                }
            } else {
                if selectedFiles.contains(fileID) && selectedFiles.count == 1 {
                    // Deselect if clicking the only selected item
                    selectedFiles.removeAll()
                    isMultiSelectMode = false
                } else {
                    selectedFiles = [fileID]
                    isMultiSelectMode = false
                }
            }
        }
    }

    private func performSelection(fileID: UUID, isWithCommandKey: Bool) {
        if isWithCommandKey {
            if selectedFiles.contains(fileID) {
                selectedFiles.remove(fileID)
            } else {
                selectedFiles.insert(fileID)
            }
            DispatchQueue.main.async {
                self.isMultiSelectMode = self.selectedFiles.count > 1
            }
        } else {
            if selectedFiles.contains(fileID) && selectedFiles.count == 1 {
                selectedFiles.removeAll()
                isMultiSelectMode = false
            } else {
                selectedFiles = [fileID]
                isMultiSelectMode = false
            }
        }
    }
    
    // MARK: - Navigation Methods
    
    func navigate(to folder: FileItem) {
        guard folder.isFolder else { return }
        
        currentFolderID = folder.id
        navigationPath.append(folder)
        resetSearchAndFilters()
        loadFiles()
    }
    
    func navigate(toDirectoryAt index: Int) {
        // Navigate to a specific folder in the breadcrumb path
        guard index < navigationPath.count else { return }
        
        let destination = navigationPath[index]
        currentFolderID = destination.id
        navigationPath.removeLast(navigationPath.count - 1 - index)
        resetSearchAndFilters()
        loadFiles()
    }
    
    func navigateToRoot() {
        currentFolderID = nil
        navigationPath.removeAll()
        resetSearchAndFilters()
        loadFiles()
    }
    
    // MARK: - Filter Control Methods
    
    func resetSearchAndFilters() {
        searchQuery = ""
        activeFilters = SearchFilters()
    }
    
    // MARK: - Rename Methods
    
    func startRenaming(file: FileItem) {
        fileToRename = file
        isRenaming = true
    }
    
    func commitRename(newName: String, notificationService: NotificationService) {
        guard let fileToRename = fileToRename else { return }
        
        do {
            try storage.renameFile(withID: fileToRename.id, newName: newName)
            loadFiles(notificationService: notificationService)
            notificationService.show(type: .success, message: "Renamed to '\(newName)'.")
        } catch {
            notificationService.show(type: .error, message: "Failed to rename file.")
        }
        
        // Reset state
        self.fileToRename = nil
        self.isRenaming = false
    }
    
    // MARK: - Drag-and-Drop Operations
    
    func importFile(from url: URL, parentID: UUID? = nil, notificationService: NotificationService) {
        do {
            // Create a FileItem from the URL
            var file = FileItem(url: url)
            file.parentID = parentID ?? currentFolderID

            // Save the file to storage
            try storage.saveFile(file)
            loadFiles(notificationService: notificationService) // Refresh the view
            
            notificationService.show(type: .success, message: "Imported '\(file.name)' successfully.")
        } catch {
            notificationService.show(type: .error, message: "Failed to import file: \(error.localizedDescription)")
        }
    }
    
    func moveFile(withID fileID: UUID, toFolder targetFolder: FileItem, notificationService: NotificationService) {
        guard targetFolder.isFolder else {
            notificationService.show(type: .error, message: "Can only move files to folders.")
            return
        }
        
        do {
            // Find the file to move
            guard let fileToMove = allFiles.first(where: { $0.id == fileID }) else {
                notificationService.show(type: .error, message: "File not found.")
                return
            }
            
            // Prevent moving a folder into itself or its descendants
            if fileToMove.isFolder {
                let isDescendant = isDescendant(folderID: targetFolder.id, of: fileToMove.id)
                if isDescendant {
                    notificationService.show(type: .error, message: "Cannot move a folder into itself or its subfolders.")
                    return
                }
            }
            
            // Update the file's parent ID
            var updatedFile = fileToMove
            updatedFile.parentID = targetFolder.id
            updatedFile.modifiedAt = Date()
            
            // Save the updated file
            try storage.saveFile(updatedFile)
            loadFiles(notificationService: notificationService) // Refresh the view
            
            notificationService.show(type: .success, message: "Moved '\(fileToMove.name)' to '\(targetFolder.name)'.")
        } catch {
            notificationService.show(type: .error, message: "Failed to move file: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Batch Operations
    
    func selectAll() {
        selectedFiles = Set(filteredFiles.map { $0.id })
        isMultiSelectMode = selectedFiles.count > 1
    }
    
    func deselectAll() {
        selectedFiles.removeAll()
        isMultiSelectMode = false
    }
    
    func batchMove(toFolder targetFolder: FileItem, notificationService: NotificationService) {
        guard !selectedFiles.isEmpty else { return }
        
        let filesToMove = allFiles.filter { selectedFiles.contains($0.id) }
        var movedCount = 0
        var failedCount = 0
        
        for file in filesToMove {
            do {
                // Prevent circular references
                if file.isFolder {
                    let isDescendant = isDescendant(folderID: targetFolder.id, of: file.id)
                    if isDescendant {
                        failedCount += 1
                        continue
                    }
                }
                
                var updatedFile = file
                updatedFile.parentID = targetFolder.id
                updatedFile.modifiedAt = Date()
                
                try storage.saveFile(updatedFile)
                movedCount += 1
            } catch {
                failedCount += 1
            }
        }
        
        // Store operation for undo
        lastBatchOperation = BatchOperation(
            type: .move,
            fileIDs: selectedFiles,
            sourceFolderID: currentFolderID,
            targetFolderID: targetFolder.id,
            successCount: movedCount,
            failedCount: failedCount
        )
        
        // Clear selection and reload
        selectedFiles.removeAll()
        isMultiSelectMode = false
        loadFiles(notificationService: notificationService)
        
        // Show notification
        if failedCount == 0 {
            notificationService.show(type: .success, message: "Moved \(movedCount) item(s) to '\(targetFolder.name)'.")
        } else {
            notificationService.show(type: .error, message: "Moved \(movedCount) item(s), failed to move \(failedCount) item(s).")
        }
    }
    
    func batchCopy(toFolder targetFolder: FileItem, notificationService: NotificationService) {
        guard !selectedFiles.isEmpty else { return }
        
        let filesToCopy = allFiles.filter { selectedFiles.contains($0.id) }
        var copiedCount = 0
        var failedCount = 0
        
        for file in filesToCopy {
            do {
                try storage.duplicateFile(withID: file.id)
                
                // Update the duplicated file's parent ID
                if let duplicatedFile = allFiles.first(where: { $0.id == file.id }) {
                    var updatedFile = duplicatedFile
                    updatedFile.parentID = targetFolder.id
                    updatedFile.modifiedAt = Date()
                    try storage.saveFile(updatedFile)
                }
                
                copiedCount += 1
            } catch {
                failedCount += 1
            }
        }
        
        // Store operation for undo
        lastBatchOperation = BatchOperation(
            type: .copy,
            fileIDs: selectedFiles,
            sourceFolderID: currentFolderID,
            targetFolderID: targetFolder.id,
            successCount: copiedCount,
            failedCount: failedCount
        )
        
        // Clear selection and reload
        selectedFiles.removeAll()
        isMultiSelectMode = false
        loadFiles(notificationService: notificationService)
        
        // Show notification
        if failedCount == 0 {
            notificationService.show(type: .success, message: "Copied \(copiedCount) item(s) to '\(targetFolder.name)'.")
        } else {
            notificationService.show(type: .error, message: "Copied \(copiedCount) item(s), failed to copy \(failedCount) item(s).")
        }
    }
    
    func batchDelete(notificationService: NotificationService) {
        guard !selectedFiles.isEmpty else { return }
        
        let filesToDelete = allFiles.filter { selectedFiles.contains($0.id) }
        var deletedCount = 0
        var failedCount = 0
        
        for file in filesToDelete {
            do {
                try storage.deleteFiles(withIDs: [file.id])
                deletedCount += 1
            } catch {
                failedCount += 1
            }
        }
        
        // Store operation for undo
        lastBatchOperation = BatchOperation(
            type: .delete,
            fileIDs: selectedFiles,
            sourceFolderID: currentFolderID,
            targetFolderID: nil,
            successCount: deletedCount,
            failedCount: failedCount
        )
        
        // Clear selection and reload
        selectedFiles.removeAll()
        isMultiSelectMode = false
        loadFiles(notificationService: notificationService)
        
        // Show notification
        if failedCount == 0 {
            notificationService.show(type: .success, message: "Deleted \(deletedCount) item(s).")
        } else {
            notificationService.show(type: .error, message: "Deleted \(deletedCount) item(s), failed to delete \(failedCount) item(s).")
        }
    }
    
    func undoLastBatchOperation(notificationService: NotificationService) {
        guard let operation = lastBatchOperation else { return }

        switch operation.type {
        case .move:
            guard let sourceID = operation.sourceFolderID else { break }
            var restored = 0
            var failed = 0
            for id in operation.fileIDs {
                do {
                    if var file = try storage.fetchFile(withID: id) {
                        file.parentID = sourceID
                        file.modifiedAt = Date()
                        try storage.saveFile(file)
                        restored += 1
                    } else {
                        failed += 1
                    }
                } catch {
                    failed += 1
                }
            }
            loadFiles(notificationService: notificationService)
            if failed == 0 {
                notificationService.show(type: .success, message: "Moved \(restored) item(s) back to the original folder.")
            } else {
                notificationService.show(type: .error, message: "Undo completed with \(failed) failure(s).")
            }
        case .copy:
            do {
                try storage.deleteFiles(withIDs: operation.fileIDs)
                loadFiles(notificationService: notificationService)
                notificationService.show(type: .success, message: "Removed copied items.")
            } catch {
                notificationService.show(type: .error, message: "Failed to undo copy operation.")
            }
        case .delete:
            notificationService.show(type: .error, message: "Undo for deletions is not supported.")
        }

        lastBatchOperation = nil
    }
    
    // MARK: - Helper Methods
    
    private func isDescendant(folderID: UUID, of parentID: UUID) -> Bool {
        guard let folder = allFiles.first(where: { $0.id == folderID }) else { return false }
        
        if folder.parentID == parentID {
            return true
        }
        
        if let grandParentID = folder.parentID {
            return isDescendant(folderID: grandParentID, of: parentID)
        }
        
        return false
    }
}

// MARK: - Batch Operation Models

struct BatchOperation {
    let type: BatchOperationType
    let fileIDs: Set<UUID>
    let sourceFolderID: UUID?
    let targetFolderID: UUID?
    let successCount: Int
    let failedCount: Int
    let timestamp = Date()
}

enum BatchOperationType {
    case move, copy, delete
    
    var displayName: String {
        switch self {
        case .move: return "Move"
        case .copy: return "Copy"
        case .delete: return "Delete"
        }
    }
}

#if DEBUG
extension FileBrowserViewModel {
    static var mock: FileBrowserViewModel {
        FileBrowserViewModel(storage: InAppFileStorageManager.mock)
    }
    
    static var empty: FileBrowserViewModel {
        FileBrowserViewModel(storage: InAppFileStorageManager(directoryName: "empty_preview"))
    }
    
    static var loading: FileBrowserViewModel {
        let vm = FileBrowserViewModel(storage: InAppFileStorageManager.mock)
        vm.isLoading = true
        return vm
    }
}
#endif 