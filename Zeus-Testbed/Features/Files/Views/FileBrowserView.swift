//
//  FileBrowserView.swift
//  Zeus-Testbed
//
//  View for displaying files in a grid or list, with support for selection and drag-and-drop.
//

import SwiftUI
import UniformTypeIdentifiers

struct FileBrowserView: View {
    @ObservedObject var viewModel: FileBrowserViewModel
    @Binding var layout: FileLayoutMode
    @EnvironmentObject var notificationService: NotificationService
    var isSearchFocused: FocusState<Bool>.Binding
    private let theme = FilesTheme.current
    
    // Drag-and-drop state
    @State private var isDropTargeted = false
    @State private var draggedFile: FileItem? = nil
    
    // File Importer
    @State private var isImporting = false

    private var gridColumns: [GridItem] {
        [GridItem(.adaptive(minimum: layout == .grid ? 240 : .infinity), spacing: 12)]
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            } else if viewModel.filteredFiles.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    content
                        .padding(theme.layout.padding)
                }
            }
            
            if !viewModel.selectedFiles.isEmpty {
                BatchActionBar(viewModel: viewModel)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.colors.background)
        .animation(.default, value: layout)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.selectedFiles.isEmpty)
        .contentShape(Rectangle())
        .onTapGesture { isSearchFocused.wrappedValue = false }
        // External drag-and-drop for file import
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
            handleExternalDrop(providers: providers, targetFolder: nil)
        }
        .overlay(
            dropZoneOverlay
        )
        .onChange(of: viewModel.draggedFileID) { _, draggedID in
            if draggedID == nil {
                // Clear drop target when drag ends
                viewModel.dropTargetFileID = nil
            }
        }
        .onKeyPress("a", phases: .down) { event in
            if event.modifiers.contains(.command) {
                viewModel.selectAll()
                return .handled
            }
            return .ignored
        }
        .onKeyPress("f", phases: .down) { event in
            if event.modifiers.contains(.command) {
                // How to focus the search bar? We need a FocusState property.
                // This will be added to FilesMainView and passed down.
            }
            return .ignored
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [UTType.data],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                urls.forEach { url in
                    viewModel.importFile(from: url, parentID: nil, notificationService: notificationService)
                }
            case .failure(let error):
                notificationService.show(type: .error, message: "Failed to import files: \(error.localizedDescription)")
            }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        LazyVGrid(columns: gridColumns, spacing: 12) {
            ForEach(viewModel.filteredFiles) { file in
                FileCardContainerView(
                    viewModel: viewModel,
                    file: file,
                    isSearchFocused: isSearchFocused,
                    handleInternalDrop: { providers, targetFile in
                        self.handleInternalDrop(providers: providers, targetFile: targetFile)
                    },
                    handleExternalDrop: { providers, targetFile in
                        self.handleExternalDrop(providers: providers, targetFolder: targetFile)
                    }
                )
            }
        }
    }
    
    @ViewBuilder
    private var dropZoneOverlay: some View {
        if isDropTargeted {
            RoundedRectangle(cornerRadius: theme.layout.cornerRadius)
                .stroke(theme.colors.accent, style: StrokeStyle(lineWidth: 2, dash: [10]))
                .background(
                    RoundedRectangle(cornerRadius: theme.layout.cornerRadius)
                        .fill(theme.colors.accent.opacity(0.1))
                )
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(theme.colors.accent)
                        Text("Drop files here to import")
                            .font(theme.fonts.body)
                            .foregroundColor(theme.colors.textPrimary)
                    }
                )
                .animation(.easeInOut(duration: 0.2), value: isDropTargeted)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            if viewModel.activeFilters.isActive {
                // Empty state for when filters are active
                Image(systemName: "line.3.horizontal.decrease.circle.fill")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(theme.colors.textTertiary)
                
                Text("No Matching Files")
                    .font(theme.fonts.title)
                    .foregroundColor(theme.colors.textPrimary)
                
                Text("Try adjusting your search query or filters.")
                    .font(theme.fonts.body)
                    .foregroundColor(theme.colors.textSecondary)
                
                Button(action: { viewModel.resetSearchAndFilters() }) {
                    Text("Clear Filters")
                        .font(theme.fonts.body)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(theme.colors.accent)
                        .foregroundColor(theme.colors.accentForeground)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)

            } else if viewModel.searchQuery.isEmpty {
                // Regular empty state
                Image(systemName: "folder.badge.questionmark")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(theme.colors.textTertiary)
                
                Text("No Files Yet")
                    .font(theme.fonts.title)
                    .foregroundColor(theme.colors.textPrimary)
                
                Text("Your files will appear here once you add them.")
                    .font(theme.fonts.body)
                    .foregroundColor(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 250)
                
                Button(action: {
                    isImporting = true
                }) {
                    Text("Add Files")
                        .font(theme.fonts.body)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(theme.colors.accent)
                        .foregroundColor(theme.colors.accentForeground)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            } else {
                // Empty state for when a search yields no results
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(theme.colors.textTertiary)
                
                Text("No Results for \"\(viewModel.searchQuery)\"")
                    .font(theme.fonts.title)
                    .foregroundColor(theme.colors.textPrimary)
                
                Text("Try searching for something else.")
                    .font(theme.fonts.body)
                    .foregroundColor(theme.colors.textSecondary)
            }
        }
    }
    
    // MARK: - Drag-and-Drop Handlers
    
    private func handleExternalDrop(providers: [NSItemProvider], targetFolder: FileItem? = nil) -> Bool {
        var importedCount = 0
        
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { (data, error) in
                    if let data = data as? Data,
                       let url = URL(dataRepresentation: data, relativeTo: nil) {
                        DispatchQueue.main.async {
                            viewModel.importFile(from: url, parentID: targetFolder?.id, notificationService: notificationService)
                            importedCount += 1
                        }
                    }
                }
            }
        }
        
        return true
    }
    
    private func handleInternalDrop(providers: [NSItemProvider], targetFile: FileItem) -> Bool {
        guard targetFile.isFolder else { return false }
        
        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.text.identifier) {
                provider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { (data, error) in
                    if let data = data as? Data,
                       let fileIDString = String(data: data, encoding: .utf8),
                       let fileID = UUID(uuidString: fileIDString) {
                        DispatchQueue.main.async {
                            viewModel.moveFile(withID: fileID, toFolder: targetFile, notificationService: notificationService)
                        }
                    }
                }
            }
        }
        
        return true
    }
}

