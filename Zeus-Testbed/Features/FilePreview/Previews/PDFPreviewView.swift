//
//  PDFPreviewView.swift
//  Zeus-Testbed
//
//  Created by Gemini on 2024-07-29.
//

import SwiftUI
import PDFKit

/// A view that displays a PDF document.
struct PDFPreviewView: View {
    let pdfDocument: PDFDocument
    
    var body: some View {
        PDFKitView(pdfDocument: pdfDocument)
    }
}

struct PDFKitView: NSViewRepresentable {
    let pdfDocument: PDFDocument
    
    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = pdfDocument
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateNSView(_ nsView: PDFView, context: Context) {
        nsView.document = pdfDocument
    }
}

#Preview {
    // Creating a dummy PDF for preview is non-trivial.
    // We will rely on runtime previews for this view.
    // For now, a placeholder.
    Text("PDF Preview Placeholder")
        .frame(width: 400, height: 600)
} 