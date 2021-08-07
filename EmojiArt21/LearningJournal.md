## Learning Journal
### August 2021 (Lecture12 - 1:46:00)
In the last 2 month, I learned the following:
- How to inject a view model using the .environmentObject() mechanism into the top level view EmojiArtDocumentView and down to the
views PaletteChooser and PaletteManager.
- Marking the states in the top level struct EmojiArtApp with @StateObject so that we can find the sources of truth by searching for '@State'
#### 1:46:36
- PaletteChooser:
    - Added a new rollTransition which is of type AnyTransition (WIP: does not yet work as expected!)
    - Made the view identifiable by using the .id() and putting the palette.id on it in order to make the view come and go (make it transitioning).
    - Doing contextMenu's: gotoMenu inside the contextMenu (@ViewBuilder)
#### 1:47:10
- PaletteEditor:
    - Bindings: how we can bind information from the view back to the model and bind to a text field
- PaletteChooser:
    - Bindings: used to decide when views are appearing like .popover() and sheet(). This takes a bit of time to understand how Bindings are used.
    This is super important because without them, we could not pass around data and copying it as we do now.
- How to use Form, List, NavigationView and NavigationLink
#### 1:48:33
- PaletteManager
    - How to add a .toolbar button up in the navigation view and about the special EditButton() that changes the $editMode in its environment.
    - How to add onDelete() and onMove() to a ForEach inside a List
#### 1:49:30
- EmojiArtDocumentView
    - How to put an alert up to notify the user in case something fails
