import SwiftUI

struct AppTheme {
    struct Colors {
        static var background: Color {
            #if os(macOS)
            return Color(NSColor.windowBackgroundColor)
            #else
            return Color(UIColor.systemBackground)
            //return Color(Color.mainBG)
            #endif
        }
        
        static var cardBackground: Color {
            #if os(macOS)
            return Color(NSColor.underPageBackgroundColor)
            #else
            return Color(UIColor.secondarySystemGroupedBackground)
            #endif
        }

        static let accent = Color.accentColor
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        
        // Sidebar Specific
        static let sidebarBackground = Color(red: 0.1, green: 0.11, blue: 0.12)
        //static let sidebarBackground = Color(Color.sidebarBG)
        static let sidebarSelection = Color.gray.opacity(0.3)
        //static let sidebarIcon = Color(Color.sideBarIcon)
        static let sidebarText = Color.primary
        static let sidebarAccent = Color.accentColor
    }
    
    struct Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xlarge: CGFloat = 32
    }
} 
