import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    let defaultEmojiFontSize: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            palette
        }
    }
    
    var documentBody: some View {
        Color.yellow
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
