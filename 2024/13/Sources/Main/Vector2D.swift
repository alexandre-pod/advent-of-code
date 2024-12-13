//
//  Untitled.swift
//  Main
//
//  Created by Alexandre Podlewski on 13/12/2024.
//

import simd

typealias Vector2D = SIMD2<Double>

extension Vector2D {
    var norm: Double {
        sqrt(pow(self.x, 2) + pow(self.y, 2))
    }

    var normalized: Vector2D {
        return self / norm
    }

    func scalarProduct(with vector: Self) -> Double {
        return x * vector.x + y * vector.y
    }
}


extension Vector2D {
    init(_ position: Coordinate2D) {
        self.init(x: Double(position.x), y: Double(position.y))
    }
}
