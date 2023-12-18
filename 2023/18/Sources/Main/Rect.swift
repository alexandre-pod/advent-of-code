//
//  Rect.swift
//  
//
//  Created by Alexandre Podlewski on 18/12/2023.
//

import Foundation

struct Rect: Equatable {
    let start: Coordinates
    let width: Int
    let height: Int
}

extension Rect {

    var minX: Int { start.x }
    var maxX: Int { start.x + width - 1 }
    var minY: Int { start.y }
    var maxY: Int { start.y + height - 1 }

    func intersection(with other: Rect) -> Rect? {
        if other.maxX < minX || other.minX > maxX || other.maxY < minY || other.minY > maxY {
            return nil
        }

        let minX = max(minX, other.minX)
        let maxX = min(maxX, other.maxX)
        let minY = max(minY, other.minY)
        let maxY = min(maxY, other.maxY)

        return Rect(
            start: Coordinates(x: minX, y: minY),
            width: maxX - minX + 1,
            height: maxY - minY + 1
        )
    }
}
