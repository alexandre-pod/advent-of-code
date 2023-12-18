//
//  Segment.swift
//  
//
//  Created by Alexandre Podlewski on 18/12/2023.
//

import Foundation

struct Segment {
    let minPoint: Coordinates
    let maxPoint: Coordinates

    init(_ point1: Coordinates, _ point2: Coordinates) {
        let minIsFirst = point1.y < point2.y || (point1.y == point2.y && point1.x < point2.x)
        self.minPoint = minIsFirst ? point1 : point2
        self.maxPoint = minIsFirst ? point2 : point1
    }
}

extension Segment {

    func intersectY(_ y: Int) -> Bool {
        return (minPoint.y...maxPoint.y).contains(y)
    }

    var isHorizontal: Bool {
        return minPoint.y == maxPoint.y
    }

    var minY: Int { minPoint.y }
    var maxY: Int { maxPoint.y }
    var minX: Int { min(minPoint.x, maxPoint.x) }
    var maxX: Int { max(minPoint.x, maxPoint.x) }
}
