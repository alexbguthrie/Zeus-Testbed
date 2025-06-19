//
//  ExtensionsSectionView.swift
//  Zeus-Testbed
//
//  Created by Alex Guthrie on 6/20/25.
//
import SwiftUI

struct ExtensionsSectionView: View {
    @ObservedObject var viewModel: ExtensionStoreViewModel
    
    // Responsive 2-column grid for desktop/tablet, 1-column for mobile
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FilterBar(selected: $viewModel.selectedFilter, filters: viewModel.filters)
                .padding(.leading, 8)
            Text("Extensions")
                .font(.title2.bold())
                .foregroundColor(.white)
                .padding(.leading, 8)
                .padding(.top, 6)
            Text("Explore the library and discover the incredible work of our community")
                .font(.body)
                .foregroundColor(.white.opacity(0.65))
                .padding(.leading, 8)
                .padding(.bottom, 22)
            
            GeometryReader { geo in
                let isWide = geo.size.width > 720
                let columns = isWide ? 2 : 1
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 22), count: columns),
                    spacing: 22
                ) {
                    ForEach(viewModel.apps) { app in
                        ExtensionAppCard(app: app)
                    }
                }
                .padding(.horizontal, 4)
            }
            .frame(minHeight: 600)
            .frame(maxWidth: 1100) // or whatever max fits your design
        }
        .padding(.vertical, 12)
        .padding(.bottom, 38)
    }
}

#Preview {
    ExtensionsSectionView(viewModel: ExtensionStoreViewModel())
        .background(Color.black)
}
