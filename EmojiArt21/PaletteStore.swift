import SwiftUI
import OSLog

// View Model for the Emoji Palette
// (all view models are classes)
class PaletteStore: ObservableObject {
    let name: String
    
    @Published var palettes = [Palette]() {
        didSet {
            storeInUserDefaults()
        }
    }
    
    // a computed property
    private var userDefaultsKey: String {
        "PaletteStore:" + name
    }
    
    private func storeInUserDefaults() {
        UserDefaults.standard.set(try? JSONEncoder().encode(palettes), forKey: userDefaultsKey)
    }
    
    private func restoreFromUserDefaults() {
        // if some data is returned for the key AND
        // we have an Array<Palette> THEN
        // assign a copy of decodedPalettes to palettes
        if let jsonData = UserDefaults.standard.data(forKey: userDefaultsKey),
           // [Palette].self is same as Array<Palette>.self
           let decodedPalettes = try? JSONDecoder().decode([Palette].self, from: jsonData) {
            palettes = decodedPalettes
        }
        
    }
    
    init(named name: String) {
        self.name = name
        restoreFromUserDefaults()
        if palettes.isEmpty {
            Logger.paletteStore.info("using built-in palettes")
            insertPalette(named: "Vehicles", emojis: "🚙🚗🚘🚕🚖🏎🚚🛻🚛🚐🚓🚔🚑🚒🚀✈️🛫🛬🛩🚁🛸🚲🏍🛶⛵️🚤🛥🛳⛴🚢🚂🚝🚅🚆🚊🚉🚇🛺🚜")
            insertPalette(named: "Sports", emojis: "🏈⚾️🏀⚽️🎾🏐🥏🏓⛳️🥅🥌🏂⛷🎳")
            insertPalette(named: "Music", emojis: "🎼🎤🎹🪘🥁🎺🪗🪕🎻")
            insertPalette(named: "Animals", emojis: "🐥🐣🐂🐄🐎🐖🐏🐑🦙🐐🐓🐁🐀🐒🦆🦅🦉🦇🐢🐍🦎🦖🦕🐅🐆🦓🦍🦧🦣🐘🦛🦏🐪🐫🦒🦘🦬🐃🦙🐐🦌🐕🐩🦮🐈🦤🦢🦩🕊🦝🦨🦡🦫🦦🦥🐿🦔")
            insertPalette(named: "Animal Faces", emojis: "🐵🙈🙊🙉🐶🐱🐭🐹🐰🦊🐻🐼🐻‍❄️🐨🐯🦁🐮🐷🐸🐲")
            insertPalette(named: "Flora", emojis: "🌲🌴🌿☘️🍀🍁🍄🌾💐🌷🌹🥀🌺🌸🌼🌻")
            insertPalette(named: "Weather", emojis: "☀️🌤⛅️🌥☁️🌦🌧⛈🌩🌨❄️💨☔️💧💦🌊☂️🌫🌪")
            insertPalette(named: "COVID", emojis: "💉🦠😷🤧🤒")
            insertPalette(named: "Faces", emojis: "😀😃😄😁😆😅😂🤣🥲☺️😊😇🙂🙃😉😌😍🥰😘😗😙😚😋😛😝😜🤪🤨🧐🤓😎🥸🤩🥳😏😞😔😟😕🙁☹️😣😖😫😩🥺😢😭😤😠😡🤯😳🥶😥😓🤗🤔🤭🤫🤥😬🙄😯😧🥱😴🤮😷🤧🤒🤠")
        } else {
            Logger.paletteStore.info("successfully loaded from UserDefaults: \(self.palettes)")
        }
    }
    
    // MARK: - Intent (functions)

    func getPalette(at index: Int) -> Palette {
        // omit to run into an index out bounds error
        let safeIndex = min(max(index, 0), palettes.count - 1)
        return palettes[safeIndex]
    }
    
    // insert a palette named <name> of <emojis>
    func insertPalette(named name: String, emojis: String, at index: Int = 0) {
        let palette = Palette(name: name, emojis: emojis, id: UUID())
        let safeIndex = palettes.count
//        let safeIndex = max(min(index, 0), palettes.count)
        palettes.insert(palette, at: safeIndex)
    }
    
    func removePalette(at index: Int) {
        // IF palettes count is greater than 1 (never remove the last palette)
        // AND it contains the index to be delete
        // THEN remove the palette at index
        if palettes.count > 1, palettes.indices.contains(index) {
            palettes.remove(at: index)
        }
    }

}

struct Palette: Identifiable, Codable {
    var id: UUID
    var name: String
    var emojis: String
    
    // we only want to be able to initialise a new Palette with the insertPalette func in the above class
    // fileprivate here: only accessible within this file "file in private" or "private access within the file itself"
    // (see https://www.avanderlee.com/swift/fileprivate-private-differences-explained/)
    fileprivate init(name: String, emojis: String, id: UUID) {
        self.name = name
        self.emojis = emojis
        self.id = id
    }
}
