//
//  StoreBannerView.swift | Zeus
//  Alex Guthrie

import SwiftUI

struct StoreBannerView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Banner app icons (Fake row, you can replace with real images)
            HStack(spacing: 32) {
                ForEach(["figma", "notion", "spotify", "slack", "chrome"], id: \.self) { icon in
                    RoundedRectangle(cornerRadius: 18)
                        .fill(.ultraThinMaterial)
                        .frame(width: 64, height: 64)
                        .overlay(
                            Image(systemName: iconSymbol(icon))
                                .resizable()
                                .scaledToFit()
                                .padding(16)
                                .foregroundStyle(.white)
                                .shadow(radius: 8)
                        )
                }
            }
            .padding(.top, 32)
            
            // Title & Subtitle
            Text("Store")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.5), radius: 8, y: 4)
            
            Text("Sprinkle a little magic on your day. Connect your tools and take your daily workflow to the next level.")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .shadow(radius: 4)
            
        }
        .padding(.bottom, 30)
    }
}

// Helper for demo symbols (replace with your icons or asset names)
func iconSymbol(_ name: String) -> String {
    switch name {
    case "figma": return "square.stack.3d.up"
    case "notion": return "cube"
    case "spotify": return "waveform"
    case "slack": return "circle.hexagonpath"
    case "chrome": return "globe"
    default: return "app.fill"
    }
}

#Preview {
    StoreBannerView()
        .background(Color.black)
}

