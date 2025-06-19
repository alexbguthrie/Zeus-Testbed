//
//  SearchBarWithShimmer.swift
//  Zeus-Testbed
//
//  Created by Alex Guthrie on 6/20/25.
//
import SwiftUI

struct SearchBarWithShimmer: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    @State private var shimmerX: CGFloat = -88

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Search Bar
            StoreSearchBar(text: $text)
                .focused($isFocused)

            // Shimmer Line - ONLY when focused & typing
            GeometryReader { geo in
                let width = geo.size.width
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .clear,
                                Color.white.opacity(0.28),
                                .clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 88, height: 3)
                    .offset(x: shimmerX, y: 0)
                    .opacity(isFocused && !text.isEmpty ? 1 : 0)
                    .onAppear {
                        shimmerX = -88
                        withAnimation(Animation.linear(duration: 1.1).repeatForever(autoreverses: true)) {
                            shimmerX = width - 88
                        }
                    }
                    .onDisappear {
                        shimmerX = -88
                    }
            }
            .frame(height: 3)
            .allowsHitTesting(false)
        }
        .frame(height: 52)
    }
}
