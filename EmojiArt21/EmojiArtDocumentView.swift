import SwiftUI

// View (of the MVVM architectural pattern)
struct EmojiArtDocumentView: View {
    
    // observes changes to the view model
    @ObservedObject var document: EmojiArtDocument
    
    let defaultEmojiFontSize: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            palette
        }
    }
    
    var documentBody: some View {
        // the GeometryReader reads the geometry from its content
        GeometryReader { geometry in
            ZStack {
                Color.white.overlay(
                    OptionalImage(uiImage: document.backgroundImage)
                        // put the background image into the emoji coordinate center
                        .position(convertFromEmojiCoordinates((x: 0, y: 0), in: geometry))
                )
                ForEach(document.emojis) { emoji in
                    Text(emoji.text)
                        .font(.system(size: fontSize(for: emoji)))
                        .position(position(for: emoji, in: geometry))
                }
            }
            .onDrop(of: [.plainText,.url,.image], isTargeted: nil) { providers, location in
                drop(providers: providers, at: location, in: geometry)
            }
        }
        
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        
        // if found, drop the background image from the url
        var found = providers.loadObjects(ofType: URL.self) { url in
            document.setBackground(.url(url.imageURL))
            
        }
        // if not found: check wether a UIImage is dropped
        if !found {
            found = providers.loadObjects(ofType: UIImage.self) { image in
                if let data = image.jpegData(compressionQuality: 1.0) {
                    document.setBackground(.imageData(data))
                }
                
            }
        }
        // if not found: check wether an emoji is dropped
        if !found {
            // this func is going to check wether the providers have a String
            // (because they might have not and instead have e.g. an image)
            // if they do have a string, it is going to call the closure with the string (emoji it
            // found in there (note: it is going to do that asynchronously)
            found =  providers.loadObjects(ofType: String.self) { string in
                if let emoji = string.first, emoji.isEmoji {
                    document.addEmoji(String(emoji),
                                      at: convertToEmojiCoordinates(location, in: geometry),
                                      size: defaultEmojiFontSize)
                }
                
            }
        }
        return found
    }
    
    // used later on when pinching the size of an emoji
    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    // position an emoji on the document
    private func position(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinates((emoji.x, emoji.y), in: geometry)
    }
    
    // convert from the view coordinates (upper left 0/0) to the emoji art coordinates
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
        // get the center of the view
        let center = geometry.frame(in: .local).center
        
        let location = CGPoint (
            x: location.x - center.x,
            y: location.y - center.y
        )
        
        return (Int(location.x), Int(location.y))
    }
    
    // convert from the emoji art coordinated to the views coordinates
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        // get the center of the view
        let center = geometry.frame(in: .local).center
        
        return CGPoint(
            x: center.x + CGFloat(location.x),
            y: center.y + CGFloat(location.y))
        
    }
    
    var palette: some View {
        ScrollingEmojisView(emojis: testEmojis)
            .font(.system(size: defaultEmojiFontSize))
    }
    
    let testEmojis = "😍😎❤🎉🎾🍓🥂😀"
}

struct ScrollingEmojisView: View {
    let emojis: String

    var body: some View {
        
        ScrollView(.horizontal) {
            HStack {
                // map is a very important function:
                // matches the emojis String to an array of strings
                // String($0 -> means first character!): changes every character (emoji) in to a String
                // These Strings need to also be identifiable (we don't want to put any duplicate emojis
                // in our emojis array) so we put the emoji string itself (\.self) as an id
                ForEach(emojis.map { String($0) }, id: \.self) { emoji in
                    Text(emoji)
                        // the NSItemProvider provides us with its information asynchronously
                        .onDrag({ NSItemProvider(object: emoji as NSString) }) // NS comes from the Objective-C world
                }
            }
        }
    }
}





















//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        EmojiArtDocumentView(document: EmojiArtDocument())
//    }
//}
