import SwiftUI

// View (MVVM)
// Manages all the palettes at once
struct PaletteManager: View {
    // inject the store (like it is in the PaletteChooser view)
    @EnvironmentObject var store: PaletteStore
    
    var body: some View {
        // List (is among the powerful views like 'Form' in SwiftUI!)
        List {
            ForEach(store.palettes) { palette in
                VStack(alignment: .leading, spacing: nil, content: {
                    Text(palette.name)
                    Text(palette.emojis)
                })
            }
        }
    }
}









struct PaletteManager_Previews: PreviewProvider {
    static var previews: some View {
        PaletteManager()
            .previewDevice("iPhone 12 mini")
            .environmentObject(PaletteStore(named: "Preview"))
    }
}
