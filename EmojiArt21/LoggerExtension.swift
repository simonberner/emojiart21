import Foundation
import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    // Logs the View: EmojiArtDocumentView
    static let emojiArtDocumentView = Logger(subsystem: subsystem, category: "EmojiArtDocumentView")
    // Logs the View Model: EmojiArtDocument
    static let emojiArtDocument = Logger(subsystem: subsystem, category: "EmojiArtDocument")
    // Logs the UtilityExtensions
    static let utilityExtensions = Logger(subsystem: subsystem, category: "UtilityExtensions")
    // Logs the View Model: PaletteStore
    static let paletteStore = Logger(subsystem: subsystem, category: "PaletteStore")
    // Logs the View: PaletteChooser
    static let paletteChooser = Logger(subsystem: subsystem, category: "PaletteChooser")

}
