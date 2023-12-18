//
//  Coordinates+Utils.swift
//  
//
//  Created by Alexandre Podlewski on 18/12/2023.
//

import Foundation

extension Coordinates {
    func applying(_ direction: Direction, length: Int) -> Coordinates {
        Coordinates(
            x: x + direction.offset.dx * length,
            y: y + direction.offset.dy * length
        )
    }
}
