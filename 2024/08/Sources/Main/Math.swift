//
//  Math.swift
//  Main
//
//  Created by Alexandre Podlewski on 08/12/2024.
//

func pgcd(_ a: Int, b: Int) -> Int {
    // Euclid algorithm
    var a = abs(a)
    var b = abs(b)
    while b != 0 {
        (a, b) = (b, a % b)
    }
    return a
}
