import Foundation

typealias InputType = [[Character]]

func main() {
    var input: InputType = []

    while let line = readLine() {
        input.append(line.map { $0 })
    }

    print(part1(inputParameter: input))
    print(part2(inputParameter: input))
}

// MARK: - Part 1

func part1(inputParameter: InputType) -> Int {
    var plainMap = plainMap(from: inputParameter)
    var positions: Set<Point> = [plainMap.entry]

    while !positions.contains(plainMap.exit) {
//        plainMap.display(with: positions)
//        Thread.sleep(forTimeInterval: 0.5)
        plainMap = plainMap.nextTurn()
        var nextPositions: Set<Point> = []

        for position in positions {
            position.availableMoves
                .filter { plainMap.canMove(to: $0) }
                .forEach { nextPositions.insert($0) }
        }
        positions = nextPositions
    }

    return plainMap.time
}

struct Point: Hashable {
    var x: Int
    var y: Int
}

enum Direction: CaseIterable {
    case top
    case left
    case right
    case bottom
}

struct PlainMap {
    let time: Int

    let minXWall: Int
    let maxXWall: Int
    let minYWall: Int
    let maxYWall: Int

    let entry: Point
    let exit: Point

    let blizzardDirections: [Point: [Direction]]
}

extension PlainMap {
    func canMove(to point: Point) -> Bool {
        if point == entry || point == exit { return true}
        return !blizzardDirections.keys.contains(point)
            && point.x > minXWall
            && point.x < maxXWall
            && point.y > minYWall
            && point.y < maxYWall

    }
}

extension Point {
    var availableMoves: [Point] {
        [
            Point(x: x + 1, y: y),
            Point(x: x - 1, y: y),
            Point(x: x, y: y + 1),
            Point(x: x, y: y - 1),
            Point(x: x, y: y)
        ]
    }
}

func plainMap(from inputParameter: InputType) -> PlainMap {
    var blizzardDirections: [Point : [Direction]] = [:]

    for (y, line) in inputParameter.enumerated() {
        for (x, tile) in line.enumerated() {
            switch tile {
            case "^":
                blizzardDirections[Point(x: x, y: y), default: []].append(.top)
            case "<":
                blizzardDirections[Point(x: x, y: y), default: []].append(.left)
            case ">":
                blizzardDirections[Point(x: x, y: y), default: []].append(.right)
            case "v":
                blizzardDirections[Point(x: x, y: y), default: []].append(.bottom)
            default:
                break
            }
        }
    }


    return PlainMap(
        time: 0,
        minXWall: 0,
        maxXWall: inputParameter[0].count - 1,
        minYWall: 0,
        maxYWall: inputParameter.count - 1,
        entry: Point(x: inputParameter.first!.firstIndex { $0 == "." }!, y: 0),
        exit: Point(x: inputParameter.last!.firstIndex { $0 == "." }!, y: inputParameter.count - 1),
        blizzardDirections: blizzardDirections
    )
}

extension PlainMap {
    func nextTurn() -> PlainMap {

        var blizzardDirections: [Point : [Direction]] = [:]

        for (point, directions) in self.blizzardDirections {
            for direction in directions {
                let nextPoint = nextPosition(from: point, along: direction)
                blizzardDirections[nextPoint, default: []].append(direction)

            }
        }

        return PlainMap(
            time: time + 1,
            minXWall: minXWall,
            maxXWall: maxXWall,
            minYWall: minYWall,
            maxYWall: maxYWall,
            entry: entry,
            exit: exit,
            blizzardDirections: blizzardDirections
        )
    }

    func nextPosition(from point: Point, along direction: Direction) -> Point {
        var nextPoint = Point(
            x: point.x + direction.dx,
            y: point.y + direction.dy
        )
        if nextPoint.x >= maxXWall {
            nextPoint.x = nextPoint.x - maxXWall + minXWall + 1
        } else if nextPoint.x <= minXWall {
            nextPoint.x = nextPoint.x - minXWall + maxXWall - 1
        }
        if nextPoint.y >= maxYWall {
            nextPoint.y = nextPoint.y - maxYWall + minYWall + 1
        } else if nextPoint.y <= minYWall {
            nextPoint.y = nextPoint.y - minYWall + maxYWall - 1
        }
        return nextPoint
    }

    func display(with positions: Set<Point>) {
        print("Time: \(time)")
        for y in minYWall...maxYWall {
            var row: [String] = []
            for x in minXWall...maxXWall {
                let point = Point(x: x, y: y)
                if positions.contains(point) {
                    row.append("•")
                } else if point == entry || point == exit {
                    row.append(" ")
                } else if point.x == minXWall || point.x == maxXWall || point.y == minYWall || point.y == maxYWall {
                    row.append("#")
                } else if let blizzards = blizzardDirections[point] {
                    row.append(blizzards.blizzardDescription)
                } else {
                    row.append(" ")
                }
            }
            print(row.joined())
        }
    }
}

extension [Direction] {
    var blizzardDescription: String {
        if count == 1 {
            return self[0].blizzardDescription
        } else {
            return "\(count)"
        }
    }
}

extension Direction {
    var blizzardDescription: String {
        switch self {
        case .top:
            return "^"
        case .left:
            return "<"
        case .right:
            return ">"
        case .bottom:
            return "v"
        }
    }
}

extension Direction {
    var dx: Int {
        switch self {
        case .top:
            return 0
        case .left:
            return -1
        case .right:
            return 1
        case .bottom:
            return 0
        }
    }

    var dy: Int {
        switch self {
        case .top:
            return -1
        case .left:
            return 0
        case .right:
            return 0
        case .bottom:
            return 1
        }
    }
}

// MARK: - Part 2

func part2(inputParameter: InputType) -> Int {
    var plainMap = plainMap(from: inputParameter)
    var positions: Set<Point> = [plainMap.entry]

    while !positions.contains(plainMap.exit) {
//        plainMap.display(with: positions)
//        Thread.sleep(forTimeInterval: 0.5)
        plainMap = plainMap.nextTurn()
        var nextPositions: Set<Point> = []

        for position in positions {
            position.availableMoves
                .filter { plainMap.canMove(to: $0) }
                .forEach { nextPositions.insert($0) }
        }
        positions = nextPositions
    }

    positions = [plainMap.exit]

    while !positions.contains(plainMap.entry) {
//        plainMap.display(with: positions)
//        Thread.sleep(forTimeInterval: 0.5)
        plainMap = plainMap.nextTurn()
        var nextPositions: Set<Point> = []

        for position in positions {
            position.availableMoves
                .filter { plainMap.canMove(to: $0) }
                .forEach { nextPositions.insert($0) }
        }
        positions = nextPositions
    }

    positions = [plainMap.entry]
    while !positions.contains(plainMap.exit) {
//        plainMap.display(with: positions)
//        Thread.sleep(forTimeInterval: 0.5)
        plainMap = plainMap.nextTurn()
        var nextPositions: Set<Point> = []

        for position in positions {
            position.availableMoves
                .filter { plainMap.canMove(to: $0) }
                .forEach { nextPositions.insert($0) }
        }
        positions = nextPositions
    }

    return plainMap.time
}

main()
