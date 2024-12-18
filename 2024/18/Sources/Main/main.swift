import Foundation

func main() {
    var positions: [Coordinate2D] = []

    while let line = readLine() {
        let pos = line.split(separator: ",").map { Int($0)! }
        positions.append(Coordinate2D(x: pos[0], y: pos[1]))

    }

    print(part1(positions: positions))
    print(part2(positions: positions))
}

// MARK: - Part 1

func part1(positions: [Coordinate2D]) -> Int {

//    let positions = positions[...11]
    let positions = positions.count == 25 ? positions[...11] : positions[..<1024]
    var map = Grid2D(
        defaultValue: false,
        width: positions.map(\.x).max()! + 1,
        height: positions.map(\.y).max()! + 1
    )
    for position in positions {
        map[position] = true
    }

//    print(positions.sorted(by: { ($0.x, $0.y) < ($1.x, $1.y) }))
//    map.printDebug { $0 ? "#" : "." }

    let startNode = Coordinate2D(x: 0, y: 0)
    let endNode = Coordinate2D(x: map.width - 1, y: map.height - 1)
    let (cost, path) = getPath(from: startNode, to: endNode, in: map)!

    let pathSet = Set(path)

//    map.map { position, isWall -> Character in
//        if isWall {
//            return "█"
//        } else {
//            return pathSet.contains(position) ? "O" : " "
//        }
//    }.printDebug(celltoCharacter: \.self)

    return cost
}

func getPath(from startNode: Coordinate2D, to endNode: Coordinate2D, in map: Grid2D<Bool>) -> (cost: Int, path: [Coordinate2D])? {
    var visited: Set<Coordinate2D> = []
    var candidates: Set<Coordinate2D> = [startNode]

    var costGrid: [Coordinate2D: Int] = [:]
    var bestMoveSource: [Coordinate2D: Coordinate2D] = [:]

    costGrid[startNode] = 0


    while let candidate = candidates.min(by: { costGrid[$0]! < costGrid[$1]! }) {
        candidates.remove(candidate)
        visited.insert(candidate)

        let currentCost = costGrid[candidate]!

        for otherNode in map.cardinalNeighbours(to: candidate) {
            if map[otherNode] == true { continue }
            if visited.contains(otherNode) { continue }

            let otherCostFromCandidate = currentCost + 1 // currentCost + edgeCost[edge]!
            if otherCostFromCandidate < costGrid[otherNode, default: .max] {
                costGrid[otherNode] = otherCostFromCandidate
                bestMoveSource[otherNode] = candidate
                candidates.insert(otherNode)
            }
        }
    }

    guard let cost = costGrid[endNode] else {
        return nil
    }

    return (cost: cost, path: Array(sequence(first: endNode, next: { bestMoveSource[$0] })))
}

// MARK: - Part 2

func part2(positions: [Coordinate2D]) -> String {

    var possibleNumber = 1
    var impossibleNumber = positions.count

    while possibleNumber + 1 < impossibleNumber {
//        print(possibleNumber, impossibleNumber)
        let midPoint = (possibleNumber + impossibleNumber) / 2
        if canGoToEnd(withBytesNumber: midPoint, of: positions) {
            possibleNumber = midPoint
        } else {
            impossibleNumber = midPoint
        }
    }
//    print("final", possibleNumber, impossibleNumber)

    let blockingByte = positions[impossibleNumber - 1]

    // print final path
//    let positions = positions[..<(impossibleNumber - 1)]
//    var map = Grid2D(
//        defaultValue: false,
//        width: positions.map(\.x).max()! + 1,
//        height: positions.map(\.y).max()! + 1
//    )
//    for position in positions {
//        map[position] = true
//    }
//    let startNode = Coordinate2D(x: 0, y: 0)
//    let endNode = Coordinate2D(x: map.width - 1, y: map.height - 1)
//    let (cost, path) = getPath(from: startNode, to: endNode, in: map)!
//
//    let pathSet = Set(path)
//
//    map.map { position, isWall -> Character in
//        if isWall {
//            return "█"
//        } else {
//            return pathSet.contains(position) ? "O" : " "
//        }
//    }.printDebug(celltoCharacter: \.self)

    return "\(blockingByte.x),\(blockingByte.y)"
}

func canGoToEnd(withBytesNumber: Int, of positions: [Coordinate2D]) -> Bool {
    let positions = positions[..<withBytesNumber]
    var map = Grid2D(
        defaultValue: false,
        width: positions.map(\.x).max()! + 1,
        height: positions.map(\.y).max()! + 1
    )
    for position in positions {
        map[position] = true
    }

    let startNode = Coordinate2D(x: 0, y: 0)
    let endNode = Coordinate2D(x: map.width - 1, y: map.height - 1)
    return getPath(from: startNode, to: endNode, in: map) != nil
}

main()
