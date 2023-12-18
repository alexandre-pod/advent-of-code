//
//  DisplayBuffer.swift
//  
//
//  Created by Alexandre Podlewski on 18/12/2023.
//

import Foundation

struct DisplayBuffer {
    var pixels: [Coordinates: Character] = [:]

    func print() {
        let minX = pixels.keys.map(\.x).min()!
        let maxX = pixels.keys.map(\.x).max()!
        let minY = pixels.keys.map(\.y).min()!
        let maxY = pixels.keys.map(\.y).max()!
        for y in minY...maxY {
            let line = (minX...maxX)
                .map { pixels[Coordinates(x: $0, y: y)] ?? "." }
                .map { String($0) }
                .joined()
            Swift.print(line)
        }
    }
}
