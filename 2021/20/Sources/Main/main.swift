import Foundation

struct Coordinates: Hashable {
    let x: Int
    let y: Int
}

// MARK: - Main

func main() {

    let algorithmMap = readLine()!.map { $0 == "#" }
    _ = readLine()

    var grid: [[Bool]] = []
    while let line = readLine()?.map({ $0 == "#" }) {
        grid.append(line)
    }

    print(part1(algorithmMap: algorithmMap, grid: grid))
    print(part2(algorithmMap: algorithmMap, grid: grid))
}

// MARK: - Part 1

func part1(algorithmMap: [Bool], grid: [[Bool]]) -> Int {

    var onCoordinates: Set<Coordinates> = []
    for y in grid.indices {
        for x in grid[y].indices {
            if grid[y][x] {
                onCoordinates.insert(Coordinates(x: x, y: y))
            }
        }
    }

    var updatedGrid = onCoordinates

//    displaySetGrid(updatedGrid)

    for step in 0..<2 {
        updatedGrid = nextGeneration(fromOn: updatedGrid, using: algorithmMap, outOfMapValue: outOfMapValue(forAlgorithm: algorithmMap, atStep: step))
//        print()
//        displaySetGrid(updatedGrid)
    }


    return updatedGrid.count
}

// MARK: - Part 2

func part2(algorithmMap: [Bool], grid: [[Bool]]) -> Int {

    var onCoordinates: Set<Coordinates> = []
    for y in grid.indices {
        for x in grid[y].indices {
            if grid[y][x] {
                onCoordinates.insert(Coordinates(x: x, y: y))
            }
        }
    }

    var updatedGrid = onCoordinates

    for step in 0..<50 {
//        print(step)
        updatedGrid = nextGeneration(fromOn: updatedGrid, using: algorithmMap, outOfMapValue: outOfMapValue(forAlgorithm: algorithmMap, atStep: step))
    }

//    displaySetGrid(updatedGrid)

    return updatedGrid.count
}

// MARK: - Puzzle

func outOfMapValue(forAlgorithm algorithm: [Bool], atStep step: Int) -> Bool {

    guard algorithm[0] else { return false }
    assert(algorithm[511] == false, "Unsupported algorithm")

    return step % 2 != 0
}

func nextGeneration(
    fromOn grid: Set<Coordinates>,
    using algorithm: [Bool],
    outOfMapValue: Bool
) -> Set<Coordinates> {
    let minX = grid.lazy.map(\.x).min() ?? 0
    let maxX = grid.lazy.map(\.x).max() ?? 0
    let minY = grid.lazy.map(\.y).min() ?? 0
    let maxY = grid.lazy.map(\.y).max() ?? 0

    let map = Map(onCoordinates: grid, minX: minX, maxX: maxX, minY: minY, maxY: maxY)

    var nextGrid: Set<Coordinates> = []

    for y in (minY - 1)...(maxY + 1) {
        for x in (minX - 1)...(maxX + 1) {
            let coordinates = Coordinates(x: x, y: y)
            let key = algorithmKeyValue(at: coordinates, in: map, outOfMapValue: outOfMapValue)
            if algorithm[key] {
                nextGrid.insert(coordinates)
            }
        }
    }

    return nextGrid
}

struct Map {
    let onCoordinates: Set<Coordinates>
    let minX: Int
    let maxX: Int
    let minY: Int
    let maxY: Int
}

func algorithmKeyValue(
    at coordinates: Coordinates,
    in map: Map,
    outOfMapValue: Bool
) -> Int {
    let binary = (-1...1)
        .map { coordinates.y + $0 }
        .flatMap { _y in
            (-1...1)
                .map { coordinates.x + $0 }
                .map { _x -> Bool in
                    if _x < map.minX || _x > map.maxX || _y < map.minY || _y > map.maxY {
                        return outOfMapValue
                    }
                    return map.onCoordinates.contains(Coordinates(x: _x, y: _y))
                }
        }
    return binaryToInt(binary)
}

func binaryToInt(_ binary: [Bool]) -> Int {
    return binary.reduce(0) { partialResult, upBit in
        return (partialResult << 1) + (upBit ? 1 : 0)
    }
}

// MARK: - Start

main()

// MARK: - Debug

func displaySetGrid(_ grid: Set<Coordinates>) {
    let minX = grid.lazy.map(\.x).min() ?? 0
    let maxX = grid.lazy.map(\.x).max() ?? 0
    let minY = grid.lazy.map(\.y).min() ?? 0
    let maxY = grid.lazy.map(\.y).max() ?? 0

    print("x:\(minX)...\(maxX), y:\(minY)...\(maxY)")
    for y in minY...maxY {
        print((minX...maxX).map { x in grid.contains(Coordinates(x: x, y: y)) ? "#" : "." }.joined())
    }
}
