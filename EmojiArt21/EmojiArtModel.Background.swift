import Foundation

// Model extension
extension EmojiArtModel {
    
    // Equatable so that we can check for equality of backgrounds
    enum Background: Equatable {
        case blank
        case url(URL) // associated data
        case imageData(Data) // associated data
        
        // convenience function: url is an optional
        // we don't have to do this, it's just syntactic sugar
        // someone who wants to get the url doesn't have to switch on us
        // to find out that when the url is nil that she is not in this
        // or in one of the other two cases
        var url: URL? {
            switch self {
            case .url(let url): return url
            default: return nil
            }
        }
        
        // convenience function: imageData is an optional
        var imageData: Data? {
            switch self {
            case .imageData(let data): return data
            default: return nil
            }
        }
    }
}
