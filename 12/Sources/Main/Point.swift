//
//  Point.swift
//  
//
//  Created by Alexandre Podlewski on 12/12/2020.
//

import Foundation

struct Point {
    let x: Double
    let y: Double

    static let zero = Point(x: 0, y: 0)
}

extension Point {

    init(x: Int, y: Int) {
        self.init(x: Double(x), y: Double(y))
    }

    func rotatedAroundZero(angle: Measurement<UnitAngle>) -> Self {
        return Point(
            angle: self.angle + angle,
            norm: norm
        )
    }

    var norm: Double {
        return sqrt(x * x + y * y)
    }

    var angle: Measurement<UnitAngle> {
        let norm = self.norm
        let angleFromCos = acos(x / norm)
        let angleFromSin = asin(-y / norm)
        if angleFromSin > 0 {
            return .radians(value: angleFromCos)
        } else {
            return .radians(value: -angleFromCos)
        }
    }

    init(angle: Measurement<UnitAngle>, norm: Double) {
        let radiantAngle = angle.converted(to: .radians).value
        let cosAngle = cos(radiantAngle)
        let sinAngle = sin(radiantAngle)
        self.init(
            x: (norm * cosAngle).rounded(),
            y: (norm * -sinAngle).rounded()
        )
    }

    static func -(lhs: Point, rhs: Point) -> Point {
        Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func +(lhs: Point, rhs: Point) -> Point {
        Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func *(lhs: Point, rhs: Double) -> Point {
        Point(x: lhs.x * rhs, y: lhs.y * rhs)
    }
}
