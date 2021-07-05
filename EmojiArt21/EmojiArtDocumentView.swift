import SwiftUI
import OSLog

// View (of the MVVM architectural pattern)
struct EmojiArtDocumentView: View {
    
    // observes changes to the view model
    @ObservedObject var document: EmojiArtDocument
    
    let defaultEmojiFontSize: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 50, content: {
                Spacer()
                emojiDeleteButton
            })
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
                        .scaleEffect(zoomScale)
                        // put the background image into the emoji coordinate center
                        .position(convertFromEmojiCoordinates((x: 0, y: 0), in: geometry))
                )
                .gesture(doubleTapToZoom(in: geometry.size)
                            .exclusively(before: deselectAllEmojisGesture())
                )
                if document.backgroundImageFetchStatus == .fetching {
                    ProgressView().scaleEffect(4)
                } else {
                    ForEach(document.emojis) { emoji in
                        Text(emoji.text)
                            .font(.system(size: fontSize(for: emoji)))
                            .scaleEffect(zoomScale)
                            .position(position(for: emoji, in: geometry))
                            .gesture(selectionGesture(for: emoji)
                                        .exclusively(before: dragSelectedEmojisGesture())
                                        .exclusively(before: longPressToDeleteGesture(for: emoji))
                            )
                            .background(Circle()
                                            .stroke(Color.blue, lineWidth: 2.0)
                                            .opacity(isSelected(emoji) ? 1 : 0)
                                            .offset(selectionOffset(for: emoji))
                                            .frame(width: 30 * zoomScale, height: 30 * zoomScale, alignment: .center)
                            )
                    }
                }
            }
            // clips this view to its bounding rectangular frame
            .clipped()
            // allowing dropping emojis (.plainText) on to the document, urls and images on to set the background
            .onDrop(of: [.plainText,.url,.image], isTargeted: nil) { providers, location in
                drop(providers: providers, at: location, in: geometry)
            }
            // recommendation: put no more than one .gesture on any view
            .gesture(panGesture().simultaneously(with: zoomGesture()))
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
                                      size: defaultEmojiFontSize / zoomScale)
                }
                
            }
        }
        return found
    }
    
    // used later on when pinching the size of an emoji
    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    // panning around the document (width and height directions for each var)
    @State private var steadyStatePanOffset: CGSize = CGSize.zero
    // state var while the gesture (panning) is happening
    @GestureState private var gesturePanOffset: CGSize = CGSize.zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset)  * zoomScale
    }
    
    private func panGesture () -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, _ in
                gesturePanOffset = latestDragGestureValue.translation / zoomScale
            }
            .onEnded { finalDragGestureValue in
                steadyStatePanOffset = steadyStatePanOffset + (finalDragGestureValue.translation / zoomScale)
            }
    }
    
    // dragging selected emojis on the document (to follow the user's finger)
    @State private var steadyStateEmojiDragOffset: CGSize = CGSize.zero
    // gesture state var for capturing the CGSize while the dragging gesture is happening
    @GestureState private var gestureStateEmojiDragOffset: CGSize = CGSize.zero
    
    private func dragSelectedEmojisGesture () -> some Gesture {
        DragGesture()
            // gestureStateEmojiDragOffset is an in/out param which updates the @GestureState var
            .updating($gestureStateEmojiDragOffset) { latestGestureStateEmojiDragOffset, gestureStateEmojiDragOffset, _ in
                gestureStateEmojiDragOffset = latestGestureStateEmojiDragOffset.translation / zoomScale
            }
            .onEnded { finalEmojiDragGestureValue in
                let distanceDragged = finalEmojiDragGestureValue.translation / zoomScale
                
                for emoji in selectedEmojis {
                    withAnimation {
                        document.moveEmoji(emoji, by: distanceDragged)
                    }
                    selectedEmojis.remove(emoji)
                }
            }
    }
        
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        // implicit return
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(document.backgroundImage, in: size)
                }
            }
    }
    
    // this has nothing to do with our model
    // it has only to do with how our view is displayed
    // this is the steady zoom scale when no zoomGesture is ongoing
    @State private var steadyStateZoomScale: CGFloat = 1
    // exists only while the gesture is ongoing
    // (otherwise its read only set to 1)
    @GestureState private var gestureZoomScale: CGFloat = 1
    
    // combination of the two zoomScales above
    // takes effect when the gestureZoomScale is happening
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private func zoomGesture() -> some Gesture {
        // an non-descrete gesture, pinch-to-zoom
        MagnificationGesture()
            // gesture modifier, 3 arguments closure which is constantly called
            // update the @GestureState gestureZoomScale
            // gestureZoomScale here is actually gestureZoomScaleInOut (in/out argument)
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureScale  // gestureZoomScale is the in/out version
            }
            // with onEnded, we get the var gestureScaleAtEnd which gets passed to us
            .onEnded { gestureScaleAtEnd in
                steadyStateZoomScale *= gestureScaleAtEnd
            }
    }
    
    // selection of emojis in the EmojiArt document
    // State: https://developer.apple.com/documentation/swiftui/state
    @State private var selectedEmojis = Set<EmojiArtModel.Emoji>()
    
    private func isSelected(_ emoji: EmojiArtModel.Emoji) -> Bool {
        selectedEmojis.contains(emoji) // implicitly return statement
    }
    
    private func selectionGesture(for emoji: EmojiArtModel.Emoji) -> some Gesture {
        TapGesture(count: 1) // single tap
            .onEnded {
                selectedEmojis.toogleMatching(element: emoji)
            }
    }
    
    private func longPressToDeleteGesture(for emoji: EmojiArtModel.Emoji) -> some Gesture {
        LongPressGesture()
            // action is triggered when the long press is released
            .onEnded {_ in
                document.deleteEmoji(emoji)
            }
    }
    
    // deselect all emojis by single-tapping on the document
    private func deselectAllEmojisGesture() -> some Gesture {
        TapGesture(count: 1)
            .onEnded {
                withAnimation(.linear(duration: 0.3)) {
                    selectedEmojis.removeAll()
                    Logger.emojiArtDocumentView.info("All emojis deselected!")
                }
            }
    }
    
    // when double tab to zoom gesture
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0 {
            // zoom factor in a horizontal direction
            let hZoom = size.width / image.size.width
            // zoom factor in a vertical direction
            let vZoom = size.height / image.size.height
            // jump to the middle
            steadyStatePanOffset = .zero // Swift will infer the CGSize
            // we need to pick the smaller of the two, to fit the whole image into the document
            steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    // position an emoji on the document
    private func position(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
        convertFromEmojiCoordinates((emoji.x, emoji.y), in: geometry)
    }
    
    // offset the emoji selection
    private func selectionOffset(for emoji: EmojiArtModel.Emoji) -> CGSize {
        
        let x = (CGFloat(emoji.x)) * zoomScale + panOffset.width
        let y = (CGFloat(emoji.y)) * zoomScale + panOffset.height
        
        return CGSize(width: x, height: y)
    }
    
    // convert from the view coordinates (upper left 0/0) to the emoji art coordinates
    // how far are we from the center
    private func convertToEmojiCoordinates(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
        // get the center of the view
        let center = geometry.frame(in: .local).center
        
        let location = CGPoint (
            x: (location.x - panOffset.width - center.x) / zoomScale,
            y: (location.y - panOffset.height - center.y) / zoomScale
        )
        
        return (Int(location.x), Int(location.y))
    }
    
    // convert from the emoji art coordinated to the views coordinates
    // move out from the center
    private func convertFromEmojiCoordinates(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        // get the center of the view
        let center = geometry.frame(in: .local).center
        
        return CGPoint(
            x: center.x + CGFloat(location.x) * zoomScale + panOffset.width,
            y: center.y + CGFloat(location.y) * zoomScale + panOffset.height
        )
    }
    
    var palette: some View {
        ScrollingEmojisView(emojis: testEmojis)
            .font(.system(size: defaultEmojiFontSize))
    }
    
    var emojiDeleteButton: some View {
        Button(action: {
            selectedEmojis.forEach { emoji in
                document.deleteEmoji(emoji)
            }
        }, label: {
            Image(systemName: "trash.fill")
            Text("Delete Emojis")
        })
        .padding()
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
