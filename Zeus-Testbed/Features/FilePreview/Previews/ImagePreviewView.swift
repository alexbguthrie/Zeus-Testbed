//
//  ImagePreviewView.swift
//  Zeus-Testbed
//
//  Created by Gemini on 2024-07-29.
//

import SwiftUI

/// A view that displays an image.
struct ImagePreviewView: View {
    let image: Image
    
    var body: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding()
    }
}

#Preview {
    ImagePreviewView(image: Image(systemName: "photo"))
        .frame(width: 400, height: 600)
} 