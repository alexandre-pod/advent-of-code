import Foundation

struct Coordinate: Hashable, Equatable {
    let x: Int
    let y: Int
}

extension Coordinate {
    init?(fromString string: String) {
        let components = string.split(separator: ",").compactMap { Int(String($0)) }
        guard components.count == 2 else { return nil }
        self.x = components[0]
        self.y = components[1]
    }
}

typealias Path = [Coordinate]
typealias Paths = [Path]

func main() {
    var input: Paths = []

    while let line = readLine() {
        let path = line.split(separator: " ")
            .filter { $0 != "->" }
            .map { Coordinate(fromString: String($0))! }
        input.append(path)
    }

    print(part1(paths: input))
    print(part2(paths: input))
}

// MARK: - Part 1

func part1(paths: Paths) -> Int {
    var map: [Coordinate: String] = [:]

    paths.forEach {
        allCoordinates(for: $0).forEach {
            map[$0] = "#"
        }
    }

    let lowerYPoint = map.keys.max { $0.y < $1.y }!.y

    let fallStart = Coordinate(x: 500, y: 0)

    var unitFallCount = 0

    while let unitRestPosition = fallingRestPosition(from: fallStart, in: map, maxY: lowerYPoint) {
        unitFallCount += 1
        map[unitRestPosition] = "o"
        //        printMap(map, xRange: 494..<504, yRange: 0..<10)
    }

    return unitFallCount
}

func allCoordinates(for path: Path) -> [Coordinate] {
    return zip(path, path.dropFirst())
        .flatMap { allCoordinates(between: $0.0, and: $0.1) }
}

func allCoordinates(between point1: Coordinate, and point2: Coordinate) -> [Coordinate] {
    let offset = directionIncrement(between: point1, and: point2)
    guard offset.dx != 0 || offset.dy != 0 else {
        assertionFailure("Invalid offset")
        return [point1, point2]
    }
    var points: [Coordinate] = []
    var currentPoint = point1
    while currentPoint != point2 {
        points.append(currentPoint)
        currentPoint = Coordinate(
            x: currentPoint.x + offset.dx,
            y: currentPoint.y + offset.dy
        )
    }
    points.append(point2)
    return points
}

func directionIncrement(between point1: Coordinate, and point2: Coordinate) -> (dx: Int, dy: Int) {
    assert(point1 != point2)
    if point1.x == point2.x {
        let dy = point1.y < point2.y ? 1 : -1
        return (dx: 0, dy: dy)
    } else {
        let dx = point1.x < point2.x ? 1 : -1
        return (dx: dx, dy: 0)
    }
}

func fallingRestPosition(from start: Coordinate, in map: [Coordinate: String], maxY: Int) -> Coordinate? {
    assert(!map.keys.contains(start), "Start blocked by sand")
    if start.y >= maxY {
        return nil
    }

    guard let nextPosition = start.fallingPreferences.first(where: { !map.keys.contains($0) }) else {
        return start
    }
    return fallingRestPosition(from: nextPosition, in: map, maxY: maxY)
}

extension Coordinate {
    var fallingPreferences: [Coordinate] {
        [
            Coordinate(x: x, y: y + 1),
            Coordinate(x: x - 1, y: y + 1),
            Coordinate(x: x + 1, y: y + 1)
        ]
    }
}

func printMap(_ map: [Coordinate: String], xRange: Range<Int>, yRange: Range<Int>) {
    for y in yRange {
        print(xRange.map { map[Coordinate(x: $0, y: y)] ?? "." }.joined())
    }
}

// MARK: - Part 2

func part2(paths: Paths) -> Int {
    var map: [Coordinate: String] = [:]

    paths.forEach {
        allCoordinates(for: $0).forEach {
            map[$0] = "#"
        }
    }

    let lowerYPoint = map.keys.max { $0.y < $1.y }!.y

    let fallStart = Coordinate(x: 500, y: 0)

    var unitFallCount = 0

    while let unitRestPosition = fallingRestPositionPart2(from: fallStart, in: map, floorY: lowerYPoint + 2) {
        unitFallCount += 1
        map[unitRestPosition] = "o"
//        printMap(map, xRange: 488..<514, yRange: 0..<12)
    }

    return unitFallCount
}

func fallingRestPositionPart2(from start: Coordinate, in map: [Coordinate: String], floorY: Int) -> Coordinate? {
    guard !map.keys.contains(start) else {
        return nil
    }
    if start.y + 1 == floorY {
        return start
    }

    guard let nextPosition = start.fallingPreferences.first(where: { !map.keys.contains($0) }) else {
        return start
    }
    return fallingRestPositionPart2(from: nextPosition, in: map, floorY: floorY)
}

main()
