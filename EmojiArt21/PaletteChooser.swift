import SwiftUI
import OSLog

// View (MVVM)
struct PaletteChooser: View {
    var emojiFontSize: CGFloat = 40
    var emojiFont: Font {.system(size: emojiFontSize)}
    
    @EnvironmentObject var store: PaletteStore
    @State var chosenPaletteIndex = 0
    
    var body: some View {
        HStack {
            paletteControlButton
            body(for: store.getPalette(at: chosenPaletteIndex))
        }
        // clip this view so that it does not smash into other views
        .clipped()
    }
    
    // computed property of type view
    var paletteControlButton: some View {
        Button {
            // e.g. 1 % 9 = 1 remaining (1:9=0.1 | 1 remaining to 10)
            // e.g. 2 % 9 = 2 remaining (2:9=0.2 | 2 remaining to 20)
            // e.g. 3 % 9 = 3 remaining (2:9=0.3 | 3 remaining to 30)
            chosenPaletteIndex = (chosenPaletteIndex + 1) % store.palettes.count
            Logger.paletteChooser.info("Palettes count: \(store.palettes.count)")
            Logger.paletteChooser.info("Chosen palette Index/Name: \(chosenPaletteIndex)/\(store.getPalette(at: chosenPaletteIndex).name)")
        } label: {
            Image(systemName: "paintpalette")
        }
        .font(emojiFont)
        .contextMenu(ContextMenu(menuItems: {
            contextMenu
        }))
    }
    
    // ViewBuilder for creating a list of views
    @ViewBuilder
    var contextMenu: some View {
        AnimatedActionButton(title: "New", systemImage: "plus") {
            store.insertPalette(named: "New", emojis: "", at: chosenPaletteIndex)
        }
        AnimatedActionButton(title: "Delete", systemImage: "minus.circle") {
            store.removePalette(at: chosenPaletteIndex)
        }
        gotoMenu
    }
    
    var gotoMenu: some View {
        Menu {
            ForEach (store.palettes) { palette in
                AnimatedActionButton(title: palette.name) {
                    if let index = store.palettes.index(matching: palette) {
                        chosenPaletteIndex = index
                    }
                }
            }
            
        } label: {
            Label("Go to", systemImage: "text.insert")
        }
    }
    
    func body(for palette: Palette) -> some View {
        HStack {
            Text(palette.name)
            ScrollingEmojisView(emojis: palette.emojis)
                .font(emojiFont)
        }
        // when the identifiable of the view changes, the view is going to be replaced with the view of the new id
        // (When the proxy value specified by the id parameter changes, the identity of the view — for example, its state — is reset.)
        .id(palette.id)
        .transition(rollTransition)
    }
    
    var rollTransition: AnyTransition {
        AnyTransition.asymmetric(
            insertion: .offset(x: 0, y: emojiFontSize),
            removal: .offset(x: 0, y: -emojiFontSize)
        )
    }
}



struct ScrollingEmojisView: View {
    let emojis: String

    var body: some View {
        
        ScrollView(.horizontal) {
            HStack {
                // map is a very important function:
                // matches the emojis String to an array of strings
                // String($0 -> means first character!): changes every character (emoji) in to a String
                // These Strings need to also be identifiable so that we can put the emoji string itself
                // (\.self) as an id
                // and as we don't want to have any duplicate emojis in our emojis array, we remove
                // any duplicates from the emojis string before we do the map
                ForEach(emojis.removingDuplicateCharacters.map { String($0) }, id: \.self) { emoji in
                    Text(emoji)
                        // the NSItemProvider provides us with its information asynchronously
                        .onDrag({ NSItemProvider(object: emoji as NSString) }) // NS comes from the Objective-C world
                }
            }
        }
    }
}














//struct PaletteChooser_Previews: PreviewProvider {
//    static var previews: some View {
//        PaletteChooser()
//    }
//}
