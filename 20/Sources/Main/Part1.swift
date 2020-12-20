//
//  Part1.swift
//  
//
//  Created by Alexandre Podlewski on 20/12/2020.
//

import Foundation

// MARK: - Part 1 - done with trick

func part1_1(tiles: [Tile]) {
    var borders: BordersMap = [:]
    for tile in tiles {
        allBorderCells(for: tile).forEach {
            borders[$0.border, default: []].append(($0.tile, $0.side))
        }
    }

    let cornerTiles = findCornerTiles(tiles: tiles, bordersMap: borders)
    let answer = cornerTiles.map(\.id).reduce(1, (*))
    print("answer: \(answer)")

}

private func findCornerTiles(tiles: [Tile], bordersMap: BordersMap) -> [Tile] {
    return tiles.filter { tile in
        compatibleTiles(for: tile, bordersMap: bordersMap).count == 2
    }
}

private func compatibleTiles(for tile: Tile, bordersMap: BordersMap) -> Set<Tile.ID> {
    let allTileBorders = Tile.BorderSide.allCases.map { tile.borderCells($0) }
    let possibleTileMatches = allTileBorders.flatMap { bordersMap[$0] ?? [] }.filter { $0.tile.id != tile.id }
    return Set(possibleTileMatches.map { $0.tile.id })
}

// MARK: - Part 1 - done properly

func part1_2(tiles: [Tile]) {
    let resolver = PuzzleResolver(puzzle: Puzzle(pieces: tiles))
    let resolved = resolver.resolve()
    let resolvedIDs = resolved.map {
        $0.map { $0.id }
    }

    let height = resolvedIDs.count
    let width = resolvedIDs[0].count

    let topLeft = resolvedIDs[0][0]
    let topRight = resolvedIDs[0][width - 1]
    let bottomLeft = resolvedIDs[height - 1][0]
    let bottomRight = resolvedIDs[height - 1][width - 1]

    let answer = topLeft * topRight * bottomLeft * bottomRight

    print("answer: \(answer)")
}
