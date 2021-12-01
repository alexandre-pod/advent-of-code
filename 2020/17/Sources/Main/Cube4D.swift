//
//  Cube4D.swift
//  
//
//  Created by Alexandre Podlewski on 17/12/2020.
//

import Foundation

typealias Cube4D = [Grid]

enum Cube4DExtensionDirection: Hashable {
    case gridExtension(GridExtensionDirection)
    case grid0
    case gridLast
}

extension Cube4D {
    var countActiveCells: Int {
        return reduce(0, { $0 + $1.countActiveCells })
    }

    func needsExtensionInDirections() -> Set<Cube4DExtensionDirection> {
        var needdeExtensions: [Cube4DExtensionDirection] = []

        if let lastLayer = last, lastLayer.countActiveCells > 0 {
            needdeExtensions.append(.gridLast)
        }
        if let firstLayer = first, firstLayer.countActiveCells > 0 {
            needdeExtensions.append(.grid0)
        }

        let neededGridExtensions: Set<GridExtensionDirection> = self.reduce(Set(), {
            return $0.union($1.needsExtensionInDirections())
        })

        neededGridExtensions.forEach {
            needdeExtensions.append(.gridExtension($0))
        }

        return Set(needdeExtensions)
    }

    mutating func extendGrid(for directions: Set<Cube4DExtensionDirection>) {
        for direction in directions {
            self.extendGrid(for: direction)
        }
    }

    mutating func extendGrid(for direction: Cube4DExtensionDirection) {
        switch direction {
        case .grid0:
            insert(Grid(lines: self[0][0].count, columns: self[0][0][0].count, height: self[0].count), at: 0)
        case .gridLast:
            append(Grid(lines: self[0][0].count, columns: self[0][0][0].count, height: self[0].count))
        case let .gridExtension(gridExtension):
            self.indices.forEach {
                self[$0].extendGrid(for: gridExtension)
            }
        }
    }

    mutating func extendsIfActiveOnBorders() {
        extendGrid(for: needsExtensionInDirections())
    }

    func nextIteration() -> Cube4D {
        var nextCube4D = self
        nextCube4D.extendsIfActiveOnBorders()
        let baseCube4D = nextCube4D

        for width in baseCube4D.indices {
            for height in baseCube4D[width].indices {
                for line in baseCube4D[width][height].indices {
                    for column in baseCube4D[width][height][line].indices {
                        let activeCount = baseCube4D.countActiveNeighbours(column: column, line: line, height: height, width: width)
                        let isActive = baseCube4D[width][height][line][column] == .active
                        if !isActive && activeCount == 3 {
                            nextCube4D[width][height][line][column] = .active
                        } else if isActive && (activeCount == 2 || activeCount == 3) {
                            nextCube4D[width][height][line][column] = .active
                        } else {
                            nextCube4D[width][height][line][column] = .inactive
                        }
                    }
                }
            }
        }

        return nextCube4D
    }

    func countActiveNeighbours(column: Int, line: Int, height: Int, width: Int) -> Int {
        [-1, 0, 1]
            .map { width + $0 }
            .filter { self.indices.contains($0) }
            .map { gridWidth in
                let gridNeighbors = self[gridWidth].countActiveNeighbours(column: column, line: line, height: height)
                if gridWidth != width {
                    return gridNeighbors + (self[gridWidth][height][line][column] == .active ? 1 : 0)
                } else {
                    return gridNeighbors
                }
            }
            .reduce(0, (+))
    }
}
