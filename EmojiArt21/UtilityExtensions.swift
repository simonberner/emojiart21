import SwiftUI

// extension for the protocol Collection
extension Collection where Element: Identifiable {
    // return value is Self.Index? Optional because some collections are not indexed by Ints
    func index(matching element: Element) -> Self.Index? {
        firstIndex(where: {$0.id == element.id})
    }
}

// holds the center coordinates of a rectangle
extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}

// convenience functions for [NSItemProvider] (i.e. array of NSItemProvider)
// makes the code for loading objects from the providers a bit simpler
// NSItemProvider is a holdover from the Objective-C (i.e. pre-Swift) world
// you can tell by its very name (starts with NS)
// so unfortunately, dealing with this API is a little bit crufty
extension Array where Element == NSItemProvider {
    func loadObjects<T>(ofType theType: T.Type, firstOnly: Bool = false, using load: @escaping (T) -> Void) -> Bool where T: NSItemProviderReading {
        if let provider = first(where: { $0.canLoadObject(ofClass: theType) }) {
            provider.loadObject(ofClass: theType) { object, error in
                if let value = object as? T {
                    DispatchQueue.main.async {
                        load(value)
                    }
                }
            }
            return true
        }
        return false
    }
    func loadObjects<T>(ofType theType: T.Type, firstOnly: Bool = false, using load: @escaping (T) -> Void) -> Bool where T: _ObjectiveCBridgeable, T._ObjectiveCType: NSItemProviderReading {
        if let provider = first(where: { $0.canLoadObject(ofClass: theType) }) {
            let _ = provider.loadObject(ofClass: theType) { object, error in
                if let value = object {
                    DispatchQueue.main.async {
                        load(value)
                    }
                }
            }
            return true
        }
        return false
    }
    func loadFirstObject<T>(ofType theType: T.Type, using load: @escaping (T) -> Void) -> Bool where T: NSItemProviderReading {
        loadObjects(ofType: theType, firstOnly: true, using: load)
    }
    func loadFirstObject<T>(ofType theType: T.Type, using load: @escaping (T) -> Void) -> Bool where T: _ObjectiveCBridgeable, T._ObjectiveCType: NSItemProviderReading {
        loadObjects(ofType: theType, firstOnly: true, using: load)
    }
}

extension Character {
    var isEmoji: Bool {
        // Swift does not have a way to ask if a Character isEmoji
        // but it does let us check to see if our component scalars isEmoji
        // unfortunately unicode allows certain scalars (like 1)
        // to be modified by another scalar to become emoji (e.g. 1️⃣)
        // so the scalar "1" will report isEmoji = true
        // so we can't just check to see if the first scalar isEmoji
        // the quick and dirty here is to see if the scalar is at least the first true emoji we know of
        // (the start of the "miscellaneous items" section)
        // or check to see if this is a multiple scalar unicode sequence
        // (e.g. a 1 with a unicode modifier to force it to be presented as emoji 1️⃣)
        if let firstScalar = unicodeScalars.first, firstScalar.properties.isEmoji {
            return (firstScalar.value >= 0x238d || unicodeScalars.count > 1)
        } else {
            return false
        }
    }
}

// sometimes image urls are wrapped in to another url (which defines where the image is coming from)
// extracting the actual url to an imageURL from a url that might contain other info
// (essentially looking for the imgurl key)
// imgurl is a "well known" key that can be embedded in a url that says what the actual image url is
extension URL {
    var imageURL: URL {
        for query in query?.components(separatedBy: "&") ?? [] {
            let queryComponents = query.components(separatedBy: "=")
            if queryComponents.count == 2 {
                // if the component has an imgurl it will return just that imageURL
                if queryComponents[0] == "imgurl", let url = URL(string: queryComponents[1].removingPercentEncoding ?? "") {
                    return url
                }
            }
        }
        // self: if it is not an imgurl, it is returning self (the normal url)
//        return baseURL ?? self
        return self
    }
}

// extension to be able to do the four basic mathematical
// operations of two CGSize's in an easy way
extension CGSize {
    var center: CGPoint {
        CGPoint(x: width/2, y: height/2)
    }
    static func +(leftHandSide: Self, rightHandSide: Self) -> CGSize {
        CGSize(width: leftHandSide.width + rightHandSide.width, height: leftHandSide.height + rightHandSide.height)
    }
    static func -(leftHandSide: Self, rightHandSide: Self) -> CGSize {
        CGSize(width: leftHandSide.width - rightHandSide.width, height: leftHandSide.height - rightHandSide.height)
    }
    static func *(leftHandSide: Self, rightHandSide: CGFloat) -> CGSize {
        CGSize(width: leftHandSide.width * rightHandSide, height: leftHandSide.height * rightHandSide)
    }
    static func /(leftHandSide: Self, rightHandSide: CGFloat) -> CGSize {
        CGSize(width: leftHandSide.width / rightHandSide, height: leftHandSide.height / rightHandSide)
    }
}
