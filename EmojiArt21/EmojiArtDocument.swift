import SwiftUI
import OSLog

// View Model
class EmojiArtDocument: ObservableObject {
    
    // private(set): the property emojiArt is settable only from within code that is part of the class
    // (https://docs.swift.org/swift-book/LanguageGuide/AccessControl.html#ID17)
    @Published private(set) var emojiArt: EmojiArtModel {
        // didSet (property observer) gets called whenever something in the model changes
        // (e.g. when we drag and drop an image, emoji or url into the model)
        didSet {
            scheduleAutosave()
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageDataIfNecessary() // we might have to fetch the backgroundImage
            }
        }
    }
    
    private var autosaveTimer: Timer?
    
    private func scheduleAutosave () {
        // cancelling the previous timer, if the func is triggered more than once in 5 sec
        autosaveTimer?.invalidate()
        // 3rd argument takes a closure (which takes a timer as argument from what
        // scheduledTimer returns.
        // coalesce here: we want to coalesce (connect) the autosave with a timer
        autosaveTimer = Timer.scheduledTimer(withTimeInterval: Autosave.coalescingInterval, repeats: false) { timer in
            // don't use weak self here because we want to keep self in memory
            Logger.emojiArtDocument.info("scheduleAutosave timer.fireDate: \(timer.fireDate)")
            self.autosave()
        }
    }
    
    private struct Autosave {
        static let coalescingInterval = 5.0
        static let filename = "Autosave.emojiart"
        static var url: URL? {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            return documentDirectory?.appendingPathComponent(filename)
        }
    }
    
    private func autosave () {
        if let url = Autosave.url {
            save(to: url)
        }
    }
    
    private func save(to url: URL) {
        // a general way of getting the name of this function as a String for print/Logger
        let  thisfunction = "\(String(describing: self)).\(#function)"
        do {
            // Data is a byte buffer (bag of bits)
            let data: Data = try emojiArt.json()
            Logger.emojiArtDocumentView.info("\(thisfunction) json = \(String(data: data, encoding: .utf8) ?? "nil")")
            try data.write(to: url)
            Logger.emojiArtDocumentView.info("\(thisfunction) success!")
        } catch let encodingError where encodingError is EncodingError {
            print("\(thisfunction) couldn't encode EmojiArt as JSON because \(encodingError.localizedDescription)")
        } catch {
            print("\(thisfunction) error = \(error)")
            //            Logger.emojiArtDocumentView.info("EmojiArtDocument.save(to) error = \(error)")
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
        // if we have a valid Autosave url AND based on this url an EmojiArtModel (which is not nil)
        // in the long run, we will not use this "aggressive" austosave mechanism, because we are
        // going to use the Swift Document infrastructure
        if let url = Autosave.url, let autosavedEmojiArt = try? EmojiArtModel(url: url) {
            emojiArt = autosavedEmojiArt
            fetchBackgroundImageDataIfNecessary()
        } else {
            emojiArt = EmojiArtModel()
    //        emojiArt.addEmoji("😷", at: (-200, -100), size: 80)
    //        emojiArt.addEmoji("😇", at: (0, 0), size: 80)
        }
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
    
    func deleteEmoji(_ emoji: EmojiArtModel.Emoji) {
        if let index = emojiArt.emojis.firstIndex(of: emoji) {
            emojiArt.emojis.remove(at: index)
            Logger.emojiArtDocument.info("\(emoji.text) deleted")
        }
    }

}
