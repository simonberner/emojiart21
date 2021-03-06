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
            insertPalette(named: "Vehicles", emojis: "ððððððððŧðððððððâïļðŦðŽðĐððļðēððķâĩïļðĪðĨðģâīðĒððððððððšð")
            insertPalette(named: "Sports", emojis: "ðâūïļðâ―ïļðūððĨðâģïļðĨðĨðâ·ðģ")
            insertPalette(named: "Music", emojis: "ðžðĪðđðŠðĨðšðŠðŠðŧ")
            insertPalette(named: "Animals", emojis: "ðĨðĢðððððððĶððððððĶðĶðĶðĶðĒððĶðĶðĶðððĶðĶðĶ§ðĶĢððĶðĶðŠðŦðĶðĶðĶŽððĶððĶððĐðĶŪððĶĪðĶĒðĶĐððĶðĶĻðĶĄðĶŦðĶĶðĶĨðŋðĶ")
            insertPalette(named: "Animal Faces", emojis: "ðĩððððķðąð­ðđð°ðĶðŧðžðŧââïļðĻðŊðĶðŪð·ðļðē")
            insertPalette(named: "Flora", emojis: "ðēðīðŋâïļððððūðð·ðđðĨðšðļðžðŧ")
            insertPalette(named: "Weather", emojis: "âïļðĪâïļðĨâïļðĶð§âðĐðĻâïļðĻâïļð§ðĶðâïļðŦðŠ")
            insertPalette(named: "COVID", emojis: "ððĶ ð·ðĪ§ðĪ")
            insertPalette(named: "Faces", emojis: "ððððððððĪĢðĨēâšïļððððððððĨ°ðððððððððĪŠðĪĻð§ðĪððĨļðĪĐðĨģððððððâđïļðĢððŦðĐðĨšðĒð­ðĪð ðĄðĪŊðģðĨķðĨððĪðĪðĪ­ðĪŦðĪĨðŽððŊð§ðĨąðīðĪŪð·ðĪ§ðĪðĪ ")
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

struct Palette: Identifiable, Codable, Hashable {
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
