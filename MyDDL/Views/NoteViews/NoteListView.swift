import SwiftUI

struct NoteListView: View {
    @EnvironmentObject var dataStore: DataStore
    @Binding var selectedNote: Note?
    @Binding var listWidth: CGFloat
    @Binding var isCollapsed: Bool

    private let minWidth: CGFloat = 160
    private let maxWidth: CGFloat = 350

    var body: some View {
        HStack(spacing: 0) {
            if !isCollapsed {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: { withAnimation(.spring(response: 0.3)) { isCollapsed = true } }) {
                            Image(systemName: "sidebar.left")
                                .font(.system(size: 12))
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                        }
                        .buttonStyle(.plain)
                        .help("收起列表")

                        Text("笔记列表")
                            .font(DesignSystem.Fonts.caption)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                            .textCase(.uppercase)
                            .tracking(1.5)

                        Spacer()

                        Button(action: createNewNote) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [DesignSystem.Colors.accent, DesignSystem.Colors.accentLight],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .buttonStyle(.plain)
                        .hoverEffect(scale: 1.15)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.md)

                    Rectangle()
                        .fill(DesignSystem.Colors.divider)
                        .frame(height: 1)

                    // Note list
                    if dataStore.notes.isEmpty {
                        VStack(spacing: DesignSystem.Spacing.md) {
                            Spacer()
                            Image(systemName: "note.text")
                                .font(.system(size: 40))
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                            Text("暂无笔记")
                                .font(DesignSystem.Fonts.body)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                            Text("点击 + 创建")
                                .font(DesignSystem.Fonts.caption)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: DesignSystem.Spacing.xs) {
                                ForEach(dataStore.sortedNotes(editing: selectedNote?.id)) { note in
                                    NoteRowView(
                                        note: note,
                                        isSelected: selectedNote?.id == note.id,
                                        onTap: { selectedNote = note },
                                        onDelete: { dataStore.deleteNote(note) },
                                        onTogglePin: { dataStore.toggleNotePin(note) }
                                    )
                                }
                            }
                            .padding(.vertical, DesignSystem.Spacing.sm)
                        }
                    }
                }
                .frame(width: listWidth)
                .background(DesignSystem.Colors.cardBackground)

                // Resize handle
                Color.clear
                    .frame(width: 6)
                    .overlay(
                        Rectangle()
                            .fill(DesignSystem.Colors.divider)
                            .frame(width: 1)
                    )
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let newWidth = listWidth + value.translation.width
                                listWidth = min(max(newWidth, minWidth), maxWidth)
                            }
                    )
                    .onHover { hovering in
                        if hovering {
                            NSCursor.resizeLeftRight.push()
                        } else {
                            NSCursor.pop()
                        }
                    }
            } else {
                // Collapsed state - just show expand button
                VStack {
                    Button(action: { withAnimation(.spring(response: 0.3)) { isCollapsed = false } }) {
                        Image(systemName: "sidebar.right")
                            .font(.system(size: 14))
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                            .frame(width: 28, height: 28)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.Radius.small)
                                    .fill(DesignSystem.Colors.elevatedBackground)
                            )
                    }
                    .buttonStyle(.plain)
                    .help("展开列表")
                    .padding(.top, DesignSystem.Spacing.md)

                    Spacer()
                }
                .frame(width: 36)
                .background(DesignSystem.Colors.cardBackground)
            }
        }
    }

    private func createNewNote() {
        let newNote = Note(title: "", content: "")
        dataStore.addNote(newNote)
        selectedNote = newNote
    }
}

struct NoteRowView: View {
    let note: Note
    let isSelected: Bool
    var onTap: () -> Void
    var onDelete: () -> Void
    var onTogglePin: () -> Void

    @State private var isHovered = false

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            // Pin indicator
            if note.isPinned {
                Image(systemName: "pin.fill")
                    .font(.system(size: 10))
                    .foregroundColor(DesignSystem.Colors.accent)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(note.displayTitle)
                    .font(DesignSystem.Fonts.body)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? DesignSystem.Colors.textPrimary : DesignSystem.Colors.textSecondary)
                    .lineLimit(1)

                Text(note.formattedDate)
                    .font(DesignSystem.Fonts.tiny)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }

            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                .fill(isSelected ? DesignSystem.Colors.accent.opacity(0.1) : (isHovered ? Color.black.opacity(0.03) : Color.clear))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.medium)
                        .stroke(isSelected ? DesignSystem.Colors.accent.opacity(0.2) : Color.clear, lineWidth: 1)
                )
        )
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        .onHover { hovering in isHovered = hovering }
        .contextMenu {
            Button(action: onTogglePin) {
                Label(note.isPinned ? "取消置顶" : "置顶", systemImage: note.isPinned ? "pin.slash" : "pin")
            }
            Divider()
            Button(role: .destructive, action: onDelete) {
                Label("删除", systemImage: "trash")
            }
        }
    }
}
