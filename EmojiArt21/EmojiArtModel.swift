import Foundation

// Model
struct EmojiArtModel: Codable {
    // all the vars also have to conform to the Codable protocol!
    var background = Background.blank
    var emojis = [Emoji]() // is an array of identifiable

    // Hashable to put them into a set
    struct Emoji: Identifiable, Hashable, Codable {
        let text: String
        var x: Int // offset from the center
        var y: Int // offset from the center
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

    // encode the model into a JSON
    func json() throws -> Data {
        return try JSONEncoder().encode(self)
    }

    // we explicitly create a empty init so that nobody might have the idea
    // they could use the EmojiArtModels free init() to set the background
    // and emojis (which in this case the could't anyway)
    init() {}

    // initialise the model by decoding passed in json data
    init(json: Data) throws {
        self = try JSONDecoder().decode(EmojiArtModel.self, from: json)
    }

    // initialise the model by getting some data from a file url
    init(url: URL) throws {
        // get/load the data from a file url
        // this might block the main queue, but it is fast enough
        // nevertheless, we leave the burden up to the caller to handle the async
        let data = try Data(contentsOf: url)
        self = try EmojiArtModel(json: data)
    }

    private var uniqueEmojiId = 0

    mutating func addEmoji(_ text: String, at location: (x: Int, y: Int), size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: location.x, y: location.y, size: size, id: uniqueEmojiId))
    }

}
