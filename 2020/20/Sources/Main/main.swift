import Foundation

// MARK: - Main

func main() {
    var tiles: [Tile] = []
    while let tile = parseTile() {
        tiles.append(tile)
    }
//    part1_1(tiles: tiles)
    part1_2(tiles: tiles)
    part2(tiles: tiles)
}

func parseTile() -> Tile? {
    guard let idLine = readLine() else { return nil }
    let stringID = idLine.split(separator: " ").last!.dropLast()
    let id = Int(stringID)!

    var cells: [[Bool]] = []

    while let line = readLine(), !line.isEmpty {
        cells.append(line.map { $0 == "#" })
    }

    return Tile(id: id, cells: cells)
}

// MARK: - Utils

extension Collection where Element: Hashable {
    func deduped() -> [Element] {
        return deduped(on: \.self)
    }
}

extension Collection {
    func deduped<T: Hashable>(on keyPath: KeyPath<Element, T>) -> [Element] {
        var seenElements = Set<T>()
        return filter {
            guard !seenElements.contains($0[keyPath: keyPath]) else { return false }
            seenElements.insert($0[keyPath: keyPath])
            return true
        }
    }
}

// MARK: - Debug

extension Tile: CustomDebugStringConvertible {
    var debugDescription: String {
        let grid = cells.map {
            $0.map { $0 ? "#" : "." }.joined()
        }
        return ([String(id)] + grid).joined(separator: "\n")
    }
}

func debugPrint(_ bordersMap: BordersMap) {
    bordersMap.keys.forEach {
        print($0.map { $0 ? "#" : "." }.joined())
        print(bordersMap[$0]!.map { ($0.tile.id, $0.side) })
    }
}

main()
