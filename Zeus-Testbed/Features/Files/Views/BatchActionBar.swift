//
//  BatchActionBar.swift
//  Zeus-Testbed
//
//  A persistent action bar that appears when multiple files are selected,
//  providing batch operations like move, copy, and delete.
//

import SwiftUI

struct BatchActionBar: View {
    @ObservedObject var viewModel: FileBrowserViewModel
    @EnvironmentObject var notificationService: NotificationService
    @State private var showingMoveSheet = false
    @State private var showingCopySheet = false
    @State private var showingDeleteAlert = false
    
    private let theme = FilesTheme.current
    
    var body: some View {
        HStack(spacing: 16) {
            // Selection count
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(theme.colors.accent)
                Text("\(viewModel.selectedFiles.count) selected")
                    .font(theme.fonts.body)
                    .foregroundColor(theme.colors.textPrimary)
            }
            
            Divider()
                .frame(height: 20)
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: { showingMoveSheet = true }) {
                    Label("Move", systemImage: "folder")
                        .font(theme.fonts.body)
                }
                .buttonStyle(BatchActionButtonStyle())
                .disabled(viewModel.selectedFiles.isEmpty)
                
                Button(action: { showingCopySheet = true }) {
                    Label("Copy", systemImage: "doc.on.doc")
                        .font(theme.fonts.body)
                }
                .buttonStyle(BatchActionButtonStyle())
                .disabled(viewModel.selectedFiles.isEmpty)
                
                Button(action: { showingDeleteAlert = true }) {
                    Label("Delete", systemImage: "trash")
                        .font(theme.fonts.body)
                }
                .buttonStyle(BatchActionButtonStyle(destructive: true))
                .disabled(viewModel.selectedFiles.isEmpty)
            }
            
            Spacer()
            
            // Undo button
            if viewModel.lastBatchOperation != nil {
                Button(action: {
                    viewModel.undoLastBatchOperation(notificationService: notificationService)
                }) {
                    Label("Undo", systemImage: "arrow.uturn.backward")
                        .font(theme.fonts.body)
                }
                .buttonStyle(BatchActionButtonStyle())
            }
            
            // Close button
            Button(action: { viewModel.deselectAll() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(theme.colors.textSecondary)
            }
            .buttonStyle(.plain)
            .frame(width: 24, height: 24)
            .background(
                Circle()
                    .fill(theme.colors.cardBackground)
                    .overlay(
                        Circle()
                            .stroke(theme.colors.border, lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: theme.layout.cornerRadius)
                .fill(theme.colors.secondaryBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.layout.cornerRadius)
                        .stroke(theme.colors.border, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .sheet(isPresented: $showingMoveSheet) {
            FolderSelectionSheet(
                title: "Move to Folder",
                viewModel: viewModel,
                action: { folder in
                    viewModel.batchMove(toFolder: folder, notificationService: notificationService)
                }
            )
        }
        .sheet(isPresented: $showingCopySheet) {
            FolderSelectionSheet(
                title: "Copy to Folder",
                viewModel: viewModel,
                action: { folder in
                    viewModel.batchCopy(toFolder: folder, notificationService: notificationService)
                }
            )
        }
        .alert("Delete Items", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.batchDelete(notificationService: notificationService)
            }
        } message: {
            Text("Are you sure you want to delete \(viewModel.selectedFiles.count) item(s)? This action cannot be undone.")
        }
    }
}

// MARK: - Batch Action Button Style

struct BatchActionButtonStyle: ButtonStyle {
    let destructive: Bool
    
    init(destructive: Bool = false) {
        self.destructive = destructive
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(destructive ? .red : FilesTheme.current.colors.accent)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(destructive ? .red.opacity(0.1) : FilesTheme.current.colors.accent.opacity(0.1))
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Folder Selection Sheet

struct FolderSelectionSheet: View {
    let title: String
    @ObservedObject var viewModel: FileBrowserViewModel
    let action: (FileItem) -> Void
    @Environment(\.dismiss) private var dismiss
    
    private let theme = FilesTheme.current
    
    private func getFolders(for parentID: UUID?) -> [FileItem] {
        return viewModel.allFiles
            .filter { $0.isFolder && $0.parentID == parentID }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            Divider()
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    RecursiveFolderList(
                        folders: getFolders(for: nil),
                        viewModel: viewModel,
                        action: { folder in
                            action(folder)
                            dismiss()
                        }
                    )
                }
                .padding(8)
            }
        }
        .frame(width: 380, height: 420)
        .background(theme.colors.secondaryBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 20)
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(theme.fonts.title)
                    .foregroundColor(theme.colors.textPrimary)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(theme.colors.textSecondary)
                        .padding(6)
                        .background(theme.colors.cardHover.opacity(0.5))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
            
            SheetBreadcrumbView(path: viewModel.navigationPath)
        }
        .padding()
        .background(theme.colors.cardBackground)
    }
}

// MARK: - Recursive Folder List for Sheet
private struct RecursiveFolderList: View {
    let folders: [FileItem]
    @ObservedObject var viewModel: FileBrowserViewModel
    let action: (FileItem) -> Void
    var indentationLevel: Int = 0
    
    private let theme = FilesTheme.current
    
    private func getSubfolders(for parentID: UUID?) -> [FileItem] {
        return viewModel.allFiles
            .filter { $0.isFolder && $0.parentID == parentID }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    var body: some View {
        ForEach(folders) { folder in
            VStack(alignment: .leading, spacing: 0) {
                FolderRowView(
                    folder: folder,
                    indentation: indentationLevel,
                    action: { action(folder) }
                )
                
                RecursiveFolderList(
                    folders: getSubfolders(for: folder.id),
                    viewModel: viewModel,
                    action: action,
                    indentationLevel: indentationLevel + 1
                )
            }
        }
    }
}

// MARK: - Folder Row View
private struct FolderRowView: View {
    let folder: FileItem
    let indentation: Int
    let action: () -> Void
    
    @State private var isHovered = false
    private let theme = FilesTheme.current

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Spacer().frame(width: CGFloat(indentation * 20))
                
                Image(systemName: "folder.fill")
                    .foregroundColor(theme.colors.accent)
                    .frame(width: 20)
                
                Text(folder.name)
                    .font(theme.fonts.body)
                    .foregroundColor(theme.colors.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
        }
        .buttonStyle(.plain)
        .background(isHovered ? theme.colors.cardHover : .clear)
        .cornerRadius(6)
        .onHover { isHovered = $0 }
    }
}

// MARK: - Sheet Breadcrumb View
private struct SheetBreadcrumbView: View {
    let path: [FileItem]
    private let theme = FilesTheme.current
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                Image(systemName: "folder")
                    .foregroundColor(theme.colors.textSecondary)
                Text("All Files")
                    .font(theme.fonts.caption)
                    .foregroundColor(theme.colors.textSecondary)
                
                ForEach(path) { folder in
                    Image(systemName: "chevron.right")
                        .foregroundColor(theme.colors.textTertiary)
                        .font(.system(size: 8, weight: .medium))
                    
                    Text(folder.name)
                        .font(theme.fonts.caption)
                        .foregroundColor(theme.colors.textSecondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
        }
        .frame(height: 20)
    }
}

#if DEBUG
struct BatchActionBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            BatchActionBar(viewModel: .mock)
        }
        .background(FilesTheme.current.colors.background)
        .environmentObject(NotificationService())
        .preferredColorScheme(.dark)
    }
}
#endif 