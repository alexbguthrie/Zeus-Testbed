//
//  PaginationView.swift
//  Zeus-Testbed
//
//  Created by Alex Guthrie on 6/20/25.
//


import SwiftUI

struct PaginationView: View {
    @Binding var currentPage: Int
    let pageCount: Int

    let visiblePages = 5 // How many numbers to show before separator

    var body: some View {
        HStack(spacing: 16) {
            // First few pages
            ForEach(1...visiblePages, id: \.self) { page in
                pageButton(page)
            }

            // Separator
            Text("—")
                .foregroundColor(.white.opacity(0.26))
                .font(.system(size: 22, weight: .light))
                .padding(.horizontal, 4)

            // Last page
            pageButton(pageCount)

            // Next arrow
            Button(action: {
                if currentPage < pageCount { currentPage += 1 }
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white.opacity(currentPage < pageCount ? 0.7 : 0.23))
                    .frame(width: 38, height: 38)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.white.opacity(0.10), lineWidth: 1.2)
                    )
            }
            .disabled(currentPage >= pageCount)
        }
        .padding(.top, 32)
    }

    @ViewBuilder
    private func pageButton(_ page: Int) -> some View {
        Button(action: { currentPage = page }) {
            Text("\(page)")
                .font(.system(size: 19, weight: .medium, design: .rounded))
                .foregroundColor(currentPage == page ? .white : .white.opacity(0.48))
                .frame(width: 38, height: 38)
                .background(
                    Group {
                        if currentPage == page {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.white.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(Color.white.opacity(0.16), lineWidth: 1.2)
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.white.opacity(0.10), lineWidth: 1.2)
                        }
                    }
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    PaginationView(currentPage: .constant(1), pageCount: 216)
        .padding()
        .background(Color.black)
        .preferredColorScheme(.dark)
}
