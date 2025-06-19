//
//  FilePreviewView.swift
//  Zeus-Testbed
//
//  Created by Gemini on 2024-07-29.
//

import SwiftUI

/// A view that displays a preview of a selected file.
///
/// This view acts as a container that switches between different
/// preview types (e.g., text, image, PDF) based on the file's extension.
struct FilePreviewView: View {
    var body: some View {
        Text("File Preview")
    }
}

#Preview {
    FilePreviewView()
        .frame(width: 400, height: 600)
} 