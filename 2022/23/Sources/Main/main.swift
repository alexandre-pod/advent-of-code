import Foundation

enum Tile: Character {
    case elf = "#"
    case empty = "."
}

typealias Grid = [[Tile]]

func main() {
    var grid: Grid = []

    while let line = readLine() {
        grid.append(line.map { Tile(rawValue: $0)! })
    }

    print(part1(grid: grid))
    print(part2(grid: grid))
}

// MARK: - Part 1

func part1(grid: Grid) -> Int {
    var elfPositions: Set<Point> = []
    var priorities: [Direction] = [.north, .south, .west, .east]

    for (y, row) in grid.enumerated() {
        for (x, tile) in row.enumerated() where tile == .elf {
            elfPositions.insert(Point(x: x, y: y))
        }
    }

//    printGrid(elfPositions)

    for round in 1...10 {
        let nextPositions = simulateRound(from: elfPositions, priorities: priorities)
        elfPositions = nextPositions
        priorities.append(priorities.removeFirst())
//        print("Round \(round)")
//        printGrid(elfPositions)
//        print()
    }

    return countEmptyPoints(in: elfPositions)
}

struct Point: Hashable {
    let x: Int
    let y: Int
}

enum Direction {
    case north
    case south
    case west
    case east
}

func simulateRound(from positions: Set<Point>,  priorities: [Direction]) -> Set<Point> {
    var proposedPositions: [Point: [Point]] = [:]

    for position in positions {
        let nextPosition = proposedPosition(from: position, in: positions, priorities: priorities)
        proposedPositions[nextPosition, default: []].append(position)
    }

    var finalPositions: Set<Point> = []
    proposedPositions.forEach { (targetPosition, elfs) in
        if elfs.count == 1 {
            finalPositions.insert(targetPosition)
        } else {
            finalPositions.formUnion(elfs)
        }
    }

    return finalPositions
}

func proposedPosition(from point: Point, in points: Set<Point>, priorities: [Direction]) -> Point {
    guard point.pointsNeighbours.contains(where: { points.contains($0) }) else {
        return point
    }
    for direction in priorities {
        if point.points(along: direction).allSatisfy({ !points.contains($0) }) {
            return point.point(along: direction)
        }
    }
    return point
}

extension Point {

    var pointsNeighbours: [Point] {
        [
            Point(x: x + 1, y: y - 1),
            Point(x: x + 1, y: y),
            Point(x: x + 1, y: y + 1),
            Point(x: x - 1, y: y - 1),
            Point(x: x - 1, y: y),
            Point(x: x - 1, y: y + 1),
            Point(x: x, y: y - 1),
            Point(x: x, y: y + 1)
        ]
    }

    func points(along direction: Direction) -> [Point] {
        switch direction {
        case .north:
            return pointsNorth
        case .south:
            return pointsSouth
        case .west:
            return pointsWest
        case .east:
            return pointsEast
        }
    }

    func point(along direction: Direction) -> Point {
        switch direction {
        case .north:
            return pointNorth
        case .south:
            return pointSouth
        case .west:
            return pointWest
        case .east:
            return pointEast
        }
    }

    var pointNorth: Point { Point(x: x, y: y - 1) }
    var pointsNorth: [Point] {
        [
            Point(x: x - 1, y: y - 1),
            pointNorth,
            Point(x: x + 1, y: y - 1)
        ]
    }

    var pointSouth: Point { Point(x: x, y: y + 1) }
    var pointsSouth: [Point] {
        [
            Point(x: x - 1, y: y + 1),
            pointSouth,
            Point(x: x + 1, y: y + 1)
        ]
    }

    var pointWest: Point { Point(x: x - 1, y: y) }
    var pointsWest: [Point] {
        [
            Point(x: x - 1, y: y - 1),
            pointWest,
            Point(x: x - 1, y: y + 1)
        ]
    }

    var pointEast: Point { Point(x: x + 1, y: y) }
    var pointsEast: [Point] {
        [
            Point(x: x + 1, y: y - 1),
            pointEast,
            Point(x: x + 1, y: y + 1)
        ]
    }
}

func countEmptyPoints(in grid: Set<Point>) -> Int {
    let minX = grid.map(\.x).min()!
    let maxX = grid.map(\.x).max()!
    let minY = grid.map(\.y).min()!
    let maxY = grid.map(\.y).max()!

    return (maxX - minX + 1) * (maxY - minY + 1) - grid.count
}

func printGrid(_ grid: Set<Point>) {
    let minX = grid.map(\.x).min()!
    let maxX = grid.map(\.x).max()!
    let minY = grid.map(\.y).min()!
    let maxY = grid.map(\.y).max()!

    for y in minY...maxY {
        let row = (minX...maxX).map { grid.contains(Point(x: $0, y: y)) ? "#" : "." }
        print(row.joined())
    }
}

// MARK: - Part 2

func part2(grid: Grid) -> Int {
    var elfPositions: Set<Point> = []
    var priorities: [Direction] = [.north, .south, .west, .east]

    for (y, row) in grid.enumerated() {
        for (x, tile) in row.enumerated() where tile == .elf {
            elfPositions.insert(Point(x: x, y: y))
        }
    }

    var round = 1

    var nextPositions = simulateRound(from: elfPositions, priorities: priorities)
    priorities.append(priorities.removeFirst())

    while elfPositions != nextPositions {
        round += 1
        elfPositions = nextPositions
        nextPositions = simulateRound(from: elfPositions, priorities: priorities)
        priorities.append(priorities.removeFirst())
    }

    return round
}

main()
