//
//  FilePreviewView.swift
//  Zeus-Testbed
//
//  Created by Gemini on 2024-07-29.
//

import SwiftUI
import PDFKit

/// A view that displays a preview of a selected file.
///
/// This view acts as a container that switches between different
/// preview types (e.g., text, image, PDF) based on the file's extension.
struct FilePreviewView: View {
    @ObservedObject var viewModel: FilePreviewViewModel

    var body: some View {
        switch viewModel.preview {
        case .text(let content):
            TextPreviewView(content: content)
        case .image(let image):
            ImagePreviewView(image: image)
        case .pdf(let document):
            PDFPreviewView(pdfDocument: document)
        case .unsupported(let ext):
            UnsupportedPreviewView(fileExtension: ext)
        case .none:
            UnsupportedPreviewView(fileExtension: viewModel.selectedFile?.url?.pathExtension)
        }
    }
}

#Preview {
    let dummy = FileItem(name: "demo.txt", type: .text)
    let vm = FilePreviewViewModel(file: dummy)
    return FilePreviewView(viewModel: vm)
        .frame(width: 400, height: 600)
}
