import SwiftUI

// this view is just syntactic sugar to be able to pass an optional UIImage to Image
// (normally it would only take a non-optional UIImage)
struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        if uiImage != nil {
            Image(uiImage: uiImage!) // force unwrapping (will abort the execution when uiImage is nil)
        }
    }
}
