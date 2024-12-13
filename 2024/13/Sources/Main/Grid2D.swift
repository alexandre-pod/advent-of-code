//
//  Grid2D.swift
//  Main
//
//  Created by Alexandre Podlewski on 06/12/2024.
//

struct Grid2D<Cell> {
    let width: Int
    let height: Int

    var cells: [[Cell]]

    init(cells: [[Cell]]) {
        self.height = cells.count
        self.width = cells[0].count
        self.cells = cells
        assert(cells.allSatisfy { $0.count == width })
    }

    init(defaultValue: Cell, width: Int, height: Int) {
        self.height = height
        self.width = width
        self.cells = Array(repeating: Array(repeating: defaultValue, count: width), count: height)
    }
}

struct Coordinate2D: Hashable {
    var x: Int
    var y: Int
}

extension Coordinate2D: AdditiveArithmetic {
    static let zero = Coordinate2D(x: 0, y: 0)

    static func +(lhs: Self, rhs: Self) -> Self {
        Coordinate2D(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func -(lhs: Self, rhs: Self) -> Self {
        Coordinate2D(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}


extension Grid2D {
    func contains(_ coordinate: Coordinate2D) -> Bool {
        (0..<height).contains(coordinate.y) && (0..<width).contains(coordinate.x)
    }

    subscript(_ coordinates: Coordinate2D) -> Cell {
        get { cells[coordinates.y][coordinates.x] }
        set { cells[coordinates.y][coordinates.x] = newValue }
    }

    var allCoordinates: some Sequence<Coordinate2D> {
        (0..<height)
            .lazy
            .flatMap { y in
                (0..<width).lazy.map { x in Coordinate2D(x: x, y: y) }
            }
    }
}

struct Direction: Hashable {
    let deltaX: Int
    let deltaY: Int
}


extension Direction {
    static let left = Direction(deltaX: -1, deltaY: 0)
    static let right = Direction(deltaX: 1, deltaY: 0)
    static let up = Direction(deltaX: 0, deltaY: -1)
    static let down = Direction(deltaX: 0, deltaY: 1)
}

extension Coordinate2D {
    func moved(by direction: Direction) -> Self {
        Coordinate2D(
            x: x + direction.deltaX,
            y: y + direction.deltaY
        )
    }
}

extension Grid2D {
    func cardinalNeighbours(to position: Coordinate2D) -> [Coordinate2D] {
        guard contains(position) else { return [] }

        return [(-1, 0), (1, 0), (0, -1), (0, 1)]
            .map { Direction(deltaX: $0.0, deltaY: $0.1) }
            .map { position.moved(by: $0) }
            .filter { self.contains($0) }
    }
}


// MARK: - Debug

extension Grid2D {
    func printDebug(celltoCharacter: (Cell) -> Character) {
        for line in cells {
            print(line.map { String(celltoCharacter($0)) }.joined())
        }
    }
}

extension Coordinate2D: CustomStringConvertible {
//    var description: String { "(x: \(x), y: \(y))" }
    var description: String { "(\(x), \(y))" }
}
