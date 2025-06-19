//
//  FilesMainView.swift
//  Zeus-Testbed
//
// Main container for the Smart Files feature, redesigned to match the Linear UI kit.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

struct FilesMainView: View {
    @StateObject private var storageManager: InAppFileStorageManager
    @StateObject private var sidebarVM: SidebarViewModel
    @StateObject private var browserVM: FileBrowserViewModel
    @StateObject private var detailsVM: DetailsViewModel
    
    @StateObject private var notificationService = NotificationService()

    @State private var layoutMode: FileLayoutMode = .list
    @State private var isImporting = false
    @FocusState private var isSearchFocused: Bool
    private let theme = FilesTheme.current
    
    init() {
        let storage = InAppFileStorageManager()
        _storageManager = StateObject(wrappedValue: storage)
        _sidebarVM = StateObject(wrappedValue: SidebarViewModel(storage: storage))
        let browserViewModel = FileBrowserViewModel(storage: storage)
        _browserVM = StateObject(wrappedValue: browserViewModel)
        _detailsVM = StateObject(wrappedValue: DetailsViewModel(storage: storage))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            HStack(spacing: 0) {
                SidebarView(viewModel: sidebarVM, isSearchFocused: $isSearchFocused)
                
                VStack(spacing: 0) {
                    HeaderView(viewModel: browserVM, layoutMode: $layoutMode, isImporting: $isImporting, isSearchFocused: $isSearchFocused)
                    FileBrowserView(viewModel: browserVM, layout: $layoutMode, isSearchFocused: $isSearchFocused)
                }
                .background(theme.colors.background)
                
                Divider().frame(width: 1).background(theme.colors.divider)
                
                DetailsView(viewModel: detailsVM, isSearchFocused: $isSearchFocused)
            }
            .onReceive(browserVM.$selectedFiles) { selectedIDs in
                // For now, only show details for a single selection.
                if selectedIDs.count == 1, let firstID = selectedIDs.first {
                    let selectedFile = browserVM.filteredFiles.first(where: { $0.id == firstID })
                    detailsVM.update(with: selectedFile)
                } else {
                    detailsVM.update(with: nil)
                }
            }
            .fileImporter(isPresented: $isImporting, allowedContentTypes: [.content], allowsMultipleSelection: true) { result in
                storageManager.importFiles(from: result, notificationService: notificationService)
                browserVM.loadFiles()
            }
            .alert("New Folder", isPresented: $browserVM.isShowingNewFolderAlert) {
                TextField("Enter folder name", text: $browserVM.newFolderName)
                Button("Create") { browserVM.createNewFolder(notificationService: notificationService) }
                Button("Cancel", role: .cancel) {
                    browserVM.newFolderName = ""
                }
            } message: {
                Text("Please enter a name for the new folder.")
            }
            
            // Notification View Overlay
            if let notification = notificationService.notification {
                NotificationView(notification: notification)
                    .padding(.top)
            }
        }
        .background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    DispatchQueue.main.async {
                        isSearchFocused = false
                    }
                }
        )
        .environmentObject(notificationService)
        // Global keyboard shortcuts for batch operations
        .onKeyPress(.escape, phases: .down) { _ in
            browserVM.deselectAll()
            return .handled
        }
        .onKeyPress(.delete, phases: .down) { _ in
            if !browserVM.selectedFiles.isEmpty {
                browserVM.batchDelete(notificationService: notificationService)
            }
            return .handled
        }
        .onKeyPress("a", phases: .down) { event in
            if event.modifiers.contains(.command) {
                browserVM.selectAll()
                return .handled
            }
            return .ignored
        }
        .onKeyPress("f", phases: .down) { event in
            if event.modifiers.contains(.command) {
                isSearchFocused = true
                return .handled
            }
            return .ignored
        }
    }
}

struct HeaderView: View {
    @ObservedObject var viewModel: FileBrowserViewModel
    @Binding var layoutMode: FileLayoutMode
    @Binding var isImporting: Bool
    var isSearchFocused: FocusState<Bool>.Binding
    
    @State private var isShowingFilterMenu = false
    
