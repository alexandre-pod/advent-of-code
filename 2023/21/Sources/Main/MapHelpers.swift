//
//  MapHelpers.swift
//  
//
//  Created by Alexandre Podlewski on 17/12/2023.
//

import Foundation

struct Coordinates: Hashable {
    let x: Int
    let y: Int
}

extension Array {
    subscript<T>(_ coordinates: Coordinates) -> T where Element == [T] {
        get { self[coordinates.y][coordinates.x] }
        set { self[coordinates.y][coordinates.x] = newValue }
    }

    func isValidCoordinates<T>(_ coordinates: Coordinates) -> Bool where Element == [T] {
        return indices.contains(coordinates.y)
        && self[coordinates.y].indices.contains(coordinates.x)
    }
}

enum Direction: Hashable, CaseIterable {
    case up
    case down
    case left
    case right
}

extension Coordinates {
    func apply(direction: Direction) -> Self {
        Coordinates(x: x + direction.offset.dx, y: y + direction.offset.dy)
    }
}

extension Direction {
    var offset: (dx: Int, dy: Int) {
        return switch self {
        case .up: (0, -1)
        case .down: (0, 1)
        case .left: (-1, 0)
        case .right: (1, 0)
        }
    }
}
