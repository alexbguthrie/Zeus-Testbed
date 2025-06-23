//
//  FileCardView.swift
//  Zeus-Testbed
//
// Displays a file or folder as a card/row, redesigned to match the Linear UI kit.
//

import SwiftUI

struct FileCardView: View {
    @ObservedObject var viewModel: FileBrowserViewModel
    @EnvironmentObject var notificationService: NotificationService
    let file: FileItem
    let isSelected: Bool
    var isSearchFocused: FocusState<Bool>.Binding
    
    @State private var isHovered = false
    @State private var newName: String
    @FocusState private var isRenameFieldFocused: Bool
    
    private var isRenaming: Bool {
        viewModel.isRenaming && viewModel.fileToRename?.id == file.id
    }
    
    private var isDragTargeted: Bool {
        viewModel.dropTargetFileID == file.id && file.isFolder
    }
    
    private var isBeingDragged: Bool {
        viewModel.draggedFileID == file.id
    }
    
    private let theme = FilesTheme.current

    init(viewModel: FileBrowserViewModel, file: FileItem, isSelected: Bool, isSearchFocused: FocusState<Bool>.Binding) {
        self.viewModel = viewModel
        self.file = file
        self.isSelected = isSelected
        self.isSearchFocused = isSearchFocused
        _newName = State(initialValue: file.name)
    }

    var body: some View {
        HStack(spacing: 12) {
            // Selection indicator for multi-select mode
            if viewModel.isMultiSelectMode {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? theme.colors.accent : theme.colors.textTertiary)
                    .font(.system(size: 16))
                    .onTapGesture {
                        isSearchFocused.wrappedValue = false
                        viewModel.selectFile(fileID: file.id, isWithCommandKey: true, notificationService: notificationService)
                    }
            }
            
            fileIcon
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                if isRenaming {
                    renameTextField
                } else {
                    Text(file.name)
                        .font(theme.fonts.body)
                        .foregroundColor(theme.colors.textPrimary)
                }
                
                Text(file.modifiedAt, style: .relative)
                    .font(theme.fonts.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }
            
            Spacer()
            
            if file.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
        }
        .padding(12)
        .background(background)
        .cornerRadius(theme.layout.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: theme.layout.cornerRadius)
                .stroke(borderColor, lineWidth: theme.layout.borderWidth)
        )
        .overlay(
            dragTargetOverlay
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                isHovered = hovering
            }
        }
        .contextMenu {
            if viewModel.isMultiSelectMode {
                Button("Select") {
                    isSearchFocused.wrappedValue = false
                    viewModel.selectFile(fileID: file.id, isWithCommandKey: true, notificationService: notificationService)
                }
                Divider()
            }
            Button("Rename") { viewModel.startRenaming(file: file) }
            Button("Duplicate") { viewModel.duplicateFile(withID: file.id, notificationService: notificationService) }
            Button(file.isFavorite ? "Remove from Favorites" : "Add to Favorites") {
                viewModel.toggleFavorite(for: file, notificationService: notificationService)
            }
            Button(file.isProtected ? "Remove Protection" : "Protect") {
                viewModel.toggleProtection(for: file, notificationService: notificationService)
            }
            Divider()
            Button("Delete", role: .destructive) {
                viewModel.deleteFiles(withIDs: [file.id], notificationService: notificationService)
            }
        }
        .onChange(of: viewModel.isRenaming) { _, isRenaming in
            if isRenaming && viewModel.fileToRename?.id == file.id {
                isRenameFieldFocused = true
            }
        }
    }

    private var renameTextField: some View {
        TextField("", text: $newName)
            .textFieldStyle(.plain)
            .font(theme.fonts.body)
            .foregroundColor(theme.colors.accent)
            .focused($isRenameFieldFocused)
            .onSubmit {
                viewModel.commitRename(newName: newName, notificationService: notificationService)
            }
            .onExitCommand {
                viewModel.commitRename(newName: file.name, notificationService: notificationService) // Cancel rename
            }
    }

    private var fileIcon: some View {
        Image(systemName: file.type.icon)
            .font(.system(size: 18))
            .foregroundColor(file.type.iconColor)
    }
    
    @ViewBuilder
    private var background: some View {
        if isDragTargeted {
            theme.colors.accent.opacity(0.15)
        } else if isBeingDragged {
            theme.colors.cardBackground.opacity(0.5)
        } else if isSelected {
            if viewModel.isMultiSelectMode {
                theme.colors.accent.opacity(0.15)
            } else {
                theme.colors.accent.opacity(0.2)
            }
        } else if isHovered {
            theme.colors.cardHover
        } else {
            theme.colors.cardBackground
        }
    }
    
    private var borderColor: Color {
        if isDragTargeted {
            return theme.colors.accent
        } else if isBeingDragged {
            return theme.colors.border.opacity(0.5)
        } else if isRenaming {
            return theme.colors.accent
        } else if isSelected {
            if viewModel.isMultiSelectMode {
                return theme.colors.accent.opacity(0.8)
            } else {
                return theme.colors.accent.opacity(0.6)
            }
        } else {
            return theme.colors.border
        }
    }
    
    @ViewBuilder
    private var dragTargetOverlay: some View {
        if isDragTargeted && file.isFolder {
            RoundedRectangle(cornerRadius: theme.layout.cornerRadius)
                .stroke(theme.colors.accent, style: StrokeStyle(lineWidth: 2, dash: [8]))
                .overlay(
                    VStack(spacing: 4) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 16))
                            .foregroundColor(theme.colors.accent)
                        Text("Drop here")
                            .font(theme.fonts.caption)
                            .foregroundColor(theme.colors.accent)
                    }
                )
                .animation(.easeInOut(duration: 0.15), value: isDragTargeted)
        }
    }
}

extension FileType {
    var icon: String {
        switch self {
            case .folder: return "folder.fill"
            case .image: return "photo.fill"
            case .pdf: return "doc.richtext.fill"
            case .markdown: return "doc.text.fill"
            case .code: return "chevron.left.slash.chevron.right"
            case .text: return "doc.plaintext.fill"
            case .other: return "doc.fill"
        }
    }
    
    var iconColor: Color {
        let theme = FilesTheme.current
        switch self {
            case .folder: return theme.colors.accent
            case .image: return .purple
            case .pdf: return .red
            case .markdown: return .green
            case .code: return .orange
            case .text, .other: return theme.colors.textSecondary
        }
    }
}


#if DEBUG
struct FileCardView_Previews: PreviewProvider {
    @FocusState static var isFocused: Bool

    static var previews: some View {
        let theme = FilesTheme.current
        let browserVM = FileBrowserViewModel(storage: InAppFileStorageManager.mock)
        return VStack(alignment: .leading, spacing: 4) {
            FileCardView(viewModel: browserVM, file: SampleData.files[0], isSelected: false, isSearchFocused: $isFocused)
            FileCardView(viewModel: browserVM, file: SampleData.files[6], isSelected: true, isSearchFocused: $isFocused)
            FileCardView(viewModel: browserVM, file: SampleData.files[3], isSelected: false, isSearchFocused: $isFocused)
        }
        .padding()
        .background(theme.colors.secondaryBackground)
        .environmentObject(NotificationService())
        .preferredColorScheme(.dark)
    }
}
#endif 