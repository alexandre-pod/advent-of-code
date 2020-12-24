import Foundation

enum Direction: CaseIterable {
    case east
    case southEast
    case southWest
    case west
    case northWest
    case northEast
}

typealias TileIdentifier = [Direction]

func main() {
    var tiles: [TileIdentifier] = []
    while let line = readLine() {
        tiles.append(parseDirections(from: line))
    }

    part1(tiles: tiles)
    part2(tiles: tiles)
}

// MARK: - Part 1

func part1(tiles: [TileIdentifier]) {
//    tiles.forEach { print($0) }
//    var positionCount: [Point: Int] = [:]
//    tiles.map { position(of: $0) }.forEach {
//        positionCount[$0, default: 0] += 1
//    }
//    let countBlackTiles = positionCount.values.filter { $0 % 2 != 0 }.count
    let countBlackTiles = HexagonalPattern(tiles: tiles).blackTileCount
    print("answer: \(countBlackTiles)")
}

/**
    0.0     0.1    0.2
      1.0     1.1    1.2
    2.-1   2.0     2.1    2.2
 */
extension Direction {
    var offset: (dx: Int, dy: Int) {
        switch self {
        case .east:
            return (dx: 1, dy: 0)
        case .northEast:
            return (dx: 1, dy: -1)
        case .northWest:
            return (dx: 0, dy: -1)
        case .southEast:
            return (dx: 0, dy: 1)
        case .southWest:
            return (dx: -1, dy: 1)
        case .west:
            return (dx: -1, dy: 0)
        }
    }
}

struct Point: Hashable {
    var x: Int
    var y: Int

    static let zero = Point(x: 0, y: 0)

    func offset(by offset: (dx: Int, dy: Int)) -> Point {
        return Point(x: x + offset.dx, y: y + offset.dy)
    }
}

func position(of tile: TileIdentifier, from initialPoint: Point = .zero) -> Point {
    return tile.map(\.offset).reduce(initialPoint) { $0.offset(by: $1) }
}

// MARK: - Part 2

func part2(tiles: [TileIdentifier]) {
    var countBlackTiles = HexagonalPattern(tiles: tiles)
    let round = 100
    for _ in 1...round {
        countBlackTiles.nextGeneration()
    }
    print(countBlackTiles.blackTileCount)
}

struct HexagonalPattern {

    private var blackTiles: Set<Point> = []

    init(tiles: [TileIdentifier]) {
        var positionCount: [Point: Int] = [:]
        tiles.map { position(of: $0) }.forEach {
            positionCount[$0, default: 0] += 1
        }

        positionCount.filter { $0.value % 2 != 0 }.forEach {
            blackTiles.insert($0.key)
        }
    }

    var blackTileCount: Int { blackTiles.count }

    mutating func nextGeneration() {
        var neighborsCount: [Point: Int] = [:]
        for blackTile in blackTiles {
            Direction.allCases
                .map { blackTile.offset(by: $0.offset) }
                .forEach { neighbor in
                    neighborsCount[neighbor, default: 0] += 1
                }
        }
        let tilesToCheck: Set<Point> = blackTiles.union(neighborsCount.keys)

        for tile in tilesToCheck {
            let isBlack = blackTiles.contains(tile)
            let neighbors = neighborsCount[tile, default: 0]
            if isBlack {
                if neighbors == 0 || neighbors > 2 {
                    blackTiles.remove(tile)
                }
            } else {
                if neighbors == 2 {
                    blackTiles.insert(tile)
                }
            }
        }
    }
}

main()
