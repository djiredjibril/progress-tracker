import Foundation
import UIKit

// Range la photo de profil dans un dossier local de l'app (Application Support/Avatars).
// ⚛️ React : ≈ `expo-file-system` : on écrit un fichier dans le bac à sable de l'app et on garde seulement son NOM dans
// les réglages. Le dossier est injectable : les tests utilisent un dossier temporaire.
struct AvatarStore {
    var directory: URL

    init(directory: URL = Self.defaultDirectory) {
        self.directory = directory
    }

    static var defaultDirectory: URL {
        URL.applicationSupportDirectory.appending(path: "Avatars", directoryHint: .isDirectory)
    }

    func url(for fileName: String) -> URL {
        directory.appending(path: fileName)
    }

    // Réduit l'image (600 px max) et l'enregistre en JPEG ; renvoie le nom du fichier créé.
    func save(_ data: Data) throws -> String {
        guard let image = UIImage(data: data) else { throw CocoaError(.fileReadCorruptFile) }
        let resized = Self.resized(image, maxSide: 600)
        guard let jpeg = resized.jpegData(compressionQuality: 0.85) else { throw CocoaError(.fileWriteUnknown) }

        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let name = "avatar-\(UUID().uuidString).jpg"
        try jpeg.write(to: url(for: name), options: .atomic)
        return name
    }

    func remove(_ fileName: String?) {
        guard let fileName else { return }
        try? FileManager.default.removeItem(at: url(for: fileName))
    }

    private static func resized(_ image: UIImage, maxSide: CGFloat) -> UIImage {
        let longest = max(image.size.width, image.size.height)
        guard longest > maxSide else { return image }
        let scale = maxSide / longest
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
