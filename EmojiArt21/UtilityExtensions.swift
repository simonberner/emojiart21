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
