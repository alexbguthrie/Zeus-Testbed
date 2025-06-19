//
//  UnsupportedPreviewView.swift
//  Zeus-Testbed
//
//  Created by Gemini on 2024-07-29.
//

import SwiftUI

/// A view that indicates that a file type is not supported for previewing.
struct UnsupportedPreviewView: View {
    let fileExtension: String?
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc")
                .font(.system(size: 50))
            
            if let fileExtension, !fileExtension.isEmpty {
                Text("Cannot Preview `.\(fileExtension)`")
                    .font(.headline)
            } else {
                Text("No Preview Available")
                    .font(.headline)
            }
            
            Text("This file type is not currently supported for previews.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    UnsupportedPreviewView(fileExtension: "zip")
        .frame(width: 400, height: 600)
}

#Preview("No Extension") {
    UnsupportedPreviewView(fileExtension: nil)
        .frame(width: 400, height: 600)
} 