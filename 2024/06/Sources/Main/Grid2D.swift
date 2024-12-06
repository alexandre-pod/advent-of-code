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
    let x: Int
    let y: Int
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

extension Coordinate2D {
    func moved(by direction: Direction) -> Self {
        Coordinate2D(
            x: x + direction.deltaX,
            y: y + direction.deltaY
        )
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
