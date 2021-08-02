import SwiftUI

// View (MVVM)
// Manages all the palettes at once
struct PaletteManager: View {
    // inject the store (like it is in the PaletteChooser view)
    @EnvironmentObject var store: PaletteStore
    
    var body: some View {
        NavigationView {
            // List (is among the powerful views like 'Form' in SwiftUI!)
            List {
                ForEach(store.palettes) { palette in
                    // NavigationLink view only work in conjunction with a NavigationView!
                    NavigationLink(destination: PaletteEditor(palette: $store.palettes[palette])) {
                        VStack(alignment: .leading, spacing: nil, content: {
                            Text(palette.name)
                            Text(palette.emojis)
                        })
                    }
                }
            }
            .navigationTitle("Manage Palettes")
            .navigationBarTitleDisplayMode(.inline)
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
