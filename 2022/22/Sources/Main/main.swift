import Foundation

struct Coordinate: Hashable {
    let x: Int
    let y: Int
}

enum Tile: Character {
    case void = " "
    case open = "."
    case wall = "#"
}

typealias Grid = [[Tile]]

struct InputType {
    let grid: Grid
    let path: Path
}

func main() {
    let input = InputType(grid: parseGrid(), path: parsePath())

    print(part1(inputParameter: input))
    print(part2(inputParameter: input))
}

func parseGrid() -> Grid {
    var grid: Grid = []
    while let line = readLine(), !line.isEmpty {
        grid.append(line.map { Tile(rawValue: $0)! })
    }
    return grid
}

enum PathInstruction {
    case forward(Int)
    case rotateLeft
    case rotateRight
}

typealias Path = [PathInstruction]

func parsePath() -> Path {
    let stringPath = readLine()!.map { $0 }


    var remainingString = stringPath[0...]

    func parseNumber() -> Int {
        var number = 0
        while remainingString.first?.isNumber ?? false {
            let character = remainingString.popFirst()!
            number = 10 * number + Int(String(character))!
        }
        return number
    }

    func parseCharacter() -> Character? {
        return remainingString.popFirst()
    }

    var path: Path = []

    while !remainingString.isEmpty {
        path.append(.forward(parseNumber()))
        switch parseCharacter() {
        case "R":
            path.append(.rotateRight)
        case "L":
            path.append(.rotateLeft)
        case .none:
            break
        default:
            fatalError()
        }
    }
    return path
}

// MARK: - Part 1

func part1(inputParameter: InputType) -> Int {
    let startPosition = Coordinate(
        x: inputParameter.grid[0].firstIndex(of: .open)!,
        y: 0
    )

    var currentPosition = startPosition
    var direction: Direction = .right

//    var currentPosition = startPosition {
//        didSet { print(currentPosition) }
//    }
//    var direction: Direction = .right {
//        didSet { print(direction) }
//    }

    let grid = inputParameter.grid

    for instruction in inputParameter.path {
        switch instruction {
        case .rotateLeft:
            direction = direction.rotatingLeft()
        case .rotateRight:
            direction = direction.rotatingRight()
        case let .forward(distance):
            for _ in 0..<distance {
                let nextPosition = grid.nextCoordinate(from: currentPosition, along: direction)
                if grid[nextPosition] == .open {
                    currentPosition = nextPosition
                }
            }
        }
    }

    let row = currentPosition.y + 1
    let column = currentPosition.x + 1

    return 1000 * row + 4 * column + direction.part1Value
}

enum Direction {
    case right
    case left
    case bottom
    case up
}

extension Direction {
    var part1Value: Int {
        switch self {
        case .right:
            return 0
        case .left:
            return 2
        case .bottom:
            return 1
        case .up:
            return 3
        }
    }
}

extension Direction {
    func rotatingRight() -> Direction {
        switch self {
        case .right:
            return .bottom
        case .left:
            return .up
        case .bottom:
            return .left
        case .up:
            return .right
        }
    }

func rotatingLeft() -> Direction {
        switch self {
        case .right:
            return .up
        case .left:
            return .bottom
        case .bottom:
            return .right
        case .up:
            return .left
        }
    }

    var coordinateOffset: Coordinate {
        switch self {
        case .right:
            return Coordinate(x: 1, y: 0)
        case .left:
            return Coordinate(x: -1, y: 0)
        case .bottom:
            return Coordinate(x: 0, y: 1)
        case .up:
            return Coordinate(x: 0, y: -1)
        }
    }
}

extension Grid {
    func nextCoordinate(from coordinate: Coordinate, along direction: Direction) -> Coordinate {
        let nextCoordinate = coordinate + direction.coordinateOffset
        if contains(nextCoordinate), self[nextCoordinate] != .void {
            return nextCoordinate
        }
        return fartherPosition(from: coordinate, along: direction.rotatingLeft().rotatingLeft())
    }

