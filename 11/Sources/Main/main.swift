import Foundation

enum Cell: Equatable {
    case floor
    case available
    case occupied

    init(from character: Character) {
        switch character {
        case ".":
            self = .floor
        case "L":
            self = .available
        case "#":
            self = .occupied
        default:
            fatalError()
        }
    }
}

typealias Grid = [[Cell]]

func main() {

    var grid: Grid = []

    while let line = readLine() {
        grid.append(line.map(Cell.init(from:)))
    }

    part1(grid: grid)
    part2(grid: grid)
}

func part1(grid initialGrid: Grid) {
    var grid = initialGrid
    var nextGrid = runStep(from: grid, using: .v1)

    while grid != nextGrid {
        grid = nextGrid
        nextGrid = runStep(from: grid, using: .v1)
    }

    let finalCount = countOccupied(in: grid)
    print("finalCount: \(finalCount)")
}

func part2(grid initialGrid: Grid) {
    var grid = initialGrid
    var nextGrid = runStep(from: grid, using: .v2)

    while grid != nextGrid {
        grid = nextGrid
        nextGrid = runStep(from: grid, using: .v2)
    }

    let finalCount = countOccupied(in: grid)
    print("finalCount: \(finalCount)")
}

func runStep(from initialGrid: Grid, using version: CountOccupied) -> Grid {
    var grid = initialGrid

    for (y, line) in grid.enumerated() {
        for (x, cell) in line.enumerated() {
            switch cell {
            case .floor:
                continue
            case .available:
                if countOccupied(aroundX: x, y: y, in: initialGrid, version: version) == 0 {
                    grid[y][x] = .occupied
                }
            case .occupied:
                if countOccupied(aroundX: x, y: y, in: initialGrid, version: version) >= version.maxValue {
                    grid[y][x] = .available
                }
            }
        }
    }

    return grid
}

func countOccupied(in grid: Grid) -> Int {
    return grid.flatMap { $0 }.filter { $0 == .occupied }.count
}

enum CountOccupied {
    case v1
    case v2
}

extension CountOccupied {
    var maxValue: Int {
        switch self {
        case .v1: return 4
        case .v2: return 5
        }
    }
}

func countOccupied(aroundX x: Int, y: Int, in grid: Grid, version: CountOccupied) -> Int {
    switch version {
    case .v1:
        return countOccupied1(aroundX: x, y: y, in: grid)
    case .v2:
        return countOccupied2(aroundX: x, y: y, in: grid)
    }
}

func countOccupied1(aroundX x: Int, y: Int, in grid: Grid) -> Int {
    var count = 0
    if x - 1 >= 0, grid[y][x - 1] == .occupied {
        count += 1
    }
    if x + 1 < grid[y].count, grid[y][x + 1] == .occupied {
        count += 1
    }
    if y - 1 >= 0, grid[y - 1][x] == .occupied {
        count += 1
    }
    if y + 1 < grid.count, grid[y + 1][x] == .occupied {
        count += 1
    }
    if x - 1 >= 0, y - 1 >= 0, grid[y - 1][x - 1] == .occupied {
        count += 1
    }
    if x - 1 >= 0, y + 1 < grid.count, grid[y + 1][x - 1] == .occupied {
        count += 1
    }
    if x + 1 < grid[y].count, y - 1 >= 0, grid[y - 1][x + 1] == .occupied {
        count += 1
    }
    if x + 1 < grid[y].count, y + 1 < grid.count, grid[y + 1][x + 1] == .occupied {
        count += 1
    }
    return count
}

struct LookDirection {
    let dx: Int
    let dy: Int
}

extension LookDirection {
    func lookedFrom(x: Int, y: Int) -> (x: Int, y: Int) {
        return (x: x + dx, y: y + dy)
    }
}

func countOccupied2(aroundX x: Int, y: Int, in grid: Grid) -> Int {
    var count = 0
    let directions: [LookDirection] = [
        LookDirection(dx: 1, dy: -1),
        LookDirection(dx: 1, dy: 1),
        LookDirection(dx: -1, dy: -1),
        LookDirection(dx: -1, dy: 1),
        LookDirection(dx: 1, dy: 0),
        LookDirection(dx: -1, dy: 0),
        LookDirection(dx: 0, dy: 1),
        LookDirection(dx: 0, dy: -1),
    ]
    directionLoop: for direction in directions {
        count += countInDirection(direction, x: x, y: y, in: grid)
    }
    return count
}

func countInDirection(_ direction: LookDirection, x: Int, y: Int, in grid: Grid) -> Int {
    var currentX = x
    var currentY = y
    var nextX: Int
    var nextY: Int
    (nextX, nextY) = direction.lookedFrom(x: currentX, y: currentY)
    while isInGrid(x: nextX, y: nextY, grid: grid) {
        switch grid[nextY][nextX] {
        case .available:
            return 0
        case .floor:
            break
        case .occupied:
            return 1
        }
        currentX = nextX
        currentY = nextY
        (nextX, nextY) = direction.lookedFrom(x: currentX, y: currentY)
    }
    return 0
}

func isInGrid(x: Int, y: Int, grid: Grid) -> Bool {
    return x >= 0
        && y >= 0
        && y < grid.count
        && x < grid[0].count
}

main()
