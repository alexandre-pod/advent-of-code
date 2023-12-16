import Foundation

typealias Grid = [[Cell]]

enum Cell: Character {
    case empty = "."
    case leftMirror = "/"
    case rightMirror = "\\"
    case horizontalSplitter = "-"
    case verticalSplitter = "|"
}

struct Coordinates {
    let x: Int
    let y: Int

    func apply(direction: Direction) -> Self {
        Coordinates(x: x + direction.offset.dx, y: y + direction.offset.dy)
    }
}

extension Array {
    subscript<T>(_ coordinates: Coordinates) -> T where Element == [T] {
        get { self[coordinates.y][coordinates.x] }
        set { self[coordinates.y][coordinates.x] = newValue }
    }
}

enum Direction {
    case up
    case down
    case left
    case right
}

extension Direction {
    var offset: (dx: Int, dy: Int) {
        return switch self {
        case .up: (0, -1)
        case .down: (0, 1)
        case .left: (-1, 0)
        case .right: (1, 0)
        }
    }
}

func main() {
    var input: Grid = []

    while let line = readLine() {
        input.append(line.map { Cell(rawValue: $0)! })
    }

    print(part1(grid: input))
    print(part2(grid: input))
}

// MARK: - Part 1

func part1(grid: Grid) -> Int {
    return grid.energizedCellCount(with: Beam(position: Coordinates(x: 0, y: 0), direction: .right))
}

struct Beam {
    var position: Coordinates
    var direction: Direction
}

extension Grid {
    func energizedCellCount(with beam: Beam) -> Int {
        var lightDiffusionGrid = LightDiffusionGrid(width: self[0].count, height: self.count)
        lightDiffusionGrid.propagate(beam: beam, with: self)

//        lightDiffusionGrid.debugPrint()

        return lightDiffusionGrid
            .map { $0.filter { !$0.isEmpty }.count }
            .reduce(0, +)
    }
}

typealias LightDiffusionGrid = [[Set<Direction>]]

extension LightDiffusionGrid {
    init(width: Int, height: Int) {
        self = Array(repeating: Swift.Array(repeating: [], count: width), count: height)
    }

    mutating func propagate(beam: Beam, with grid: Grid) {
        guard 
            grid.indices.contains(beam.position.y),
            grid[beam.position.y].indices.contains(beam.position.x),
            !self[beam.position].contains(beam.direction)
        else { return }
        self[beam.position].insert(beam.direction)

        for incidentBeam in beam.resultBeamsOver(cell: grid[beam.position]) {
            propagate(beam: incidentBeam, with: grid)
        }
    }
}

extension Beam {
    func resultBeamsOver(cell: Cell) -> [Beam] {
        switch cell {
        case .empty:
            return [Beam(position: position.apply(direction: direction), direction: direction)]
        case .rightMirror:
            switch direction {
            case .up:
                return [Beam(position: position.apply(direction: .left), direction: .left)]
            case .down:
                return [Beam(position: position.apply(direction: .right), direction: .right)]
            case .left:
                return [Beam(position: position.apply(direction: .up), direction: .up)]
            case .right:
                return [Beam(position: position.apply(direction: .down), direction: .down)]
            }
        case .leftMirror:
            switch direction {
            case .up:
                return [Beam(position: position.apply(direction: .right), direction: .right)]
            case .down:
                return [Beam(position: position.apply(direction: .left), direction: .left)]
            case .left:
                return [Beam(position: position.apply(direction: .down), direction: .down)]
            case .right:
                return [Beam(position: position.apply(direction: .up), direction: .up)]
            }
        case .horizontalSplitter:
            switch direction {
            case .up, .down:
                return [
                    Beam(position: position, direction: .left),
                    Beam(position: position, direction: .right)
                ]
            case .left, .right:
                return [Beam(position: position.apply(direction: direction), direction: direction)]
            }
        case .verticalSplitter:
            switch direction {
            case .left, .right:
                return [
                    Beam(position: position, direction: .up),
                    Beam(position: position, direction: .down)
                ]
            case .up, .down:
                return [Beam(position: position.apply(direction: direction), direction: direction)]
            }
        }
    }
}

// MARK: - Part 2

func part2(grid: Grid) -> Int {
    return grid.possibleBeamStart
        .map { grid.energizedCellCount(with: $0) }
        .max()!
}

extension Grid {
    var possibleBeamStart: [Beam] {
        var results: [Beam] = []
        results.append(contentsOf: self.indices.map {
            Beam(position: Coordinates(x: 0, y: $0), direction: .right)
        })
        results.append(contentsOf: self.indices.map {
            Beam(position: Coordinates(x: self[0].count - 1, y: $0), direction: .left)
        })
        results.append(contentsOf: self[0].indices.map {
            Beam(position: Coordinates(x: $0, y: 0), direction: .down)
        })
        results.append(contentsOf: self[0].indices.map {
            Beam(position: Coordinates(x: $0, y: self.count - 1), direction: .up)
        })
        return results
    }
}

// MARK: - Visualisation

extension Grid {
    func debugPrint() {
        self.forEach {
            print(String($0.map(\.rawValue)))
        }
        print()
    }
}

extension LightDiffusionGrid {
    func debugPrint() {
        forEach { line in
            print(line.map { $0.isEmpty ? "." : "#" }.joined())
        }
        print()
    }
}

main()
