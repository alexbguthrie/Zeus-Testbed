//
//  SidebarView.swift
//  Zeus-Testbed
//
// Sidebar for the Files feature, redesigned for the Linear look.
//

import SwiftUI

struct SidebarView: View {
    @ObservedObject var viewModel: SidebarViewModel
    var isSearchFocused: FocusState<Bool>.Binding
    private let theme = FilesTheme.current

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, theme.layout.padding)
                .padding(.bottom, theme.layout.padding)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    smartGroupsSection
                    tagsSection
                }
                .padding(.horizontal, theme.layout.padding)
            }
        }
        .padding(.vertical, theme.layout.padding)
        .frame(width: theme.layout.sidebarWidth)
        .background(theme.colors.sidebar)
        .contentShape(Rectangle())
        .onTapGesture { isSearchFocused.wrappedValue = false }
    }

    private var header: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(theme.colors.accent)
                .frame(width: 24, height: 24)
            Text("Zeus-Testbed")
                .font(theme.fonts.title)
                .foregroundColor(theme.colors.textPrimary)
            Spacer()
        }
    }

    private var smartGroupsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Smart Groups")
                .font(theme.fonts.caption.weight(.medium))
                .foregroundColor(theme.colors.textSecondary)
                .padding(.horizontal, 12)

            ForEach(viewModel.smartGroups) { group in
                SidebarRow(
                    item: group,
                    isSelected: viewModel.selectedSmartGroupID == group.id,
                    action: { viewModel.selectedSmartGroupID = group.id },
                    isSearchFocused: isSearchFocused
                )
            }
        }
    }

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Tags")
                .font(theme.fonts.caption.weight(.medium))
                .foregroundColor(theme.colors.textSecondary)
                .padding(.horizontal, 12)

            ForEach(viewModel.tags) { tag in
                SidebarRow(
                    item: tag,
                    isSelected: viewModel.selectedTagID == tag.id,
                    action: { viewModel.selectedTagID = tag.id },
                    isSearchFocused: isSearchFocused
                )
            }
        }
    }
}

// Generic protocol for items that can be displayed in the sidebar
protocol SidebarItem: Identifiable {
    var name: String { get }
    var icon: String { get }
    var iconColor: Color? { get }
}

// Conform SmartGroup and Tag to the protocol
extension SmartGroup: SidebarItem {
    var iconColor: Color? { nil }
}
extension Tag: SidebarItem {
    var icon: String { "circle.fill" }
    var iconColor: Color? { colorHex.map { Color(hex: $0) } }
}

// A reusable, styled row for the sidebar
struct SidebarRow<Item: SidebarItem>: View {
    let item: Item
    let isSelected: Bool
    let action: () -> Void
    var isSearchFocused: FocusState<Bool>.Binding
    @State private var isHovered = false
    private let theme = FilesTheme.current

    var body: some View {
        Button(action: {
            isSearchFocused.wrappedValue = false
            action()
        }) {
            HStack(spacing: 10) {
                Image(systemName: item.icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(item.iconColor ?? theme.colors.textSecondary)
                
                Text(item.name)
                    .font(theme.fonts.body)
                    .foregroundColor(isSelected ? theme.colors.textPrimary : theme.colors.textSecondary)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .frame(height: 36)
            .background(background)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                isHovered = hovering
            }
        }
    }
    
    @ViewBuilder
    private var background: some View {
        if isSelected {
            theme.colors.sidebarSelection
        } else if isHovered {
            theme.colors.sidebarSelection.opacity(0.5)
        } else {
            Color.clear
        }
    }
}


#if DEBUG
struct SidebarView_Previews: PreviewProvider {
    @FocusState static var isFocused: Bool
    
    static var previews: some View {
        let storage = InAppFileStorageManager.mock
        let viewModel = SidebarViewModel(storage: storage)
        
        // Simulate a selection
        viewModel.selectedSmartGroupID = viewModel.smartGroups[2].id
        
        return SidebarView(viewModel: viewModel, isSearchFocused: $isFocused)
            .preferredColorScheme(.dark)
    }
}
#endif 
