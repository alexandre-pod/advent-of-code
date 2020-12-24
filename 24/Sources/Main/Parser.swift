//
//  File.swift
//  
//
//  Created by Alexandre Podlewski on 24/12/2020.
//

import Foundation

func parseDirections(from line: String) -> [Direction] {
    var directions: [Direction] = []

    var substring = Substring(line)

    while let (direction, remainingString) = parseDirection(from: substring) {
        directions.append(direction)
        substring = remainingString
    }

    return directions
}

func parseDirection(from substring: Substring) -> (direction: Direction, remainingString: Substring)? {

    guard !substring.isEmpty else { return nil }

    let nextIndex = substring.index(after: substring.startIndex)
    if substring.starts(with: "e") {
        return (direction: .east, remainingString: substring[nextIndex...])
    } else if substring.starts(with: "w") {
        return (direction: .west, remainingString: substring[nextIndex...])
    }

    let next2Index = substring.index(after: nextIndex)
    if substring.starts(with: "se") {
        return (direction: .southEast, remainingString: substring[next2Index...])
    } else if substring.starts(with: "sw") {
        return (direction: .southWest, remainingString: substring[next2Index...])
    } else if substring.starts(with: "ne") {
        return (direction: .northEast, remainingString: substring[next2Index...])
    } else if substring.starts(with: "nw") {
        return (direction: .northWest, remainingString: substring[next2Index...])
    }

    fatalError()
}