    private let theme = FilesTheme.current

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 16) {
                if viewModel.searchQuery.isEmpty && !viewModel.activeFilters.isActive {
                    BreadcrumbView(viewModel: viewModel)
                        .layoutPriority(0)
                } else {
                    searchResultsHeader
                }

                Spacer(minLength: 16)
                
                SearchBar(searchQuery: $viewModel.searchQuery, isFocused: isSearchFocused)
                    .frame(maxWidth: 300)
                
                HStack(spacing: 8) {
                    filterButton
                    
                    Menu {
                        Button("New Folder") { viewModel.isShowingNewFolderAlert = true }
                        Button("Import Files...") { isImporting = true }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(theme.colors.textPrimary)
                    }
                    .menuStyle(.borderlessButton)
                    .frame(width: 32, height: 28)
                    
                    FileLayoutToggle(selected: $layoutMode)
                }
                .layoutPriority(1)
            }
            .padding(theme.layout.padding)

            if viewModel.activeFilters.isActive {
                ActiveFiltersView(viewModel: viewModel)
                    .padding(.horizontal, theme.layout.padding)
                    .padding(.bottom, 8)
            }
        }
        .overlay(Rectangle().frame(height: 1).foregroundColor(theme.colors.border), alignment: .bottom)
    }
    
    @ViewBuilder
    private var searchResultsHeader: some View {
        HStack(spacing: 8) {
            Text(viewModel.searchQuery.isEmpty ? "Filtered Results" : "Search Results")
                .font(theme.fonts.title)
                .foregroundColor(theme.colors.textPrimary)
            
            Button(action: { viewModel.resetSearchAndFilters() }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(theme.colors.textTertiary)
            }
            .buttonStyle(.plain)
        }
        .layoutPriority(0)
    }
    
    private var filterButton: some View {
        Button(action: { isShowingFilterMenu = true }) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(viewModel.activeFilters.isActive ? theme.colors.accent : theme.colors.textPrimary)
        }
        .menuStyle(.borderlessButton)
        .frame(width: 32, height: 28)
        .popover(isPresented: $isShowingFilterMenu, arrowEdge: .bottom) {
            FilterMenuView(viewModel: viewModel)
        }
    }
}

struct SearchBar: View {
    @Binding var searchQuery: String
    var isFocused: FocusState<Bool>.Binding
    private let theme = FilesTheme.current
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(theme.colors.textTertiary)

            TextField("Search files...", text: $searchQuery)
                .textFieldStyle(.plain)
                .font(theme.fonts.body)
                .foregroundColor(theme.colors.textPrimary)
                .focused(isFocused)
            
            if !searchQuery.isEmpty {
                Button(action: { searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(theme.colors.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(theme.colors.secondaryBackground)
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(theme.colors.border, lineWidth: 1)
        )
    }
}

struct BreadcrumbView: View {
    @ObservedObject var viewModel: FileBrowserViewModel
    private let theme = FilesTheme.current
    
    var body: some View {
        HStack(spacing: 4) {
            Button(action: { viewModel.navigateToRoot() }) {
                HStack(spacing: 4) {
                    Image(systemName: "folder")
                    Text("All Files")
                }
            }
            .buttonStyle(.plain)
            .font(theme.fonts.title)
            .foregroundColor(viewModel.navigationPath.isEmpty ? theme.colors.textPrimary : theme.colors.textSecondary)

            ForEach(Array(viewModel.navigationPath.enumerated()), id: \.element.id) { index, folder in
                Image(systemName: "chevron.right")
                    .foregroundColor(theme.colors.textTertiary)
                    .font(.system(size: 10, weight: .medium))

                Button(action: { viewModel.navigate(toDirectoryAt: index) }) {
                    Text(folder.name)
                }
                .buttonStyle(.plain)
                .font(theme.fonts.title)
                .foregroundColor(index == viewModel.navigationPath.count - 1 ? theme.colors.textPrimary : theme.colors.textSecondary)
            }
        }
        .lineLimit(1)
        .truncationMode(.tail)
    }
}

private struct FileLayoutToggle: View {
    @Binding var selected: FileLayoutMode
    @Namespace private var namespace
    private let theme = FilesTheme.current
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(FileLayoutMode.allCases, id: \.self) { mode in
                Button(action: { selected = mode }) {
                    ZStack {
                        if selected == mode {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(theme.colors.secondaryBackground)
                                .matchedGeometryEffect(id: "selection", in: namespace)
                        }
                        Image(systemName: mode.icon)
                    }
                    .frame(width: 32, height: 28)
                }
                .buttonStyle(.plain)
                .foregroundColor(selected == mode ? theme.colors.textPrimary : theme.colors.textSecondary)
            }
        }
        .padding(4)
        .background(theme.colors.background)
        .cornerRadius(theme.layout.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: theme.layout.cornerRadius)
                .stroke(theme.colors.border, lineWidth: theme.layout.borderWidth)
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selected)
    }
}

enum FileLayoutMode: String, CaseIterable {
    case list, grid
    var icon: String {
        switch self {
        case .list: return "list.bullet"
        case .grid: return "square.grid.2x2.fill"
        }
    }
}

struct ActiveFiltersView: View {
    @ObservedObject var viewModel: FileBrowserViewModel
    private let theme = FilesTheme.current

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if !viewModel.activeFilters.fileTypes.isEmpty {
                    ForEach(Array(viewModel.activeFilters.fileTypes), id: \.self) { type in
                        FilterChip(label: type.rawValue.capitalized) {
                            viewModel.activeFilters.fileTypes.remove(type)
                        }
                    }
                }
                
                if !viewModel.activeFilters.tags.isEmpty {
                    ForEach(Array(viewModel.activeFilters.tags), id: \.self) { tag in
                        FilterChip(label: "Tag: \(tag)") {
                            viewModel.activeFilters.tags.remove(tag)
                        }
                    }
                }
                
                if let dateRange = viewModel.activeFilters.dateRange {
                    FilterChip(label: dateRange.rawValue) {
                        viewModel.activeFilters.dateRange = nil
                    }
                }
            }
        }
    }
}

