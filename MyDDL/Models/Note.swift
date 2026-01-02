import Foundation
import SwiftUI
import AppKit

struct Note: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var content: String  // Plain text fallback
    var rtfData: Data?   // Rich text data (RTFD format for images)
    var createdAt: Date
    var updatedAt: Date
    var isPinned: Bool   // 置顶

    init(
        id: UUID = UUID(),
        title: String = "",
        content: String = "",
        rtfData: Data? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isPinned: Bool = false
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.rtfData = rtfData
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isPinned = isPinned
    }

    var displayTitle: String {
        if title.isEmpty {
            let firstLine = content.components(separatedBy: .newlines).first ?? ""
            return firstLine.isEmpty ? "无标题笔记" : String(firstLine.prefix(30))
        }
        return title
    }

    var previewText: String {
        let text = content.trimmingCharacters(in: .whitespacesAndNewlines)
        return String(text.prefix(100))
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(updatedAt) {
            formatter.dateFormat = "HH:mm"
            return "今天 " + formatter.string(from: updatedAt)
        } else if calendar.isDateInYesterday(updatedAt) {
            formatter.dateFormat = "HH:mm"
            return "昨天 " + formatter.string(from: updatedAt)
        } else if calendar.isDate(updatedAt, equalTo: Date(), toGranularity: .year) {
            formatter.dateFormat = "MM月dd日"
            return formatter.string(from: updatedAt)
        } else {
            formatter.dateFormat = "yyyy年MM月dd日"
            return formatter.string(from: updatedAt)
        }
    }

    // MARK: - Rich Text Helpers

    /// Get attributed string from stored RTF data, restoring images from file system
    var attributedContent: NSAttributedString {
        if let data = rtfData {
            // Try RTFD first (supports images)
            if let attrString = NSAttributedString(rtfd: data, documentAttributes: nil) {
                return restoreImagesFromFileSystem(attrString)
            }
            // Fallback to RTF
            if let attrString = NSAttributedString(rtf: data, documentAttributes: nil) {
                return attrString
            }
        }
        // Fallback to plain text
        return NSAttributedString(string: content, attributes: [
            .font: NSFont.systemFont(ofSize: 14),
            .foregroundColor: NSColor.labelColor
        ])
    }

    /// Restore images from file system based on attachment filenames
    private func restoreImagesFromFileSystem(_ attributedString: NSAttributedString) -> NSAttributedString {
        let mutableString = NSMutableAttributedString(attributedString: attributedString)
        let range = NSRange(location: 0, length: mutableString.length)

        mutableString.enumerateAttribute(.attachment, in: range, options: []) { value, attrRange, _ in
            if let attachment = value as? NSTextAttachment,
               let fileWrapper = attachment.fileWrapper,
               let filename = fileWrapper.preferredFilename,
               filename.hasSuffix(".png") {
                // Load image from file system
                if let image = ImageManager.shared.loadImage(filename: filename) {
                    let newAttachment = FileImageTextAttachment(image: image, filename: filename)
                    mutableString.removeAttribute(.attachment, range: attrRange)
                    mutableString.addAttribute(.attachment, value: newAttachment, range: attrRange)
                }
            }
        }

        return mutableString
    }

    /// Update from attributed string
    mutating func setAttributedContent(_ attributedString: NSAttributedString) {
        // Store as RTFD (supports images with file references)
        let range = NSRange(location: 0, length: attributedString.length)
        if let data = attributedString.rtfd(from: range, documentAttributes: [:]) {
            self.rtfData = data
        } else if let data = attributedString.rtf(from: range, documentAttributes: [:]) {
            self.rtfData = data
        }
        // Also store plain text for search/preview
        self.content = attributedString.string
    }

    /// Get all image filenames referenced in this note
    var imageFilenames: [String] {
        guard let data = rtfData,
              let attrString = NSAttributedString(rtfd: data, documentAttributes: nil) else {
            return []
        }
        return ImageManager.shared.extractImageFilenames(from: attrString)
    }

    // MARK: - Equatable
    static func == (lhs: Note, rhs: Note) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.content == rhs.content &&
        lhs.rtfData == rhs.rtfData &&
        lhs.createdAt == rhs.createdAt &&
        lhs.updatedAt == rhs.updatedAt &&
        lhs.isPinned == rhs.isPinned
    }
}
