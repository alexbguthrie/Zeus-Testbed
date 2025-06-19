//
//  StoreSearchBar.swift | Zeus
//  Alex Guthrie

import SwiftUI

struct StoreSearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    var maxWidth: CGFloat = 440
    var options: [CommandOption] = []

    // Highlighted index for keyboard navigation (optional)
    @State private var highlightedIndex: Int = 0

    var showOptions: Bool {
        isFocused || !text.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search bar itself
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search…", text: $text)
                    .focused($isFocused)
                    .textFieldStyle(.plain)
                    .foregroundStyle(.primary)
                    .padding(.vertical, 8)
                Spacer(minLength: 0)
                HStack(spacing: 2) {
                    Text("⌘").font(.system(.subheadline, design: .monospaced))
                    Text("K").font(.system(.subheadline, design: .monospaced))
                }
                .padding(4)
                .background(RoundedRectangle(cornerRadius: 4).fill(.thinMaterial))
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .frame(maxWidth: maxWidth)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(isFocused ? 0.16 : 0.05), radius: isFocused ? 8 : 2, y: isFocused ? 2 : 0)
            )
            .animation(.spring(response: 0.32, dampingFraction: 0.7), value: isFocused)

            // Dropdown with options (Raycast style)
            if showOptions && !options.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    Divider().opacity(0.6)
                    HStack {
                        Text("Explore")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                    ForEach(options.indices, id: \.self) { idx in
                        let opt = options[idx]
                        Button(action: opt.action) {
                            HStack(spacing: 10) {
                                Image(systemName: opt.icon)
                                    .font(.system(size: 19))
                                Text(opt.title)
                                    .font(.body)
                                Spacer()
                                if let shortcut = opt.shortcut {
                                    Text(shortcut)
                                        .font(.system(.subheadline, design: .monospaced))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(idx == highlightedIndex ? Color.gray.opacity(0.14) : Color.clear)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: maxWidth)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.sRGB, white: 0.11, opacity: 0.97))
                        .shadow(radius: 22, y: 3)
                )
                .padding(.top, 2)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .onChange(of: isFocused) { newValue, _ in
            if newValue {
                highlightedIndex = 0
            }
        }

    }
}

#Preview {
    StoreSearchBar(
        text: .constant(""),
        options: [
            CommandOption(icon: "gear", title: "Browse Extensions", shortcut: "↩︎") {},
            CommandOption(icon: "plus", title: "Create an Extension", shortcut: nil) {}
        ]
    )
    .padding()
    .background(Color.black)
}