    func fartherPosition(from coordinate: Coordinate, along direction: Direction) -> Coordinate {
        var last = coordinate
        var nextCoordinate = coordinate + direction.coordinateOffset
        while contains(nextCoordinate) {
            if self[nextCoordinate] != .void {
                last = nextCoordinate
            }
            nextCoordinate += direction.coordinateOffset
        }
        return last
    }

    func contains(_ coordinate: Coordinate) -> Bool {
        return self.indices.contains(coordinate.y)
            && self[coordinate.y].indices.contains(coordinate.x)
    }

    subscript(_ coordinate: Coordinate) -> Tile {
        self[coordinate.y][coordinate.x]
    }
}

extension Coordinate: AdditiveArithmetic {

    static var zero: Coordinate {
        return Coordinate(x: 0, y: 0)
    }

    static func + (lhs: Coordinate, rhs: Coordinate) -> Coordinate {
        Coordinate(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func - (lhs: Coordinate, rhs: Coordinate) -> Coordinate {
        Coordinate(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

extension Coordinate {
    func multiply(by value: Int) -> Coordinate {
        return Coordinate(x: x * value, y: y * value)
    }
}


// MARK: - Part 2

func part2(inputParameter: InputType) -> Int {

    let startPosition = Coordinate(
        x: inputParameter.grid[0].firstIndex(of: .open)!,
        y: 0
    )

    var currentPosition = startPosition
    var direction: Direction = .right

    //    var currentPosition = startPosition {
    //        didSet { print(currentPosition) }
    //    }
    //    var direction: Direction = .right {
    //        didSet { print(direction) }
    //    }

    let grid = inputParameter.grid

    let wrapCache = part2WrapCache()
//    let wrapCache = sampleWrapCache()

    var orientations: [Coordinate: Direction] = [:]

    for instruction in inputParameter.path {
        orientations[currentPosition] = direction
        switch instruction {
        case .rotateLeft:
            direction = direction.rotatingLeft()
        case .rotateRight:
            direction = direction.rotatingRight()
        case let .forward(distance):
            for _ in 0..<distance {
                orientations[currentPosition] = direction
                let key = DirectionalCoordinate(coordinate: currentPosition, direction: direction)
                let nextPosition = grid.nextCoordinatePart2(for: key, wrapCache: wrapCache)
                if grid[nextPosition.coordinate] == .open {
                    currentPosition = nextPosition.coordinate
                    direction = nextPosition.direction
                }
            }
        }
    }

    grid.display(with: orientations)

    //    print(currentPosition)
    //    print(direction)

    let row = currentPosition.y + 1
    let column = currentPosition.x + 1

    return 1000 * row + 4 * column + direction.part1Value
}

extension Grid {
    func display(with directions: [Coordinate: Direction]) {
        let grid = uniformized()
        for y in 0..<grid.count {
            let row = (0..<grid[y].count).map { x in
                directions[Coordinate(x: x, y: y)]?.character ?? grid[y][x].rawValue
            }
            print(row.map { String($0) }.joined())
        }
    }

    func uniformized() -> Grid {
        let maxWidth = map(\.count).max()!
        return self.map {
            $0 + [Tile].init(repeating: .void, count: maxWidth - $0.count)
        }
    }
}

extension Direction {
    var character: Character {
        switch self {
        case .right:
            return ">"
        case .left:
            return "<"
        case .bottom:
            return "v"
        case .up:
            return "^"
        }
    }
}

extension Direction {
    var opposite: Direction {
        return rotatingLeft().rotatingLeft()
    }
}

struct DirectionalCoordinate: Hashable {
    let coordinate: Coordinate
    let direction: Direction
}

extension Grid {
    func nextCoordinatePart2(
        for directionalCoordinate: DirectionalCoordinate,
        wrapCache: [DirectionalCoordinate: DirectionalCoordinate]
    ) -> DirectionalCoordinate {

        if let value = wrapCache[directionalCoordinate] {
            return value
        }

        let nextCoordinate = directionalCoordinate.coordinate + directionalCoordinate.direction.coordinateOffset
        if contains(nextCoordinate), self[nextCoordinate] != .void {
            return DirectionalCoordinate(coordinate: nextCoordinate, direction: directionalCoordinate.direction)
        }

        print(directionalCoordinate)

        fatalError()
    }
}

main()
