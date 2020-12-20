//
//  Part2.swift
//  
//
//  Created by Alexandre Podlewski on 20/12/2020.
//

import Foundation

private let seaMonster = [
    "                  # ",
    "#    ##    ##    ###",
    " #  #  #  #  #  #   "
].joined(separator: "\n")

func part2(tiles: [Tile]) {
    let resolver = PuzzleResolver(puzzle: Puzzle(pieces: tiles))
    let resolved = resolver.resolve()
    let resolvedWithoutBorder = resolved.map { $0.map { removeBorders(from: $0) } }

    let mergedLines = resolvedWithoutBorder.map { lineGroup in
        lineGroup.reduce(Array<[Bool]>(repeating: [], count: lineGroup[0].count)) { partial, grid in
            return zip(partial, grid).map { $0.0 + $0.1 }
        }
    }
    let completeImage = mergedLines.reduce(Array<[Bool]>()) { partial, grid in
        if partial.isEmpty {
            return grid
        } else {
            return partial + grid
        }
    }

    let completeFinalTile = Tile(id: 0, cells: completeImage)

    let seaMonsterMask = seaMonster
        .split(separator: "\n")
        .map { $0.map { $0 == "#" } }

    var possibleSeaMonsterIndicies: [(x: Int, y: Int)]?
    var possibleCorrectlyOrientedTile: Tile?

    for tile in allOrientations(of: completeFinalTile) {
        let indicies = findIndices(of: seaMonsterMask, in: tile)
        if !indicies.isEmpty {
            possibleCorrectlyOrientedTile = tile
            possibleSeaMonsterIndicies = indicies
            break
        }
    }

    guard
        let seaMonsterIndicies = possibleSeaMonsterIndicies,
        let correctlyOrientedTile = possibleCorrectlyOrientedTile else {
        print("NO SEA MONSTER FOUND")
        return
    }

    let finalTile = removeMasks(seaMonsterMask, atPositions: seaMonsterIndicies, in: correctlyOrientedTile)
    let answer = finalTile.cells.flatMap { $0 }.filter { $0 }.count

    print("answer: \(answer)")
}

private func allOrientations(of tile: Tile) -> [Tile] {
    var result: [Tile] = []
    for rotation in 0...3 {
        result.append(tile.rotate90(numbersOfRotations: rotation))
        result.append(tile.flipped(horizontally: false).rotate90(numbersOfRotations: rotation))
        result.append(tile.flipped(horizontally: true).rotate90(numbersOfRotations: rotation))
    }
    return result
}

private func removeBorders(from tile: Tile) -> [[Bool]] {
    return Array(tile.cells[1..<(tile.cells.count - 1)].map { Array($0[1..<($0.count - 1)]) })
}

// MARK: - Mask operations

private func findIndices(of mask: [[Bool]], in tile: Tile) -> [(x: Int, y: Int)] {
    let maskHeight = mask.count
    let maskWidth = mask[0].count

    var results: [(x: Int, y: Int)] = []

    for y in 0...(tile.cells.count - maskHeight) {
        for x in 0...(tile[0].count - maskWidth) {
            if maskMatch(mask, atX: x, y: y, in: tile) {
                results.append((x: x, y: y))
            }
        }
    }

    return results
}

private func maskMatch(_ mask: [[Bool]], atX x: Int, y: Int, in tile: Tile) -> Bool {
    for (dy, line) in mask.enumerated() {
        for (dx, value) in line.enumerated() {
            guard value else { continue }
            if tile[y + dy][x + dx] == false {
                return false
            }
        }
    }
    return true
}

private func removeMasks(_ mask: [[Bool]], atPositions positions: [(x: Int, y: Int)], in tile: Tile) -> Tile {
    return positions.reduce(tile) { previousTile, position in
        let (x, y) = position
        return removeMask(mask, atX: x, y: y, in: previousTile)
    }
}

private func removeMask(_ mask: [[Bool]], atX x: Int, y: Int, in tile: Tile) -> Tile {
    var newCells: [[Bool]] = tile.cells
    for (dy, line) in mask.enumerated() {
        for (dx, value) in line.enumerated() {
            guard value else { continue }
            newCells[y + dy][x + dx] = false
        }
    }
    return Tile(id: tile.id, cells: newCells)
}
