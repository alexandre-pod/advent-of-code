import Foundation

// MARK: - Main

typealias Grid = [[Int]]

struct GridCoordinates: Hashable {
    let x: Int
    let y: Int
}

extension Grid {
    subscript(_ coordinates: GridCoordinates) -> Int {
        get { self[coordinates.y][coordinates.x] }
        set { self[coordinates.y][coordinates.x] = newValue }
    }

    var allCoordinates: LazySequence<FlattenSequence<LazyMapSequence<Range<Int>, [GridCoordinates]>>> {
        return self.indices.lazy.flatMap { y in
            return self[y].indices.map { x in
                return GridCoordinates(x: x, y: y)
            }
        }
    }
}

func main() {

    var grid: Grid = []

    while let line = readLine() {
        grid.append(line.map { Int(String($0))! })
    }

    print(part1(grid: grid))
    print(part2(grid: grid))
}

// MARK: - Part 1

struct PowerMap {
    var grid: Grid
    var flashCount: Int = 0
}

func part1(grid: Grid) -> Int {

    var powerMap = PowerMap(grid: grid, flashCount: 0)

//    for stepCount in 1...100 {
//        step(powerMap: &powerMap)
//        print("After step \(stepCount):")
//        powerMap.grid.debugDisplay()
//        print("flashCount", powerMap.flashCount)
//    }

    for _ in 1...100 {
        step(powerMap: &powerMap)
    }

    return powerMap.flashCount
}

func step(powerMap: inout PowerMap) {

    var flashingIndicies: [GridCoordinates] = []

    powerMap.grid.allCoordinates.forEach {
        powerMap.grid[$0] += 1
        if powerMap.grid[$0] == 10 {
            flashingIndicies.append($0)
        }
    }

    var flashedIndicies: Set<GridCoordinates> = []

    while let flashingCoordinates = flashingIndicies.popLast() {
        powerMap.flashCount += 1
        powerMap.grid[flashingCoordinates] -= 10
        flashedIndicies.insert(flashingCoordinates)
        adjacentIndicies(fromCoordinates: flashingCoordinates, grid: powerMap.grid).forEach {
            powerMap.grid[$0] += 1
            if powerMap.grid[$0] == 10 {
                flashingIndicies.append($0)
            }
        }
    }

    flashedIndicies.forEach {
        powerMap.grid[$0] = 0
    }
}

func adjacentIndicies(fromCoordinates coordinates: GridCoordinates, grid: Grid) -> [GridCoordinates] {
    return (-1...1)
        .map { coordinates.x + $0 }
        .flatMap { _x in
            (-1...1)
                .map { coordinates.y + $0 }
                .map { _y in
                    return GridCoordinates(x: _x, y: _y)
                }
        }
        .filter {
            $0.x >= 0
            && $0.x < grid[0].count
            && $0.y >= 0
            && $0.y < grid.count
            && ($0.x != coordinates.x || $0.y != coordinates.y)
        }
}

// MARK: - Part 2

func part2(grid: Grid) -> Int {

    var powerMap = PowerMap(grid: grid, flashCount: 0)

    var previousFlashCount: Int
    let allFlashingDifference = powerMap.grid.count * powerMap.grid[0].count

    var stepCount = 0

    while true {
        previousFlashCount = powerMap.flashCount
        step(powerMap: &powerMap)
        stepCount += 1

        if powerMap.flashCount - previousFlashCount == allFlashingDifference {
            return stepCount
        }
    }
}

main()

// MARK: - Debug

extension Grid {
    func debugDisplay() {
        self.forEach {
            print($0.map(\.description).joined(separator: " "))
        }

    }
}
