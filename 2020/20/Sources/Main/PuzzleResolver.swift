//
//  PuzzleResolver.swift
//  
//
//  Created by Alexandre Podlewski on 20/12/2020.
//

import Foundation

struct PuzzleResolver {
    let puzzle: Puzzle

    func resolve() -> [[Tile]] {
        guard let topLeftCorner = findTopLeftPiece() else {
            fatalError("Unsolvable puzzle")
        }
        var usedPieces = Set<Tile.ID>()

        let firstRow = resolveRow(startingWith: topLeftCorner, alreadyUsedPieces: usedPieces)
        firstRow.map(\.id).forEach { usedPieces.insert($0) }

        var resolved: [[Tile]] = [firstRow]

        while let firstNextLinePiece = findPiece(to: resolved.last!.first!, on: .bottom, excluding: usedPieces) {
            let nextRow = resolveRow(startingWith: firstNextLinePiece, alreadyUsedPieces: usedPieces)
            nextRow.map(\.id).forEach { usedPieces.insert($0) }
            resolved.append(nextRow)
        }

        assert(resolved.isRectangular)
        return resolved
    }

    private func findTopLeftPiece() -> Tile? {
        let allPossiblePieces = puzzle.pieces.flatMap { [$0, $0.flipped(horizontally: true), $0.flipped(horizontally: false)] }
        return allPossiblePieces.first { piece in

            let topCompatible = puzzle.findCompatiblePieces(to: piece, on: .top)
            let leftCompatible = puzzle.findCompatiblePieces(to: piece, on: .left)

            let allCompatibleSet = Set(topCompatible.map(\.id) + leftCompatible.map(\.id))

            return allCompatibleSet.isEmpty
        }
    }

    private func resolveRow(startingWith leftPiece: Tile, alreadyUsedPieces: Set<Tile.ID>) -> [Tile] {
        var usedPieces = alreadyUsedPieces
        usedPieces.insert(leftPiece.id)
        var pieces: [Tile] = [leftPiece]
        while let nextPiece = findPiece(to: pieces.last!, on: .right, excluding: usedPieces) {
            pieces.append(nextPiece)
            usedPieces.insert(nextPiece.id)
        }
        return pieces
    }

    private func findPiece(to piece: Tile, on side: Tile.BorderSide, excluding excludedIDs: Set<Tile.ID>) -> Tile? {
        let compatible = puzzle.findCompatiblePieces(to: piece, on: side)
            .filter { !excludedIDs.contains($0.id) }
        if compatible.count > 1 {
            print("WARN: Not a unique solution !")
        }
        return compatible.first
    }
}

private extension Array where Element == Swift.Array<Tile> {
    var isRectangular: Bool {
        let height = count
        if height == 0 {
            return true
        }
        let width = first!.count
        return allSatisfy { $0.count == width }
    }
}
