//
//  CommandPalette.swift
//  Zeus-Testbed
//
//  Created by Alex Guthrie on 6/20/25.
//
import SwiftUI
struct CommandPalette: View {
    let options: [CommandOption]
    @Binding var highlightedIndex: Int

    var body: some View {
        VStack(spacing: 0) {
            // Section title
            HStack {
                Text("Explore")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            
            // Option Rows
            ForEach(Array(options.enumerated()), id: \.element.id) { index, option in
                Button(action: option.action) {
                    HStack {
                        Image(systemName: option.icon)
                            .font(.system(size: 20))
                        Text(option.title)
                            .font(.title3)
                        Spacer()
                        if let shortcut = option.shortcut {
                            Text(shortcut)
                                .font(.system(.subheadline, design: .monospaced))
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(index == highlightedIndex ? Color.gray.opacity(0.13) : Color.clear)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .frame(width: 520)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.sRGB, white: 0.11, opacity: 0.99))
                .shadow(radius: 24)
        )
    }
}
