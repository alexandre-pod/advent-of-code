//
//  Plane.swift
//  
//
//  Created by Alexandre Podlewski on 17/12/2020.
//

import Foundation

typealias Plane = [[CellState]]

enum PlaneExtensionDirection: Hashable {
    case column0
    case columnLast
    case line0
    case lineLast
}

extension Plane {

    init(lines: Int, columns: Int) {
        let line: [CellState] = Swift.Array(repeating: .inactive, count: columns)
        self = Swift.Array(repeating: line, count: lines)
    }

    var countActiveCells: Int {
        return flatMap { $0.filter { $0 == .active } }.count
    }

    func countActiveNeighbors(column: Int, line: Int) -> Int {
        validCoordinatesAround(column: column, line: line)
            .filter { self[$0.line][$0.column] == .active }
            .count
    }

    func validCoordinatesAround(column: Int, line: Int) -> [(column: Int, line: Int)] {
        return Self.neighboursDirections
            .map { (column: column + $0.dx, line: line + $0.dy) }
            .filter { self.indices.contains($0.line) }
            .filter { self[0].indices.contains($0.column) }
    }

    static let neighboursDirections: [(dx: Int, dy: Int)] = [
        (dx: -1, dy: -1),
        (dx: -1, dy: 0),
        (dx: -1, dy: 1),
        (dx: 0, dy: -1),
        (dx: 0, dy: 1),
        (dx: 1, dy: -1),
        (dx: 1, dy: 0),
        (dx: 1, dy: 1)
    ]

    func haveActiveOnBorder() -> Bool {
        let lines = self.count
        let columns = self[0].count

        var bordersIndices: [(column: Int, line: Int)] = []
        bordersIndices.append(
            contentsOf: self.indices.flatMap { [(column: 0, line: $0), (column: columns - 1, line: $0)] }
        )
        bordersIndices.append(
            contentsOf: self[0].indices.flatMap { [(column: $0, line: 0), (column: $0, line: lines - 1)] }
        )
        return bordersIndices.contains { self[$0.line][$0.column] == .active }
    }

    func needsExtensionInDirections() -> Set<PlaneExtensionDirection> {
        let lines = self.count
        let columns = self[0].count

        var needdeExtensions: [PlaneExtensionDirection] = []

        if self.indices.map({ (column: 0, line: $0) })
            .contains(where: { self[$0.line][$0.column] == .active }) {
            needdeExtensions.append(.column0)
        }
        if columns > 0 && self.indices.map({ (column: columns - 1, line: $0) })
            .contains(where: { self[$0.line][$0.column] == .active }) {
            needdeExtensions.append(.columnLast)
        }

        if self[0].indices.map({ (column: $0, line: 0) })
            .contains(where: { self[$0.line][$0.column] == .active }) {
            needdeExtensions.append(.line0)
        }
        if lines > 0 && self[0].indices.map({ (column: $0, line: lines - 1) })
            .contains(where: { self[$0.line][$0.column] == .active }) {
            needdeExtensions.append(.lineLast)
        }

        return Set(needdeExtensions)
    }

    mutating func extendsPlaneInDirections(_ directions: Set<PlaneExtensionDirection>) {
        for direction in directions {
            self.extendsPlaneInDirection(direction)
        }
    }

    mutating func extendsPlaneInDirection(_ direction: PlaneExtensionDirection) {
        switch direction {
        case .column0:
            self = self.map { [.inactive] + $0 }
        case .columnLast:
            self = self.map { $0 + [.inactive] }
        case .line0:
            self.insert(Swift.Array(repeating: .inactive, count: self[0].count), at: 0)
        case .lineLast:
            self.insert(Swift.Array(repeating: .inactive, count: self[0].count), at: count)
        }
    }
}