// MARK: - Helper Container View
private struct FileCardContainerView: View {
    @ObservedObject var viewModel: FileBrowserViewModel
    let file: FileItem
    var isSearchFocused: FocusState<Bool>.Binding
    @EnvironmentObject var notificationService: NotificationService
    
    // Drop handlers passed from the parent
    var handleInternalDrop: ([NSItemProvider], FileItem) -> Bool
    var handleExternalDrop: ([NSItemProvider], FileItem) -> Bool
    
    var body: some View {
        FileCardView(
            viewModel: viewModel,
            file: file,
            isSelected: viewModel.selectedFiles.contains(file.id),
            isSearchFocused: isSearchFocused
        )
        .onTapGesture(count: 2) {
            if file.isFolder {
                viewModel.navigate(to: file)
            }
        }
        .onTapGesture(count: 1) {
            viewModel.selectFile(fileID: file.id, isWithCommandKey: NSEvent.modifierFlags.contains(.command), notificationService: notificationService)
        }
        // Internal drag-and-drop for file movement
        .onDrag {
            viewModel.draggedFileID = file.id
            return NSItemProvider(object: file.id.uuidString as NSString)
        }
        .onDrop(of: [.text], isTargeted: Binding(
            get: { viewModel.dropTargetFileID == file.id },
            set: { isTargeted in
                viewModel.dropTargetFileID = isTargeted ? file.id : nil
            }
        )) { providers in
            let result = handleInternalDrop(providers, file)
            viewModel.draggedFileID = nil
            viewModel.dropTargetFileID = nil
            return result
        }
        .onDrop(of: [.fileURL], isTargeted: .constant(false)) { providers in
            guard file.isFolder else { return false }
            return handleExternalDrop(providers, file)
        }
        .onDrop(of: [.fileURL], isTargeted: .constant(false)) { providers in
            guard file.isFolder else { return false }
            return handleExternalDrop(providers: providers, targetFolder: file)
        }
        .id(file.id)
    }
}

#if DEBUG
struct FileBrowserView_Previews: PreviewProvider {
    @FocusState static var isFocused: Bool
    
    static var previews: some View {
        Group {
            FileBrowserView(viewModel: .mock, layout: .constant(.grid), isSearchFocused: $isFocused)
                .previewDisplayName("Grid View")
            
            FileBrowserView(viewModel: .mock, layout: .constant(.list), isSearchFocused: $isFocused)
                .previewDisplayName("List View")

            FileBrowserView(viewModel: .empty, layout: .constant(.grid), isSearchFocused: $isFocused)
                .previewDisplayName("Empty State")
            
            FileBrowserView(viewModel: .loading, layout: .constant(.grid), isSearchFocused: $isFocused)
                .previewDisplayName("Loading State")
        }
        .environmentObject(NotificationService())
        .preferredColorScheme(.dark)
        .frame(height: 800)
    }
}
#endif 