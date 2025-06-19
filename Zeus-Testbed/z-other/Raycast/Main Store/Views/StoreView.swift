//
//  StoreView.swift | Zeus
//  Alex Guthrie

import SwiftUI

struct StoreView: View {
    @StateObject var viewModel = StoreViewModel()
    @StateObject var extensionsViewModel = ExtensionStoreViewModel()
    @State private var isSearchOverlayPresented = false
    
    let searchOptions = [
        CommandOption(icon: "gear", title: "Browse Extensions", shortcut: "↩︎") {
            print("Browse Extensions tapped")
        },
        CommandOption(icon: "plus", title: "Create an Extension", shortcut: nil) {
            print("Create tapped")
        }
    ]
    
    // Responsive grid
    let spacing: CGFloat = 24
    let minCardWidth: CGFloat = 280
    
    // Use .adaptive for featured grid if possible:
    let featureColumns: [GridItem] = [
        GridItem(.adaptive(minimum: 260, maximum: 340), spacing: 24)
    ]
    
    var body: some View {
        ZStack {
            // Main content (blurred when overlay is presented)
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.black, Color(.sRGB, white: 0.12, opacity: 1)]),
                               startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 0) {
                        StoreBannerView()
                        // --- Change this button to open overlay ---
                        Button(action: { withAnimation { isSearchOverlayPresented = true } }) {
                            StoreSearchBar(text: $viewModel.searchText, options: []) // No options for main view
                                .padding(.top, 8)
                        }
                        .buttonStyle(.plain)
                        // ----
                        
                        // Featured Apps Grid
                        LazyVGrid(columns: featureColumns, spacing: spacing) {
                            ForEach(viewModel.filteredApps) { app in
                                StoreAppCard(app: app)
                            }
                        }
                        .padding(.top, 12)
                        .padding(.horizontal)
                        .frame(maxWidth: 1200)
                        
                        // Extensions Section
                        ExtensionsSectionView(viewModel: extensionsViewModel)
                            .padding(.top, 32)
                    }
                    .padding(.top, 18)
                    .padding(.horizontal, 24)
                    .background(Color.black.ignoresSafeArea())
                    
                    .preferredColorScheme(.dark)
                }
            }
            .blur(radius: isSearchOverlayPresented ? 8 : 0)
            .animation(.easeInOut(duration: 0.15), value: isSearchOverlayPresented)
            
            // Overlay
            if isSearchOverlayPresented {
                SearchOverlay(
                    isPresented: $isSearchOverlayPresented,
                    searchText: $viewModel.searchText,
                    options: searchOptions // Pass your options here!
                )
                .zIndex(10)
                .transition(.opacity.combined(with: .scale))
            }
        }
    }
}

// MARK: - PREVIEW
#Preview {
    StoreView()
        .frame(width: 1000, height: 900)
}
