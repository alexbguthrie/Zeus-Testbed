//
//  TagManagementView.swift
//  Zeus-Testbed
//
// A view for adding, removing, and creating tags for a file.
//

import SwiftUI

struct TagManagementView: View {
    @ObservedObject var viewModel: DetailsViewModel
    @State private var newTagName = ""
    @EnvironmentObject var notificationService: NotificationService
    private let theme = FilesTheme.current
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Assign Tags")
                .font(theme.fonts.body.weight(.medium))
                .foregroundColor(theme.colors.textSecondary)
                .padding([.horizontal, .top])
                .padding(.bottom, 8)

            if let file = viewModel.file {
                tagListView(for: file)
                
                Divider()
                
                newTagInputView(for: file)
                    .padding()
            }
        }
        .frame(width: 280)
        .background(theme.colors.secondaryBackground)
    }
    
    @ViewBuilder
    private func tagListView(for file: FileItem) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(viewModel.allTags) { tag in
                    Button(action: {
                        toggleTag(tag, for: file)
                    }) {
                        HStack {
                            TagPill(tag: tag, size: .small)
                            Spacer()
                            if file.tags.contains(where: { $0.id == tag.id }) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(theme.colors.accent)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxHeight: 200)
    }
    
    private func newTagInputView(for file: FileItem) -> some View {
        HStack {
            TextField("New tag name...", text: $newTagName)
                .textFieldStyle(PlainTextFieldStyle())
                .font(theme.fonts.body)
                .padding(8)
                .background(theme.colors.background)
                .cornerRadius(6)

            Button("Create") {
                viewModel.createAndAssignTag(named: newTagName, to: file, notificationService: notificationService)
                newTagName = ""
            }
            .buttonStyle(AccentButtonStyle())
            .disabled(newTagName.isEmpty)
        }
    }
    
    private func toggleTag(_ tag: Tag, for file: FileItem) {
        if file.tags.contains(where: { $0.id == tag.id }) {
            viewModel.removeTag(tag, from: file)
        } else {
            viewModel.addTag(tag, to: file)
        }
    }
}

// A reusable accent color button style
struct AccentButtonStyle: ButtonStyle {
    private let theme = FilesTheme.current
    @Environment(\.isEnabled) private var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(theme.fonts.body.weight(.medium))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isEnabled ? theme.colors.accent : theme.colors.textTertiary)
            .foregroundColor(isEnabled ? theme.colors.accentForeground : theme.colors.textSecondary)
            .cornerRadius(6)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#if DEBUG
struct TagManagementView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = DetailsViewModel.fileSelected
        return TagManagementView(viewModel: vm)
            .padding()
            .background(Color.black)
            .environmentObject(NotificationService())
            .preferredColorScheme(.dark)
    }
}
#endif 