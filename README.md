# EmojiArt 2021
![EmojiArt](assets/EmojiArt.png)

This is a work in progress learning project for my personal endeavours of becoming an iOS Developer one day.
EmojiArt is an iOS app (for iPhone and iPad >= iOS14) to practice different Gestures with SwiftUI.

## Technologies
- Xcode 12.5.1
- Swift 5.4
- SwiftUI 

## Persistance
All the data that is created by the user is stored locally using [UserDefaults](https://developer.apple.com/documentation/foundation/userdefaults) and is only deleted when the app is deleted. I am aware that [UserDefaults](https://www.hackingwithswift.com/example-code/system/how-to-save-user-settings-using-userdefaults)
should only be used for storing a small amount of data (eg user settings). Because too much data will slow down the lunch of the app.

## Logging in Swift
In this project I am also showing how to add proper Logging in Swift by using [Unified Logging](https://developer.apple.com/documentation/os/logging).

## Further Learning Resources
### SwiftUI

#### Opaque Type
- [Swift - Documentation](https://docs.swift.org/swift-book/LanguageGuide/OpaqueTypes.html)
- [The concepts behind SwiftUI: What is the keyword “some” doing?](https://www.process-one.net/blog/the-concepts-behind-swiftui-what-is-the-keyword-some-doing/#:~:text=The%20some%20keyword%20was%20introduced,to%20define%20an%20Opaque%20Type.&text=So%2C%20in%20SwiftUI%20case%2C%20%E2%80%9C,be%20known%20by%20the%20caller.)
- [Why does SwiftUI use “some View” for its view type?](https://www.hackingwithswift.com/books/ios-swiftui/why-does-swiftui-use-some-view-for-its-view-type)

#### Buttons
- [The many faces of button in SwiftUI 3](https://swiftwithmajid.com/2021/06/30/the-many-faces-of-button-in-swiftui/)

### Logging in Swift
- [OSLog and Unified logging as recommended by Apple](https://www.avanderlee.com/workflow/oslog-unified-logging/#improved-apis-in-ios-14-and-up)
- [Logging in Swift](https://steipete.com/posts/logging-in-swift/)
- [Customised Textual Representation](https://developer.apple.com/documentation/swift/customstringconvertible)
- [Explore logging in Swift](https://developer.apple.com/videos/play/wwdc2020/10168/)
- [Migrating to Unified Logging: Console and Instruments](https://www.raywenderlich.com/605079-migrating-to-unified-logging-console-and-instruments)

### async/await (Swift 5.5)
- [Using URLSession’s async/await-powered APIs](https://wwdcbysundell.com/2021/using-async-await-with-urlsession/)
