import SwiftUI
import OSLog

// View Model
class EmojiArtDocument: ObservableObject {
    
    // private(set): the property emojiArt is settable only from within code that is part of the class
    // (https://docs.swift.org/swift-book/LanguageGuide/AccessControl.html#ID17)
    @Published private(set) var emojiArt: EmojiArtModel {
        // didSet (property observer) gets called whenever something in the model changes
        // (e.g. when we drag and drop an image or url into the model)
        didSet {
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageDataIfNecessary() // we might have to fetch the backgroundImage
            }
        }
    }
    
    // Every time the background changes in our model, we have to set this backgroundImage
    // Published: lets the EmojiArtDocumentView know when its going to redraw and show it
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    enum BackgroundImageFetchStatus {
        case idle
        case fetching
    }
    
    private func fetchBackgroundImageDataIfNecessary() {
        backgroundImage = nil
        switch emojiArt.background {
        case .url(let url): // EmojiArtModel.Background.url
            backgroundImageFetchStatus = .fetching
            // ignore the error which is thrown back at us: try this, if it fails return nil
            // (because this can easily fail)
            DispatchQueue.global(qos: .userInitiated).async { // takes the closure an puts it on a queue in some other thread than the main thread
                let imageData = try? Data(contentsOf: url) // will actually GET that image!
                // weak: it doesn't force to keep the self in the heap
                // if no-one else keeps it in the heap, if it goes away it will turn to nil
                // turns self in an optional (self?)
                DispatchQueue.main.async { [weak self] in
                    // check if current background equals the background
                    // with the url that is the same as the url we just looked up
                    if self?.emojiArt.background == EmojiArtModel.Background.url(url) {
                        self?.backgroundImageFetchStatus = .idle
                        if imageData != nil {
                            // self?: if self is nil, don't do the rest
                            self?.backgroundImage = UIImage(data: imageData!)
                        }
                    }
                }
            }
        case .imageData(let data): // // EmojiArtModel.Background.imageData
            backgroundImage = UIImage(data: data) //UIImage is an image like jpeg, png
        case .blank: // if blank we do nothing
            break
        }
    }
    
    init() {
        emojiArt = EmojiArtModel()
//        emojiArt.addEmoji("😷", at: (-200, -100), size: 80)
//        emojiArt.addEmoji("😇", at: (0, 0), size: 80)

    }
    
    // convenient functions, so that a caller can get the emojis array of the model
    var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }
    var background: EmojiArtModel.Background { emojiArt.background }
    
    // MARK: - Intent(s)
    // (functions which modify the model)
    
    func setBackground(_ background: EmojiArtModel.Background) {
        emojiArt.background = background
        print("background set to \(background)")
//        Logger.emojiArtDocument.info("background set to \(background)")
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
