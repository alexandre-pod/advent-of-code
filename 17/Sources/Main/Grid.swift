//
//  Grid.swift
//  
//
//  Created by Alexandre Podlewski on 17/12/2020.
//

import Foundation

typealias Grid = [Plane]

enum GridExtensionDirection: Hashable {
    case planeExtension(PlaneExtensionDirection)
    case plane0
    case planeLast
}

extension Grid {

    init(lines: Int, columns: Int, height: Int) {
        self = Swift.Array(repeating: Plane(lines: lines, columns: columns), count: height)
    }

    var countActiveCells: Int {
        return reduce(0, { $0 + $1.countActiveCells })
    }

    func needsExtensionInDirections() -> Set<GridExtensionDirection> {
        var needdeExtensions: [GridExtensionDirection] = []

        if let lastLayer = last, lastLayer.countActiveCells > 0 {
            needdeExtensions.append(.planeLast)
        }
        if let firstLayer = first, firstLayer.countActiveCells > 0 {
            needdeExtensions.append(.plane0)
        }

        let neededPlaneExtensions: Set<PlaneExtensionDirection> = self.reduce(Set(), {
            return $0.union($1.needsExtensionInDirections())
        })

        neededPlaneExtensions.forEach {
            needdeExtensions.append(.planeExtension($0))
        }

        return Set(needdeExtensions)
    }

    mutating func extendGrid(for directions: Set<GridExtensionDirection>) {
        for direction in directions {
            self.extendGrid(for: direction)
        }
    }

    mutating func extendGrid(for direction: GridExtensionDirection) {
        switch direction {
        case .plane0:
            insert(Plane(lines: self[0].count, columns: self[0][0].count), at: 0)
        case .planeLast:
            append(Plane(lines: self[0].count, columns: self[0][0].count))
        case let .planeExtension(planeExtension):
            self.indices.forEach {
                self[$0].extendsPlaneInDirection(planeExtension)
            }
        }
    }

    mutating func extendsIfActiveOnBorders() {
        extendGrid(for: needsExtensionInDirections())
    }

    func nextIteration() -> Grid {
        var nextGrid = self
        nextGrid.extendsIfActiveOnBorders()
        let baseGrid = nextGrid

        for height in baseGrid.indices {
            for line in baseGrid[height].indices {
                for column in baseGrid[height][line].indices {
                    let activeCount = baseGrid.countActiveNeighbours(column: column, line: line, height: height)
                    let isActive = baseGrid[height][line][column] == .active
                    if !isActive && activeCount == 3 {
                        nextGrid[height][line][column] = .active
                    } else if isActive && (activeCount == 2 || activeCount == 3) {
                        nextGrid[height][line][column] = .active
                    } else {
                        nextGrid[height][line][column] = .inactive
                    }
                }
            }
        }

        return nextGrid
    }

    func countActiveNeighbours(column: Int, line: Int, height: Int) -> Int {
        [-1, 0, 1]
            .map { height + $0 }
            .filter { self.indices.contains($0) }
            .map { planeHeight in
                let planeNeighbours = self[planeHeight].countActiveNeighbors(column: column, line: line)
                if planeHeight != height {
                    return planeNeighbours + (self[planeHeight][line][column] == .active ? 1 : 0)
                } else {
                    return planeNeighbours
                }
            }
            .reduce(0, (+))
    }
}
