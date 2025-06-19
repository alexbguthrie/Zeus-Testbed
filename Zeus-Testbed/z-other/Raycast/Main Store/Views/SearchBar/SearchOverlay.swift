//
//  SearchOverlay.swift
//  Zeus-Testbed
//
//  Created by Alex Guthrie on 6/20/25.
//
import SwiftUI

#if os(macOS)
extension View {
    func onEscapeKey(perform: @escaping () -> Void) -> some View {
        self.background(EscapeKeyHandlingView(action: perform))
    }
}

struct EscapeKeyHandlingView: NSViewRepresentable {
    let action: () -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.specialKey?.rawValue == 0x35 { // Escape key
                action()
                return nil
            }
            return event
        }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}
#endif

struct SearchOverlay: View {
    @Binding var isPresented: Bool
    @Binding var searchText: String
    var options: [CommandOption]
    var results: [StoreApp] = []
    @State private var highlightedIndex: Int = 0

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(isPresented ? 0.54 : 0)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.18), value: isPresented)
                .onTapGesture { withAnimation { isPresented = false } }

            VStack(spacing: 0) {
                // MAIN search bar (animated shimmer)
                SearchBarWithShimmer(text: $searchText)
                    .frame(maxWidth: 540)
                    .padding(.top, 72)
                    .padding(.bottom, 6)

                // BELOW: Results/Options/No results inside a single background
                ZStack {
                    if searchText.isEmpty {
                        // Command options (explore/create)
                        CommandPalette(options: options, highlightedIndex: $highlightedIndex)
                            .padding(.top, 0)
                    } else if results.isEmpty {
                        // No results
                        VStack(spacing: 18) {
                            Spacer().frame(height: 40)
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 38))
                                .opacity(0.20)
                            Text("Can't find what you're looking for?")
                                .font(.title3)
                                .foregroundColor(.secondary)
                            Button {
                                // Build extension action
                            } label: {
                                HStack(spacing: 6) {
                                    Text("Build your own Extension")
                                        .bold()
                                    Image(systemName: "arrow.right")
                                }
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.white)
                            Spacer().frame(height: 32)
                        }
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(.sRGB, white: 0.10, opacity: 0.98))
                                .shadow(radius: 18)
                        )
                    } else {
                        // Results
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Results")
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(.secondary)
                                .padding(.leading, 28)
                                .padding(.vertical, 7)

                            ForEach(results.indices, id: \.self) { idx in
                                let app = results[idx]
                                Button {
                                    // Select app
                                } label: {
                                    HStack(spacing: 16) {
                                        Image(systemName: app.imageName)
                                            .font(.title2)
                                            .frame(width: 30)
                                        VStack(alignment: .leading) {
                                            Text(app.name)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            Text(app.description)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                        }
                                        Spacer()
                                        if highlightedIndex == idx {
                                            Image(systemName: "arrow.right")
                                                .foregroundColor(.accentColor)
                                        }
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 24)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(highlightedIndex == idx ? Color.white.opacity(0.07) : Color.clear)
                                    )
                                }
                                .buttonStyle(.plain)
                            }

                            // View all results at bottom
                            Button {
                                // Action for all results
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("View all results")
                                        .font(.callout)
                                        .bold()
                                    Image(systemName: "arrow.right")
                                }
                                .padding(.vertical, 16)
                                .padding(.horizontal, 16)
                                .foregroundColor(.white)
                                .background(Color.clear)
                            }
                            .buttonStyle(.plain)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color(.sRGB, white: 0.10, opacity: 0.98))
                                .shadow(radius: 18)
                        )
                    }
                }
                .frame(maxWidth: 600)
            }
            .padding(.horizontal)
        }
        .transition(.opacity)
    }
}
