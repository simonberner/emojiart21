// View Model
import SwiftUI

class EmojiArtDocument: ObservableObject {
    
    // private(set): the property emojiArt is settable only from within code that is part of the class
    // (https://docs.swift.org/swift-book/LanguageGuide/AccessControl.html#ID17)
    @Published private(set) var emojiArt: EmojiArtModel
    
    init() {
        emojiArt = EmojiArtModel()
    }
    
    // convenient functions, so that a caller can get the emojis array of the model
    var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }
    var background: EmojiArtModel.Background { emojiArt.background }
    
    // MARK: - Intent(s)
    // (functions which modify the model)
    
    func setBackground(_ background: EmojiArtModel.Background) {
        emojiArt.background = background
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat) {
        emojiArt.addEmoji(emoji, at: location, size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            // TODO: check if this calculation is correct
            emojiArt.emojis[index].size = emojiArt.emojis[index].size * Int(scale.rounded(.toNearestOrAwayFromZero))
        }
    }

}
