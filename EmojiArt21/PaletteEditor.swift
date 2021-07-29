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
            TextField("Name", text: $palette.name)
        }
        .frame(minWidth: 300, minHeight: 300)
    }
}






struct PaletteEditor_Previews: PreviewProvider {
    static var previews: some View {
        Text("Fix Me!")
//        PaletteEditor()
            .previewLayout(.fixed(width: 150.0, height: 175.0))
    }
}
