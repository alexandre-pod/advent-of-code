//
//  Tile.swift
//  
//
//  Created by Alexandre Podlewski on 20/12/2020.
//

import Foundation

struct Tile {
    typealias ID = Int
    let id: ID
    let cells: [[Bool]]

    subscript(_ index: Int) -> [Bool] {
        return cells[index]
    }

    typealias Border = [Bool]
    enum BorderSide: CaseIterable {
        case top
        case left
        case right
        case bottom
    }

    func borderCells(_ side: BorderSide) -> Border {
        switch side {
        case .top:
            return cells[0]
        case .left:
            return cells.map { $0[0] }.reversed()
        case .right:
            return cells.map { $0.last! }
        case .bottom:
            return cells.last!.reversed()
        }
    }

    func flipped(horizontally: Bool) -> Tile {
        let cells: [[Bool]]
        if horizontally {
            cells = self.cells.map { $0.reversed() }
        } else {
            cells = self.cells.reversed()
        }
        return Tile(id: id, cells: cells)
    }

    func rotateSide(_ startSide: BorderSide, to endSide: BorderSide) -> Tile {
        if startSide == endSide {
            return self
        }
        return rotate90(numbersOfRotations: 4 + angle90(for: startSide) - angle90(for: endSide))
    }

    private func angle90(for side: BorderSide) -> Int {
        switch side {
        case .top:      return 0
        case .right:    return 1
        case .bottom:   return 2
        case .left:     return 3
        }
    }

    func rotate90(numbersOfRotations: Int) -> Tile {
        if numbersOfRotations % 4 == 0 {
            return self
        }
        let width = cells[0].count
        let rotatedCells: [[Bool]] = cells[0].indices.map { yNew in
            cells.map { $0[width - 1 - yNew] }
        }
        return Tile(id: id, cells: rotatedCells).rotate90(numbersOfRotations: numbersOfRotations - 1)
    }
}

func allBorderCells(for tile: Tile) -> [(border: Tile.Border, tile: Tile, side: Tile.BorderSide)] {
    var result: [(border: [Bool], tile: Tile, side: Tile.BorderSide)] = []

    Tile.BorderSide.allCases.forEach { side in
        result.append((tile.borderCells(side), tile, side))
        let flippedVerticallyTile = tile.flipped(horizontally: false)
        result.append((flippedVerticallyTile.borderCells(side), flippedVerticallyTile, side))
        let flippedHorizontallyTile = tile.flipped(horizontally: true)
        result.append((flippedHorizontallyTile.borderCells(side), flippedHorizontallyTile, side))
    }

    return result
}
