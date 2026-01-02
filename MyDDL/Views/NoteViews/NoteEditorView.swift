import SwiftUI
import AppKit

// MARK: - NSView Extension for finding scroll view
extension NSView {
    func findScrollView() -> NSScrollView? {
        if let scrollView = self as? NSScrollView {
            return scrollView
        }
        for subview in subviews {
            if let found = subview.findScrollView() {
                return found
            }
        }
        return nil
    }
}

struct NoteEditorView: View {
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var note: Note?

    @State private var title: String = ""
    @State private var attributedContent: NSAttributedString = NSAttributedString()

    var body: some View {
        VStack(spacing: 0) {
            if let currentNote = note {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("编辑笔记")
                            .font(DesignSystem.Fonts.title)
                            .foregroundColor(DesignSystem.Colors.textPrimary)

                        Text(currentNote.formattedDate)
                            .font(DesignSystem.Fonts.caption)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                    }

                    Spacer()

                    Button(action: deleteNote) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(DesignSystem.Colors.danger)
                            .frame(width: 32, height: 32)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.Radius.small)
                                    .fill(DesignSystem.Colors.danger.opacity(0.1))
                            )
                    }
                    .buttonStyle(.plain)
                    .hoverEffect(scale: 1.1)
                }
                .padding(DesignSystem.Spacing.xl)

                Rectangle()
                    .fill(DesignSystem.Colors.divider)
                    .frame(height: 1)

                // Title field
                VStack(spacing: 0) {
                    TextField("标题（可选）", text: $title)
                        .textFieldStyle(.plain)
                        .font(DesignSystem.Fonts.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .padding(DesignSystem.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                                .fill(DesignSystem.Colors.elevatedBackground)
                        )
                        .padding(.horizontal, DesignSystem.Spacing.xl)
                        .padding(.top, DesignSystem.Spacing.lg)
                        .onChange(of: title) { _, newValue in
                            saveChanges()
                        }

                    // Format toolbar
                    RichTextToolbar(
                        attributedText: $attributedContent,
                        onFormatChange: saveChanges
                    )
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.top, DesignSystem.Spacing.md)

                    // Rich text editor
                    RichTextEditor(
                        attributedText: $attributedContent,
                        onTextChange: saveChanges,
                        currentTheme: themeManager.currentTheme
                    )
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                            .fill(DesignSystem.Colors.elevatedBackground)
                    )
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.vertical, DesignSystem.Spacing.md)
                }
            } else {
                // Empty state
                VStack(spacing: DesignSystem.Spacing.lg) {
                    Spacer()
                    Image(systemName: "note.text")
                        .font(.system(size: 60))
                        .foregroundColor(DesignSystem.Colors.textTertiary.opacity(0.5))
                    Text("选择或创建一个笔记")
                        .font(DesignSystem.Fonts.headline)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(DesignSystem.Colors.secondaryBackground)
        .onChange(of: note?.id) { _, _ in
            // Reset content when note changes
            if let n = note {
                title = n.title
                attributedContent = n.attributedContent
            } else {
                title = ""
                attributedContent = NSAttributedString()
            }
        }
        .onAppear {
            if let n = note {
                title = n.title
                attributedContent = n.attributedContent
            }
        }
    }

    private func saveChanges() {
        guard var currentNote = note else { return }
        currentNote.title = title
        currentNote.setAttributedContent(attributedContent)
        dataStore.updateNote(currentNote)
        // Update the binding to reflect changes
        note = dataStore.notes.first { $0.id == currentNote.id }
    }

    private func deleteNote() {
        guard let currentNote = note else { return }
        dataStore.deleteNote(currentNote)
        note = nil
    }
}
