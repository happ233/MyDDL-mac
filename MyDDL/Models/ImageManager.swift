import Foundation
import AppKit

class ImageManager {
    static let shared = ImageManager()

    private let fileManager = FileManager.default
    private let imagesDirectoryName = "images"

    private var imagesDirectory: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupport.appendingPathComponent("MyDDL")
        return appDir.appendingPathComponent(imagesDirectoryName)
    }

    private init() {
        createImagesDirectoryIfNeeded()
    }

    private func createImagesDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: imagesDirectory.path) {
            try? fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        }
    }

    // MARK: - Save Image

    /// Save image to file system and return the filename
    func saveImage(_ image: NSImage) -> String? {
        let filename = UUID().uuidString + ".png"
        let fileURL = imagesDirectory.appendingPathComponent(filename)

        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            return nil
        }

        do {
            try pngData.write(to: fileURL)
            return filename
        } catch {
            debugLog("[ImageManager] Failed to save image: \(error)")
            return nil
        }
    }

    // MARK: - Load Image

    /// Load image from file system by filename
    func loadImage(filename: String) -> NSImage? {
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        return NSImage(contentsOf: fileURL)
    }

    /// Get full path for image filename
    func imagePath(for filename: String) -> URL {
        return imagesDirectory.appendingPathComponent(filename)
    }

    // MARK: - Delete Image

    /// Delete image file
    func deleteImage(filename: String) {
        let fileURL = imagesDirectory.appendingPathComponent(filename)
        try? fileManager.removeItem(at: fileURL)
    }

    /// Delete multiple images
    func deleteImages(filenames: [String]) {
        for filename in filenames {
            deleteImage(filename: filename)
        }
    }

    // MARK: - Extract Image References

    /// Extract all image filenames from attributed string
    func extractImageFilenames(from attributedString: NSAttributedString) -> [String] {
        var filenames: [String] = []
        let range = NSRange(location: 0, length: attributedString.length)

        attributedString.enumerateAttribute(.attachment, in: range, options: []) { value, _, _ in
            if let attachment = value as? NSTextAttachment,
               let fileWrapper = attachment.fileWrapper,
               let filename = fileWrapper.preferredFilename,
               filename.hasSuffix(".png") {
                filenames.append(filename)
            }
        }

        return filenames
    }

    // MARK: - Clean Orphan Images

    /// Remove images that are no longer referenced by any note
    func cleanOrphanImages(referencedFilenames: Set<String>) {
        guard let contents = try? fileManager.contentsOfDirectory(at: imagesDirectory, includingPropertiesForKeys: nil) else {
            return
        }

        for fileURL in contents {
            let filename = fileURL.lastPathComponent
            if filename.hasSuffix(".png") && !referencedFilenames.contains(filename) {
                try? fileManager.removeItem(at: fileURL)
                debugLog("[ImageManager] Cleaned orphan image: \(filename)")
            }
        }
    }
}

// MARK: - Custom Text Attachment for File-based Images

class FileImageTextAttachment: NSTextAttachment {
    var imageFilename: String?

    override init(data contentData: Data?, ofType uti: String?) {
        super.init(data: contentData, ofType: uti)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.imageFilename = coder.decodeObject(forKey: "imageFilename") as? String
    }

    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(imageFilename, forKey: "imageFilename")
    }

    convenience init(image: NSImage, filename: String) {
        self.init(data: nil, ofType: nil)
        self.image = image
        self.imageFilename = filename

        // Create file wrapper with filename for serialization
        if let tiffData = image.tiffRepresentation {
            let wrapper = FileWrapper(regularFileWithContents: tiffData)
            wrapper.preferredFilename = filename
            self.fileWrapper = wrapper
        }
    }
}
