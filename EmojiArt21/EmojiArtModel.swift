import Foundation

// Model
struct EmojiArtModel {
    var background = Background.blank
    var emojis = [Emoji]()
    
    // Hashable to put them into a set
    struct Emoji: Identifiable, Hashable {
        let text: String
        var x: Int
        var y: Int
        var size: Int
        let id: Int
        
        // fileprivate: anyone in this file can use this init but no one else
        // so no one except us can create an emoji
        // (with this we lose the free init from the struct)
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
    
    // we explicitly create a empty init so that nobody might have the idea
    // they could use the EmojiArtModels free init() to set the background
    // and emojis (which in this case the could't anyway)
    init() {}
    
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(_ text: String, at location: (x: Int, y: Int), size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: location.x, y: location.y, size: size, id: uniqueEmojiId))
    }
    
}
