//
//  FilePreviewViewModel.swift
//  Zeus-Testbed
//
//  Created by Gemini on 2024-07-29.
//

import SwiftUI
import PDFKit
import Combine

/// The view model for `FilePreviewView`.
///
/// This class is responsible for determining which type of preview
/// should be displayed for a given file.
@MainActor
class FilePreviewViewModel: ObservableObject {

    /// Represents the type of preview to display.
    enum PreviewType {
        case none
        case text(String)
        case image(Image)
        case pdf(PDFDocument)
        case unsupported(String?)
    }

    /// The currently selected file.
    @Published private(set) var selectedFile: FileItem?

    /// The computed preview content for the selected file.
    @Published private(set) var preview: PreviewType = .none

    init(file: FileItem? = nil) {
        self.selectedFile = file
        if let file = file {
            updatePreview(for: file)
        }
    }

    /// Update the view model with a new file selection.
    func update(with file: FileItem?) {
        selectedFile = file
        if let file = file {
            updatePreview(for: file)
        } else {
            preview = .none
        }
    }

    /// Determines the preview content based on the file type.
    private func updatePreview(for file: FileItem) {
        guard let url = file.url else {
            preview = .unsupported(nil)
            return
        }

        switch file.type {
        case .image:
            if let nsImage = NSImage(contentsOf: url) {
                preview = .image(Image(nsImage: nsImage))
            } else {
                preview = .unsupported(url.pathExtension)
            }
        case .text, .markdown, .code:
            if let content = try? String(contentsOf: url, encoding: .utf8) {
                preview = .text(content)
            } else {
                preview = .unsupported(url.pathExtension)
            }
        case .pdf:
            if let document = PDFDocument(url: url) {
                preview = .pdf(document)
            } else {
                preview = .unsupported(url.pathExtension)
            }
        default:
            preview = .unsupported(url.pathExtension)
        }
    }
}
