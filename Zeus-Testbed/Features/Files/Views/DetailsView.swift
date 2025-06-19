//
//  DetailsView.swift
//  Zeus-Testbed
//
//  View to display metadata and previews for a selected file.
//

import SwiftUI
import PDFKit

struct DetailsView: View {
    @ObservedObject var viewModel: DetailsViewModel
    @EnvironmentObject var notificationService: NotificationService
    var isSearchFocused: FocusState<Bool>.Binding
    private let theme = FilesTheme.current

    var body: some View {
        VStack(spacing: 0) {
            if let file = viewModel.file {
                fileDetailContent(for: file)
            } else {
                placeholder
            }
        }
        .frame(minWidth: 280, idealWidth: 350, maxWidth: 500)
        .background(theme.colors.background)
        .edgesIgnoringSafeArea(.bottom)
        .contentShape(Rectangle())
        .onTapGesture { isSearchFocused.wrappedValue = false }
    }
    
    @ViewBuilder
    private func fileDetailContent(for file: FileItem) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            header(for: file)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    previewSection(for: file)
                    
                    Divider().padding(.horizontal, theme.layout.padding)
                    
                    metadataSection(for: file)
                    
                    Divider().padding(.horizontal, theme.layout.padding)

                    tagSection(for: file)
                }
                .padding(.vertical)
            }
        }
    }
    
    private func header(for file: FileItem) -> some View {
        HStack {
            Image(systemName: file.type.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(file.type.iconColor)
            Text(file.name)
                .font(theme.fonts.title)
                .lineLimit(1)
            Spacer()
        }
        .padding(theme.layout.padding)
        .background(theme.colors.secondaryBackground)
        .overlay(Rectangle().frame(height: 1).foregroundColor(theme.colors.border), alignment: .bottom)
    }

    @ViewBuilder
    private func previewSection(for file: FileItem) -> some View {
        VStack {
            switch file.type {
            case .image:
                imagePreview(for: file)
            case .text, .markdown, .code:
                textPreview(for: file)
            case .pdf:
                pdfPreview(for: file)
            default:
                genericPreview(for: file)
            }
        }
        .padding(.horizontal, theme.layout.padding)
    }
    
    @ViewBuilder
    private func imagePreview(for file: FileItem) -> some View {
        if let url = file.url, let image = NSImage(contentsOf: url) {
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(theme.layout.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.layout.cornerRadius)
                        .stroke(theme.colors.border, lineWidth: theme.layout.borderWidth)
                )
        } else {
            genericPreview(for: file)
        }
    }
    
    @ViewBuilder
    private func textPreview(for file: FileItem) -> some View {
        if let url = file.url, let content = try? String(contentsOf: url, encoding: .utf8) {
            Text(content)
                .font(theme.fonts.body)
                .foregroundColor(theme.colors.textPrimary)
                .padding()
                .frame(maxWidth: .infinity, minHeight: 100, maxHeight: 300, alignment: .topLeading)
                .background(theme.colors.secondaryBackground)
                .cornerRadius(theme.layout.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.layout.cornerRadius)
                        .stroke(theme.colors.border, lineWidth: theme.layout.borderWidth)
                )
        } else {
            genericPreview(for: file)
        }
    }
    
    @ViewBuilder
    private func pdfPreview(for file: FileItem) -> some View {
        if let url = file.url {
            PDFKitRepresentedView(url: url)
                .frame(height: 300)
                .cornerRadius(theme.layout.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.layout.cornerRadius)
                        .stroke(theme.colors.border, lineWidth: theme.layout.borderWidth)
                )
        } else {
            genericPreview(for: file)
        }
    }

    private func genericPreview(for file: FileItem) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "eye.slash")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(theme.colors.textTertiary)
            Text("No preview available")
                .font(theme.fonts.body)
                .foregroundColor(theme.colors.textSecondary)
            Text("Preview for .\(file.url?.pathExtension ?? "file") files is not supported.")
                .font(theme.fonts.caption)
                .foregroundColor(theme.colors.textTertiary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .background(theme.colors.secondaryBackground.opacity(0.5))
        .background(.ultraThinMaterial)
        .cornerRadius(theme.layout.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: theme.layout.cornerRadius)
                .stroke(theme.colors.border, lineWidth: theme.layout.borderWidth)
        )
    }
    
    private func metadataSection(for file: FileItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            DetailRow(label: "Type", value: file.type.rawValue.capitalized)
            DetailRow(label: "Size", value: file.sizeString)
            DetailRow(label: "Modified", value: file.modifiedAt.formatted(date: .long, time: .shortened))
            DetailRow(label: "Created", value: file.createdAt.formatted(date: .long, time: .shortened))
        }
        .padding(.horizontal, theme.layout.padding)
    }

    private func tagSection(for file: FileItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tags")
                .font(theme.fonts.body.weight(.medium))
                .foregroundColor(theme.colors.textSecondary)

            // Using a custom FlowLayout view would be ideal here for wrapping tags.
            // For now, a simple HStack is used.
            HStack {
                ForEach(file.tags) { tag in
                    TagPill(tag: tag)
                }
                
                Button(action: {
                    viewModel.isShowingTagPopover = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: 24, height: 24)
                .background(theme.colors.secondaryBackground)
                .clipShape(Circle())
                .overlay(Circle().stroke(theme.colors.border, lineWidth: 1))
                .popover(isPresented: $viewModel.isShowingTagPopover, arrowEdge: .bottom) {
                    TagManagementView(viewModel: viewModel)
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, theme.layout.padding)
    }
    
    private var placeholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 40, weight: .light))
                .foregroundColor(theme.colors.textTertiary)
            Text("Select a file")
                .font(theme.fonts.title)
                .foregroundColor(theme.colors.textPrimary)
            Text("Details and a preview will appear here.")
                .font(theme.fonts.body)
                .foregroundColor(theme.colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// A reusable row for displaying metadata
struct DetailRow: View {
    let label: String
    let value: String
    private let theme = FilesTheme.current

    var body: some View {
        HStack {
            Text(label)
                .font(theme.fonts.body)
                .foregroundColor(theme.colors.textSecondary)
            Spacer()
            Text(value)
                .font(theme.fonts.body.weight(.medium))
                .foregroundColor(theme.colors.textPrimary)
        }
    }
}

// MARK: - PDFKit Wrapper
struct PDFKitRepresentedView: NSViewRepresentable {
    let url: URL

    func makeNSView(context: NSViewRepresentableContext<PDFKitRepresentedView>) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: self.url)
        pdfView.autoScales = true
        pdfView.backgroundColor = .clear
        return pdfView
    }

    func updateNSView(_ nsView: PDFView, context: NSViewRepresentableContext<PDFKitRepresentedView>) {
        // Update the view if needed
    }
}

// MARK: - Preview
#if DEBUG
struct DetailsView_Previews: PreviewProvider {
    @FocusState static var isFocused: Bool
    
    static var previews: some View {
        Group {
            DetailsView(viewModel: .noFileSelected, isSearchFocused: $isFocused)
                .previewDisplayName("No File Selected")

            DetailsView(viewModel: .fileSelected, isSearchFocused: $isFocused)
                .previewDisplayName("File Selected")
        }
        .environmentObject(NotificationService())
        .preferredColorScheme(.dark)
        .frame(width: 350)
    }
}
#endif 