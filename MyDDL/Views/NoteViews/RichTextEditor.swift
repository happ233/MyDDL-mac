import SwiftUI
import AppKit

// MARK: - Rich Text Editor
struct RichTextEditor: NSViewRepresentable {
    @Binding var attributedText: NSAttributedString
    var onTextChange: (() -> Void)?
    var currentTheme: AppTheme  // 显式传入主题，确保主题变化时触发更新

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView

        textView.delegate = context.coordinator
        textView.isRichText = true
        textView.allowsUndo = true
        textView.isEditable = true
        textView.isSelectable = true
        textView.usesFontPanel = true
        textView.usesRuler = false
        textView.importsGraphics = true
        textView.allowsImageEditing = true

        // Enable drag and drop for images
        textView.registerForDraggedTypes([.png, .tiff, .fileURL, .URL])

        // Styling
        textView.backgroundColor = NSColor.clear
        textView.drawsBackground = false
        textView.textContainerInset = NSSize(width: 8, height: 8)

        // Default font and color based on theme
        textView.font = NSFont.systemFont(ofSize: 14)
        updateTextColor(textView)

        // Set initial content
        if attributedText.length > 0 {
            textView.textStorage?.setAttributedString(attributedText)
        }

        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false

        // Ensure text view accepts first responder
        textView.isFieldEditor = false
        scrollView.contentView.postsBoundsChangedNotifications = true

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }

        debugLog("[RichTextEditor] updateNSView called, theme: \(currentTheme.rawValue)")

        // First: update content if not editing (to avoid cursor jumping)
        if !context.coordinator.isEditing {
            let currentText = textView.textStorage?.copy() as? NSAttributedString ?? NSAttributedString()
            if !currentText.isEqual(to: attributedText) {
                textView.textStorage?.setAttributedString(attributedText)
            }
        }

        // Then: update text color AFTER content is set
        updateTextColor(textView)
    }

    private func updateTextColor(_ textView: NSTextView) {
        let textColor: NSColor
        switch currentTheme {
        case .dark:
            textColor = NSColor.white
        case .cream, .lightGray:
            textColor = NSColor.black
        }

        debugLog("[RichTextEditor] updateTextColor: theme=\(currentTheme.rawValue), color=\(textColor == NSColor.white ? "white" : "black"), textLength=\(textView.textStorage?.length ?? 0)")

        textView.textColor = textColor
        textView.insertionPointColor = textColor

        // Update typing attributes
        var typingAttrs = textView.typingAttributes
        typingAttrs[.foregroundColor] = textColor
        textView.typingAttributes = typingAttrs

        // Update existing text color in textStorage
        if let textStorage = textView.textStorage, textStorage.length > 0 {
            let fullRange = NSRange(location: 0, length: textStorage.length)
            textStorage.beginEditing()
            textStorage.addAttribute(.foregroundColor, value: textColor, range: fullRange)
            textStorage.endEditing()

            // Force layout manager to redraw
            textView.layoutManager?.invalidateDisplay(forCharacterRange: fullRange)
            textView.setNeedsDisplay(textView.bounds)
            debugLog("[RichTextEditor] Updated foregroundColor for range 0..\(textStorage.length)")
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: RichTextEditor
        var isEditing = false

        init(_ parent: RichTextEditor) {
            self.parent = parent
        }

        func textDidBeginEditing(_ notification: Notification) {
            isEditing = true
        }

        func textDidEndEditing(_ notification: Notification) {
            isEditing = false
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView,
                  let textStorage = textView.textStorage else { return }

            let newAttributedString = NSAttributedString(attributedString: textStorage)
            DispatchQueue.main.async {
                self.parent.attributedText = newAttributedString
                self.parent.onTextChange?()
            }
        }
    }
}

// MARK: - Format Toolbar
struct RichTextToolbar: View {
    @Binding var attributedText: NSAttributedString
    var textView: NSTextView?
    var onFormatChange: (() -> Void)?

    @State private var selectedFontSize: CGFloat = 14
    @State private var isBold = false
    @State private var isItalic = false
    @State private var isUnderline = false

    private let fontSizes: [CGFloat] = [10, 12, 14, 16, 18, 20, 24, 28, 32, 36, 48]

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            // Font size picker
            Menu {
                ForEach(fontSizes, id: \.self) { size in
                    Button("\(Int(size)) pt") {
                        applyFontSize(size)
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text("\(Int(selectedFontSize))")
                        .font(.system(size: 12))
                    Image(systemName: "chevron.down")
                        .font(.system(size: 8))
                }
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(DesignSystem.Colors.elevatedBackground)
                )
            }
            .buttonStyle(.plain)

            Divider()
                .frame(height: 20)

            // Bold
            ToolbarButton(
                icon: "bold",
                isActive: isBold,
                action: toggleBold
            )

            // Italic
            ToolbarButton(
                icon: "italic",
                isActive: isItalic,
                action: toggleItalic
            )

            // Underline
            ToolbarButton(
                icon: "underline",
                isActive: isUnderline,
                action: toggleUnderline
            )

            Divider()
                .frame(height: 20)

            // Insert checkbox
            ToolbarButton(
                icon: "checklist",
                isActive: false,
                action: insertCheckbox
            )

