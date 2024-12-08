import Foundation

typealias AntennaMap = Grid2D<Character?>

func main() {
    var grid: [[Character?]] = []

    while let line = readLine() {
        grid.append(line.map { $0 == "." ? nil : $0 })
    }

    let input = AntennaMap(cells: grid)

    print(part1(antennaMap: input))
    print(part2(antennaMap: input))
}

// MARK: - Part 1

func part1(antennaMap: AntennaMap) -> Int {
    antennaMap.printDebug { $0 ?? "." }

    var antennasGroup: [Character: [Coordinate2D]] = [:]

    antennaMap.allCoordinates.forEach { coordinates in
        if let antenna = antennaMap[coordinates] {
            antennasGroup[antenna, default: []].append(coordinates)
        }
    }

    var antennaGroupAntiNodes: [Character: [Coordinate2D]] = [:]

    for (antennaType, positions) in antennasGroup {
        var antinodes: Set<Coordinate2D> = []
        for pair in positions.allPairs() {
            for antiNode in antiNodes(for: pair.0, and: pair.1) where antennaMap.contains(antiNode) {
                antinodes.insert(antiNode)
            }
        }
        antennaGroupAntiNodes[antennaType] = Array(antinodes)
    }

    let allAntiNodesPositions = antennaGroupAntiNodes.values.reduce(into: Set<Coordinate2D>()) { $0.formUnion($1) }

    return allAntiNodesPositions.count
}

func antiNodes(for p1: Coordinate2D, and p2: Coordinate2D) -> [Coordinate2D] {
    assert(p1 != p2)
    let difference = p2 - p1
    return [p2 + difference, p1 - difference]
}

extension Array {
    func allPairs() -> some Sequence<(Element, Element)> {
        return indices.dropLast().lazy.flatMap { i1 in
            ((i1+1)..<indices.upperBound).lazy.map { i2 in (self[i1], self[i2]) }
        }
    }
}

// MARK: - Part 2

func part2(antennaMap: AntennaMap) -> Int {
    antennaMap.printDebug { $0 ?? "." }

    var antennasGroup: [Character: [Coordinate2D]] = [:]

    antennaMap.allCoordinates.forEach { coordinates in
        if let antenna = antennaMap[coordinates] {
            antennasGroup[antenna, default: []].append(coordinates)
        }
    }

    var antennaGroupAntiNodes: [Character: [Coordinate2D]] = [:]

    for (antennaType, positions) in antennasGroup {
        //        print(antenna)
        //        print(Array(positions.allPairs()))
        var antinodes: Set<Coordinate2D> = []
        for pair in positions.allPairs() {
            for antiNode in resonantAntiNodes(for: pair.0, and: pair.1, in: antennaMap) {
                assert(antennaMap.contains(antiNode))
                antinodes.insert(antiNode)
            }
        }
        antennaGroupAntiNodes[antennaType] = Array(antinodes)
    }

    let allAntiNodesPositions = antennaGroupAntiNodes.values.reduce(into: Set<Coordinate2D>()) { $0.formUnion($1) }

    return allAntiNodesPositions.count
}

func resonantAntiNodes<T>(for p1: Coordinate2D, and p2: Coordinate2D, in grid: Grid2D<T>) -> [Coordinate2D] {
    assert(p1 != p2)
    var difference = p2 - p1
    let differencePGCD = pgcd(difference.x, b: difference.y)
    // We want the smallest step to be aligned with the two position
    difference.x /= differencePGCD
    difference.y /= differencePGCD

    var antiNodes: [Coordinate2D] = [p1, p2]
    var nextAntiNode = p2 + difference
    while grid.contains(nextAntiNode) {
        antiNodes.append(nextAntiNode)
        nextAntiNode += difference
    }
    nextAntiNode = p1 - difference
    while grid.contains(nextAntiNode) {
        antiNodes.append(nextAntiNode)
        nextAntiNode -= difference
    }
    return antiNodes
}

//func pgcd(_ a: Int, b: Int) -> Int {
//    if abs(a) == abs(b) { return abs(a) }
//    return (1...min(abs(a), abs(b))).last { a % $0 == 0 && b % $0 == 0 } ?? 1
//}

main()
