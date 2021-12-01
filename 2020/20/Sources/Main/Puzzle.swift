//
//  Puzzle.swift
//  
//
//  Created by Alexandre Podlewski on 20/12/2020.
//

import Foundation

struct Puzzle {
    let pieces: [Tile]
    private let bordersMap: BordersMap

    init(pieces: [Tile]) {
        self.pieces = pieces
        self.bordersMap = BordersMap(from: pieces)
    }

    func findCompatiblePieces(to piece: Tile, on side: Tile.BorderSide) -> [Tile] {
        return findCompatiblePieces(withBorder: piece.borderCells(side).reversed(), on: side.opposite)
            .filter { $0.id != piece.id }
            .deduped(on: \.id)
    }

    /// side is the side that the returned tiles should match with
    private func findCompatiblePieces(withBorder border: Tile.Border, on side: Tile.BorderSide) -> [Tile] {
        return (bordersMap[border] ?? []).map { $0.tile.rotateSide($0.side, to: side) }
    }
}

private extension Tile.BorderSide {
    var opposite: Tile.BorderSide {
        switch self {
        case .bottom:
            return .top
        case .left:
            return .right
        case .right:
            return .left
        case .top:
            return .bottom
        }
    }
}

private extension BordersMap {
    init(from tiles: [Tile]) {
        var borders: BordersMap = [:]
        for tile in tiles {
            allBorderCells(for: tile).forEach {
                borders[$0.border, default: []].append(($0.tile, $0.side))
            }
        }
        self = borders
    }
}
