//
//  FilterBar.swift
//  Zeus-Testbed
//
//  Created by Alex Guthrie on 6/20/25.
//
import SwiftUI

struct FilterBar: View {
    @Binding var selected: String
    let filters: [String]
    
    var body: some View {
        ZStack {
            // Main track
            Capsule()
                .fill(Color(white: 0.1))
                .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 0.7))
            
            HStack(spacing: 0) {
                ForEach(filters, id: \.self) { filter in
                    Button(action: { selected = filter }) {
                        ZStack {
                            if selected == filter {
                                GeometryReader { geo in
                                    let inset: CGFloat = 4
                                    let capsule = Capsule()
                                    capsule
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color(white: 0.26), Color(white: 0.19)]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .frame(
                                            width: geo.size.width - inset * 2,
                                            height: geo.size.height - inset * 2
                                        )
                                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                                        // Glassy highlight
                                        .overlay(
                                            Ellipse()
                                                .fill(Color.white.opacity(0.22))
                                                .frame(width: (geo.size.width - inset * 2) * 0.7, height: (geo.size.height - inset * 2) * 0.45)
                                                .offset(y: -(geo.size.height - inset * 2) * 0.18)
                                                .blur(radius: 7)
                                        )
                                        // Subtle border
                                        .overlay(
                                            capsule
                                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                                .frame(
                                                    width: geo.size.width - inset * 2,
                                                    height: geo.size.height - inset * 2
                                                )
                                                .position(x: geo.size.width / 2, y: geo.size.height / 2)
                                        )
                                        // Faint inner shadow at the bottom
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.black.opacity(0.18), lineWidth: 3)
                                                .blur(radius: 3)
                                                .frame(
                                                    width: geo.size.width - inset * 2,
                                                    height: geo.size.height - inset * 2
                                                )
                                                .position(x: geo.size.width / 2, y: geo.size.height / 2 + (geo.size.height - inset * 2) * 0.09)
                                                .mask(
                                                    Capsule()
                                                        .fill(
                                                            LinearGradient(
                                                                gradient: Gradient(stops: [
                                                                    .init(color: .clear, location: 0.0),
                                                                    .init(color: .black, location: 0.7)
                                                                ]),
                                                                startPoint: .top,
                                                                endPoint: .bottom
                                                            )
                                                        )
                                                )
                                        )
                                }
                            }
                            Text(filter)
                                .fontWeight(selected == filter ? .semibold : .regular)
                                .foregroundColor(selected == filter ? .white : .white.opacity(0.66))
                                .frame(maxWidth: .infinity)
                                .frame(height: 38)
                        }
                        .frame(height: 38)
                        .padding(.horizontal, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(height: 44)
            .clipShape(Capsule())
        }
        .frame(height: 44)
        .frame(minWidth: 250, maxWidth: 300)
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
        .fixedSize(horizontal: false, vertical: true)
    }
}



#Preview {
    FilterBar(
        selected: .constant("All Extensions"),
        filters: ["All Extensions", "Recently Added"]
    )
    .padding()
    .background(Color.black)
}
