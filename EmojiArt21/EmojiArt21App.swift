import SwiftUI

@main
struct EmojiArt21App: App {
    // View Models which are the source of through
    @StateObject var document = EmojiArtDocument()
    @StateObject var paletteStore = PaletteStore(named: "Default")
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: document)
                // inject the let paletteStore as an observable object in to the EmojiArtDocumentView
                // and in all its subviews (e.g. passes it on to the PaletteChooser)
                .environmentObject(paletteStore)
        }
    }
}
