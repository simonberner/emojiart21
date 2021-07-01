import Foundation
import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    
    // Logs the EmojiArtDocumentView
    static let emojiArtDocumentView = Logger(subsystem: subsystem, category: "EmojiArtDocumentView")
    // Logs the EmojiArtDocument
    static let emojiArtDocument = Logger(subsystem: subsystem, category: "EmojiArtDocument")
    // Logs the UtilityExtensions
    static let utilityExtensions = Logger(subsystem: subsystem, category: "UtilityExtensions")

}
