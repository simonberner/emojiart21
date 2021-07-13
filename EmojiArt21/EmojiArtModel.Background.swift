import Foundation

// Model extension
extension EmojiArtModel {
    
    // Equatable so that we can check for equality of backgrounds
    enum Background: Equatable, Codable {
    
        case blank
        case url(URL) // associated data
        case imageData(Data) // associated data
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            // optional try?: if it throws, set url = nil
            if let url = try? container.decode(URL.self, forKey: .url) {
                // setting self (enum case url) to the copy of value type of the key .url
                self = .url(url)
            } else if let imageData = try? container.decode(Data.self, forKey: .imageData) {
                // setting self (which is the enum case imageData)
                self = .imageData(imageData)
            } else {
                self = .blank
            }
        }
        
        // Key.type for the encoder
        // String type of enum: all cases get a String alias "url", "imageData"
        // We can also reassign the raw String alias of any case e.g. case url = "theURL"
        enum CodingKeys: String, CodingKey {
            case url = "theURL"
            case imageData
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            switch self {
            case .url(let url): try container.encode(url, forKey: .url)
            case .imageData(let data): try container.encode(data, forKey: .imageData)
            case .blank: break
            }
            
        }
        
        
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
