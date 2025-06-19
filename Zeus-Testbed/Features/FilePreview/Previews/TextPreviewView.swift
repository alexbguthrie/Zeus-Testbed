//
//  TextPreviewView.swift
//  Zeus-Testbed
//
//  Created by Gemini on 2024-07-29.
//

import SwiftUI

/// A view that displays the contents of a text-based file.
struct TextPreviewView: View {
    let content: String
    
    var body: some View {
        ScrollView {
            Text(content)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
    }
}

#Preview {
    TextPreviewView(content: "This is a sample text file.\n\nIt has multiple lines.")
        .frame(width: 400, height: 600)
} 