            // Insert image
            ToolbarButton(
                icon: "photo",
                isActive: false,
                action: insertImage
            )

            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(DesignSystem.Colors.elevatedBackground)
    }

    private func applyFontSize(_ size: CGFloat) {
        selectedFontSize = size
        guard let textView = getFirstResponderTextView() else { return }
        let range = textView.selectedRange()

        if range.length > 0 {
            textView.textStorage?.beginEditing()
            textView.textStorage?.enumerateAttribute(.font, in: range, options: []) { value, attrRange, _ in
                if let font = value as? NSFont {
                    let newFont = NSFontManager.shared.convert(font, toSize: size)
                    textView.textStorage?.addAttribute(.font, value: newFont, range: attrRange)
                }
            }
            textView.textStorage?.endEditing()
        } else {
            let font = NSFont.systemFont(ofSize: size)
            textView.typingAttributes[.font] = font
        }
        onFormatChange?()
    }

    private func toggleBold() {
        isBold.toggle()
        guard let textView = getFirstResponderTextView() else { return }
        let range = textView.selectedRange()

        if range.length > 0 {
            textView.textStorage?.beginEditing()
            textView.textStorage?.enumerateAttribute(.font, in: range, options: []) { value, attrRange, _ in
                if let font = value as? NSFont {
                    let newFont: NSFont
                    if isBold {
                        newFont = NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask)
                    } else {
                        newFont = NSFontManager.shared.convert(font, toNotHaveTrait: .boldFontMask)
                    }
                    textView.textStorage?.addAttribute(.font, value: newFont, range: attrRange)
                }
            }
            textView.textStorage?.endEditing()
        } else {
            if let font = textView.typingAttributes[.font] as? NSFont {
                let newFont: NSFont
                if isBold {
                    newFont = NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask)
                } else {
                    newFont = NSFontManager.shared.convert(font, toNotHaveTrait: .boldFontMask)
                }
                textView.typingAttributes[.font] = newFont
            }
        }
        onFormatChange?()
    }

    private func toggleItalic() {
        isItalic.toggle()
        guard let textView = getFirstResponderTextView() else { return }
        let range = textView.selectedRange()

        if range.length > 0 {
            textView.textStorage?.beginEditing()
            textView.textStorage?.enumerateAttribute(.font, in: range, options: []) { value, attrRange, _ in
                if let font = value as? NSFont {
                    let newFont: NSFont
                    if isItalic {
                        newFont = NSFontManager.shared.convert(font, toHaveTrait: .italicFontMask)
                    } else {
                        newFont = NSFontManager.shared.convert(font, toNotHaveTrait: .italicFontMask)
                    }
                    textView.textStorage?.addAttribute(.font, value: newFont, range: attrRange)
                }
            }
            textView.textStorage?.endEditing()
        } else {
            if let font = textView.typingAttributes[.font] as? NSFont {
                let newFont: NSFont
                if isItalic {
                    newFont = NSFontManager.shared.convert(font, toHaveTrait: .italicFontMask)
                } else {
                    newFont = NSFontManager.shared.convert(font, toNotHaveTrait: .italicFontMask)
                }
                textView.typingAttributes[.font] = newFont
            }
        }
        onFormatChange?()
    }

    private func toggleUnderline() {
        isUnderline.toggle()
        guard let textView = getFirstResponderTextView() else { return }
        let range = textView.selectedRange()

        if range.length > 0 {
            textView.textStorage?.beginEditing()
            let style: NSUnderlineStyle = isUnderline ? .single : []
            textView.textStorage?.addAttribute(.underlineStyle, value: style.rawValue, range: range)
            textView.textStorage?.endEditing()
        } else {
            let style: NSUnderlineStyle = isUnderline ? .single : []
            textView.typingAttributes[.underlineStyle] = style.rawValue
        }
        onFormatChange?()
    }

    private func insertCheckbox() {
        guard let textView = getFirstResponderTextView() else { return }
        let checkboxString = NSAttributedString(string: "☐ ", attributes: [
            .font: NSFont.systemFont(ofSize: selectedFontSize)
        ])
        textView.textStorage?.insert(checkboxString, at: textView.selectedRange().location)
        onFormatChange?()
    }

    private func insertImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false

        if panel.runModal() == .OK, let url = panel.url {
            guard let textView = getFirstResponderTextView() else { return }

            if let image = NSImage(contentsOf: url) {
                // Resize image if too large
                let maxWidth: CGFloat = 400
                let resizedImage: NSImage
                if image.size.width > maxWidth {
                    let ratio = maxWidth / image.size.width
                    let newSize = NSSize(width: maxWidth, height: image.size.height * ratio)
                    resizedImage = NSImage(size: newSize)
                    resizedImage.lockFocus()
                    image.draw(in: NSRect(origin: .zero, size: newSize))
                    resizedImage.unlockFocus()
                } else {
                    resizedImage = image
                }

                // Save image to file system
                guard let filename = ImageManager.shared.saveImage(resizedImage) else {
                    debugLog("[RichTextToolbar] Failed to save image")
                    return
                }

                // Create attachment with file reference
                let attachment = FileImageTextAttachment(image: resizedImage, filename: filename)

                let imageString = NSAttributedString(attachment: attachment)
                textView.textStorage?.insert(imageString, at: textView.selectedRange().location)
                textView.textStorage?.insert(NSAttributedString(string: "\n"), at: textView.selectedRange().location + 1)
                onFormatChange?()
            }
        }
    }

    private func getFirstResponderTextView() -> NSTextView? {
        return NSApp.keyWindow?.firstResponder as? NSTextView
    }
}

// MARK: - Toolbar Button
struct ToolbarButton: View {
    let icon: String
    let isActive: Bool
    var action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: isActive ? .bold : .regular))
                .foregroundColor(isActive ? DesignSystem.Colors.accent : DesignSystem.Colors.textSecondary)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isActive ? DesignSystem.Colors.accent.opacity(0.15) : (isHovered ? Color.black.opacity(0.05) : Color.clear))
                )
        }
        .buttonStyle(.plain)
        .onHover { hovering in isHovered = hovering }
    }
}