struct FilterChip: View {
    let label: String
    let onRemove: () -> Void
    private let theme = FilesTheme.current
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(theme.fonts.caption)
                .foregroundColor(theme.colors.accent)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
            }
            .buttonStyle(.plain)
            .foregroundColor(theme.colors.accent)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(theme.colors.accent.opacity(0.1))
        .cornerRadius(6)
    }
}

struct FilterMenuView: View {
    @ObservedObject var viewModel: FileBrowserViewModel
    private let theme = FilesTheme.current
    
    private var allTags: [String] {
        let tags = viewModel.allFiles.flatMap { $0.tags.map { $0.name } }
        return Array(Set(tags)).sorted()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            fileTypeFilter
            Divider()
            tagFilter
            Divider()
            dateFilter
            Divider()
            resetButton
        }
        .padding()
        .frame(width: 250)
        .background(theme.colors.secondaryBackground)
    }
    
    @ViewBuilder
    private var fileTypeFilter: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("File Type")
                .font(theme.fonts.body.weight(.semibold))
            
            FlexibleView(
                data: FileType.allCases,
                spacing: 8,
                alignment: .leading
            ) { type in
                Button(action: { toggleFileType(type) }) {
                    Text(type.rawValue.capitalized)
                        .font(theme.fonts.body)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(viewModel.activeFilters.fileTypes.contains(type) ? theme.colors.accent.opacity(0.2) : theme.colors.cardBackground)
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    @ViewBuilder
    private var tagFilter: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags")
                .font(theme.fonts.body.weight(.semibold))
            
            Menu {
                ForEach(allTags, id: \.self) { tag in
                    Button(action: { toggleTag(tag) }) {
                        HStack {
                            Text(tag)
                            if viewModel.activeFilters.tags.contains(tag) {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(viewModel.activeFilters.tags.isEmpty ? "Select Tags" : "\(viewModel.activeFilters.tags.count) selected")
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                }
                .padding(8)
                .background(theme.colors.cardBackground)
                .cornerRadius(6)
            }
            .menuStyle(.borderlessButton)
        }
    }
    
    @ViewBuilder
    private var dateFilter: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Date Modified")
                .font(theme.fonts.body.weight(.semibold))
            
            Picker("Date Range", selection: $viewModel.activeFilters.dateRange) {
                Text("Any Time").tag(nil as DateFilterRange?)
                ForEach(DateFilterRange.allCases) { range in
                    Text(range.rawValue).tag(range as DateFilterRange?)
                }
            }
            .pickerStyle(.menu)
        }
    }
    
    private var resetButton: some View {
        Button("Reset Filters", role: .destructive) {
            viewModel.activeFilters = SearchFilters()
        }
        .buttonStyle(.plain)
        .font(theme.fonts.body)
        .foregroundColor(.red)
    }
    
    private func toggleFileType(_ type: FileType) {
        if viewModel.activeFilters.fileTypes.contains(type) {
            viewModel.activeFilters.fileTypes.remove(type)
        } else {
            viewModel.activeFilters.fileTypes.insert(type)
        }
    }
    
    private func toggleTag(_ tag: String) {
        if viewModel.activeFilters.tags.contains(tag) {
            viewModel.activeFilters.tags.remove(tag)
        } else {
            viewModel.activeFilters.tags.insert(tag)
        }
    }
}

/// A view that arranges its children in a wrapping horizontal layout.
struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    
    @State private var availableWidth: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: alignment, vertical: .center)) {
            Color.clear
                .frame(height: 1)
                .readSize { size in
                    availableWidth = size.width
                }
            
            _FlexibleView(
                availableWidth: availableWidth,
                data: data,
                spacing: spacing,
                alignment: alignment,
                content: content
            )
        }
    }
}

/// Helper for FlexibleView to perform the layout calculation.
private struct _FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let availableWidth: CGFloat
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    
    @State var elementsSize: [Data.Element: CGSize] = [:]
    
    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(computeRows(), id: \.self) { rowElements in
                HStack(spacing: spacing) {
                    ForEach(rowElements, id: \.self) { element in
                        content(element)
                            .fixedSize()
                            .readSize { size in
                                elementsSize[element] = size
                            }
                    }
                }
            }
        }
    }
    
    private func computeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = [[]]
        var currentRow = 0
        var remainingWidth = availableWidth
        
        for element in data {
            let elementSize = elementsSize[element, default: CGSize(width: availableWidth, height: 1)]
            
            if remainingWidth - (elementSize.width + spacing) >= 0 {
                rows[currentRow].append(element)
            } else {
                currentRow += 1
                rows.append([element])
                remainingWidth = availableWidth
            }
            
            remainingWidth -= (elementSize.width + spacing)
        }
        
        return rows
    }
}

/// View modifier to read the size of a view.
extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

/// Preference key for view size.
private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

#if DEBUG
struct FilesMainView_Previews: PreviewProvider {
    static var previews: some View {
        FilesMainView()
            .preferredColorScheme(.dark)
    }
}
#endif 
