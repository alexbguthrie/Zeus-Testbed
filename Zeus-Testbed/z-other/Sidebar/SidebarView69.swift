//
//  SidebarView.swift
//  Zeus-Testbed
//
//  Created by User on 2024-07-29.
//
/*
import SwiftUI

struct SidebarView: View {
    @Binding var selectedTab: SidebarTab?

    var body: some View {
        VStack(alignment: .leading) {
            userProfile
                .padding(.bottom, AppTheme.Spacing.large)

            ForEach(SidebarTab.allCases) { tab in
                navigationLink(for: tab)
            }
            
            Spacer()
            
            Divider()
            
            downloadsButton
        }
        .padding(AppTheme.Spacing.medium)
        .background(AppTheme.Colors.sidebarBackground)
        .foregroundColor(AppTheme.Colors.sidebarText)
    }

    private var userProfile: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .font(.largeTitle)
                .foregroundColor(AppTheme.Colors.sidebarAccent)
            VStack(alignment: .leading) {
                Text("John Cooper")
                    .font(.headline)
                Text("Developer")
                    .font(.subheadline)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
    }

    private func navigationLink(for tab: SidebarTab) -> some View {
        Button(action: { self.selectedTab = tab }) {
            HStack {
                Image(systemName: tab.iconName)
                    .frame(width: 24)
                Text(tab.title)
            }
            .padding(.vertical, AppTheme.Spacing.small)
            .padding(.horizontal, AppTheme.Spacing.medium)
            .background(selectedTab == tab ? AppTheme.Colors.sidebarSelection : .clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
    
    private var downloadsButton: some View {
        Button(action: {
            // Handle downloads action
        }) {
            HStack {
                Image(systemName: "square.and.arrow.down")
                    .frame(width: 24)
                Text("Downloads")
            }
            .padding(.vertical, AppTheme.Spacing.small)
            .padding(.horizontal, AppTheme.Spacing.medium)
        }
        .buttonStyle(.plain)
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView(selectedTab: .constant(.learn))
    }
} 
*/
