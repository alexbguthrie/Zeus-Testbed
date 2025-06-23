import SwiftUI

/// A simple sheet that allows the user to create a file from one of several templates.
struct NewFileTemplateView: View {
    @ObservedObject var viewModel: FileBrowserViewModel
    @EnvironmentObject var notificationService: NotificationService
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTemplate: FileTemplate = FileTemplate.all.first!
    @State private var fileName: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose a Template")
                .font(.headline)

            Picker("Template", selection: $selectedTemplate) {
                ForEach(FileTemplate.all) { template in
                    Text(template.displayName).tag(template)
                }
            }
            .pickerStyle(.radioGroup)

            TextField("File name", text: $fileName)
                .textFieldStyle(.roundedBorder)

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                Button("Create") {
                    let finalName = selectedTemplate.filename(for: fileName)
                    viewModel.createNewFile(named: finalName,
                                             type: selectedTemplate.fileType,
                                             template: selectedTemplate.content,
                                             notificationService: notificationService)
                    dismiss()
                }
                .disabled(fileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding()
        .frame(width: 300)
    }
}

/// Represents a built-in file template.
struct FileTemplate: Identifiable, Hashable {
    let id = UUID()
    let displayName: String
    let fileExtension: String
    let content: String
    let fileType: FileType

    func filename(for name: String) -> String {
        if name.lowercased().hasSuffix(".\(fileExtension)") {
            return name
        } else {
            return "\(name).\(fileExtension)"
        }
    }

    static let swift = FileTemplate(displayName: "Swift File",
                                    fileExtension: "swift",
                                    content: "import Foundation\n\n",
                                    fileType: .code)

    static let text = FileTemplate(displayName: "Text File",
                                   fileExtension: "txt",
                                   content: "",
                                   fileType: .text)

    static let markdown = FileTemplate(displayName: "Markdown File",
                                       fileExtension: "md",
                                       content: "# New Document\n\n",
                                       fileType: .markdown)

    static let all: [FileTemplate] = [.swift, .text, .markdown]
}


