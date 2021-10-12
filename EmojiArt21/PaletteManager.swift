import SwiftUI

// View (MVVM)
// Manages all the palettes at once
struct PaletteManager: View {
    // inject the store (like it is in the PaletteChooser view)
    @EnvironmentObject var store: PaletteStore
    // Environment variable to change colorScheme, can be set for a certain view
    // key path as argument to the thing which we are interested in
    // here the var which has the value from the \.colorScheme
    // (Documentation: EnvironmentValues)
    @Environment(\.colorScheme) var colorScheme
    // Dismiss/Close a view (if it is presented in a popover)
    @Environment(\.presentationMode) var presentationMode

    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationView {
            // List (is among the powerful views like 'Form' in SwiftUI!)
            List {
                ForEach(store.palettes) { palette in
                    // NavigationLink view only work in conjunction with a NavigationView!
                    NavigationLink(destination: PaletteEditor(palette: $store.palettes[palette])) {
                        VStack(alignment: .leading, spacing: nil, content: {
                            // could be added to Text: .font(editMode == .active ? .largeTitle : .caption)
                            Text(palette.name)
                            Text(palette.emojis)
                        })
                        // if the editMode is active add the tap gesture, otherwise nil
                        .gesture(editMode == .active ? tap : nil)
                    }
                }
                // is the editMode .active, every palette in the List can be deleted...
                .onDelete { indexSet in
                    store.palettes.remove(atOffsets: indexSet)
                }
                // ...and moved up or down
                .onMove { indexSet, newOffset in
                    store.palettes.move(fromOffsets: indexSet, toOffset: newOffset)
                }
            }
            .navigationTitle("Manage Palettes")
//            .environment(\.colorScheme, .dark)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    // this edit button is looking at the binding $editMode and toggles it
                    // setting the view into edit mode
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    // if the presentationMode is presented AND
                    // the device is an ipad (currently commented out)
                    // show the 'Close' button
                    if presentationMode.wrappedValue.isPresented {
                       // this is from UIKit
//                       UIDevice.current.userInterfaceIdiom != .pad {
                        Button("Close") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
            // List is using the binding to check whether it is in edit mode or not
            .environment(\.editMode, $editMode)
        }
    }

    // for later use...
    var tap: some Gesture {
        TapGesture().onEnded {

        }
    }
}

struct PaletteManager_Previews: PreviewProvider {
    static var previews: some View {
        PaletteManager()
            .previewDevice("iPhone 12 mini")
            .environmentObject(PaletteStore(named: "Preview"))
            .preferredColorScheme(.light)
    }
}
