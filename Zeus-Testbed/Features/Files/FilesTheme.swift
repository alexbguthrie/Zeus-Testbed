//
//  FilesTheme.swift
//  Zeus-Testbed
//
//  A robust, customizable theme engine for the Smart Files feature, inspired by the Linear UI design system.
//  This structure supports multiple themes (e.g., dark, light) and provides a centralized source for all UI styling.
//

import SwiftUI

// MARK: - Theme Protocol and Concrete Implementation

/// Defines the blueprint for a theme, ensuring all necessary colors, fonts, and layout values are provided.
protocol Theme {
    var colors: ColorTheme { get }
    var fonts: FontTheme { get }
    var layout: LayoutTheme { get }
}

/// The main struct that holds the active theme configuration.
struct FilesTheme {
    /// The currently active theme. Change this to `light` to switch the app's appearance.
    static var current: Theme = DarkTheme()

    // Concrete theme implementations can be added here.
}

// MARK: - Dark Theme Definition

struct DarkTheme: Theme {
    let colors = ColorTheme(
        background: Color(hex: "#0b0b0f"),
        secondaryBackground: Color(hex: "#1a1a1e"),
        sidebar: Color(hex: "#151519"),
        
        textPrimary: Color(hex: "#f0f0f0"),
        textSecondary: Color(hex: "#a0a0a0"),
        textTertiary: Color(hex: "#6a6a6f"),
        
        accent: Color(hex: "#5e6ad2"),
        accentForeground: Color(hex: "#ffffff"),
        
        border: Color(hex: "#252529"),
        divider: Color(hex: "#202024"),
        
        cardBackground: Color(hex: "#1a1a1e"),
        cardHover: Color(hex: "#202024"),
        
        button: Color.clear,
        buttonHover: Color(hex: "#252529"),
        
        destructive: Color(hex: "#e5484d"),
        destructiveHover: Color(hex: "#f2555a"),

        sidebarSelection: Color(hex: "#2a2a2e")
    )
    
    let fonts = FontTheme(
        largeTitle: .system(size: 28, weight: .bold, design: .default),
        title: .system(size: 18, weight: .semibold, design: .default),
        body: .system(size: 14, weight: .medium, design: .default),
        caption: .system(size: 12, weight: .regular, design: .default)
    )
    
    let layout = LayoutTheme(
        cornerRadius: 8.0,
        padding: 16.0,
        sidebarWidth: 260.0,
        borderWidth: 1.0,
        shadow: Shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    )
}

// MARK: - Theme Component Structs

struct ColorTheme {
    let background: Color
    let secondaryBackground: Color
    let sidebar: Color
    
    let textPrimary: Color
    let textSecondary: Color
    let textTertiary: Color
    
    let accent: Color
    let accentForeground: Color
    
    let border: Color
    let divider: Color
    
    let cardBackground: Color
    let cardHover: Color
    
    let button: Color
    let buttonHover: Color
    
    let destructive: Color
    let destructiveHover: Color

    let sidebarSelection: Color
}

struct FontTheme {
    let largeTitle: Font
    let title: Font
    let body: Font
    let caption: Font
}

struct LayoutTheme {
    let cornerRadius: CGFloat
    let padding: CGFloat
    let sidebarWidth: CGFloat
    let borderWidth: CGFloat
    let shadow: Shadow
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
} 