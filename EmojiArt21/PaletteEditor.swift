// View
import SwiftUI

struct PaletteEditor: View {
    // Bindings are passed to us (so don't mark them as private!)
    // this var is defined somewhere else
    @Binding var palette: Palette
    
    var body: some View {
        // we bind the text (of the TextField) to the 'name' field in the @State var palette:
        // through that Binding, the field 'name' of the @State var 'palette' is going to be changed
        // when we edit the TextField
        Form {
            nameSection
            addEmojiSection
            removeEmojiSection
        }
        .frame(minWidth: 300, minHeight: 300)
    }
    
    var nameSection: some View {
        Section(header: Text("name")) {
            TextField("Name", text: $palette.name)
        }
    }
    
    // this is a state var for the emojis we are adding
    // via the keyboard
    @State private var emojisToAdd = ""
    
    var addEmojiSection: some View {
        Section(header: Text("Add Emojis")) {
            TextField("", text: $emojisToAdd)
                // watch the var emojisToAdd and very time it changes
                // it executes the closure and hands in its latest value
                // (here emojis)
                .onChange(of: emojisToAdd, perform: { emojis in
                    addEmojis(emojis)
                })
        }
    }
    
    // remove emojis from the current palette selection
    var removeEmojiSection: some View {
        Section(header: Text("Remove Emoji")) {
            // an array containing all the emojis of the selected palette
            let emojis = palette.emojis.removingDuplicateCharacters.map { String ($0)}
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], alignment: .center, spacing: nil, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/, content: {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .onTapGesture {
                            withAnimation {
                                palette.emojis.removeAll(where: {String($0) == emoji})
                            }
                        }
                }
            })
            .font(.system(size: 40))
        }
    }
    
    private func addEmojis(_ emojis: String) {
        palette.emojis = (emojis + palette.emojis)
            .filter { $0.isEmoji }
            .removingDuplicateCharacters
    }
}






//struct PaletteEditor_Previews: PreviewProvider {
//    static var previews: some View {
//        // for testing only
//        PaletteEditor(palette: .constant(PaletteStore(named: "Preview").getPalette(at: 4)))
//            .previewLayout(.fixed(width: 300, height: 350))
//        PaletteEditor(palette: .constant(PaletteStore(named: "Preview").getPalette(at: 2)))
//            .previewLayout(.fixed(width: 300, height: 600))
//    }
//}
