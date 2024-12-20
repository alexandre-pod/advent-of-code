import Foundation

struct InputType {
    var map: Grid2D<Bool>
    let start: Coordinate2D
    let end: Coordinate2D
}

func main() {
    var cells: [[Bool]] = []
    var start: Coordinate2D?
    var end: Coordinate2D?

    while let line = readLine() {
        let y = cells.count
        cells.append(line.map { $0 == "#" })
        if let startX = Array(line).firstIndex(of: "S") {
            start = Coordinate2D(x: startX, y: y)
        }
        if let endX = Array(line).firstIndex(of: "E") {
            end = Coordinate2D(x: endX, y: y)
        }
    }

    var input = InputType(
        map: Grid2D<Bool>(cells: cells),
        start: start!,
        end: end!
    )

    print(part1(inputParameter: input))
    print(part2(inputParameter: input))
}

// MARK: - Part 1

func part1(inputParameter: InputType) -> Int {
//    print(inputParameter)

    // Djikstra bruteforce
//        let baseDistance = pathDistance(in: inputParameter)!
//        var countReducingBy100 = 0
//        for wallPosition in inputParameter.map.allCoordinates.filter({ inputParameter.map[$0] }) {
//            var updatedInput = inputParameter
//            updatedInput.map[wallPosition] = false
//
//            let updatedDistance = pathDistance(in: updatedInput)!
//    //        if updatedDistance < baseDistance {
//    //            print("Gain :", baseDistance - updatedDistance)
//    //        }
//            if updatedDistance <= baseDistance - 100 {
//                countReducingBy100 += 1
//            }
//        }
//        return countReducingBy100

    var countReducingBy100 = 0

    var cheatDistance = 2
    let map = inputParameter.map

    let distanceFromEnd = distanceMap(from: inputParameter.end, to: inputParameter.start, in: map)
    let nonWallPositions = Set(map.allCoordinates.filter { !map[$0] })

    var cheatsCountPerGainedTime: [Int: Int] = [:]

    for startShortcut in nonWallPositions {
        for endShortcut in map.neighbours(around: startShortcut, inRadius: cheatDistance) {
            guard !map[endShortcut] else { continue }
            let costWithShortcut = distanceFromEnd[startShortcut]! + startShortcut.distance(to: endShortcut)
            let shortcutGain = distanceFromEnd[endShortcut]! - costWithShortcut
            guard shortcutGain > 0 else { continue }

            cheatsCountPerGainedTime[shortcutGain, default: 0] += 1
//            print(shortcutGain, "gained", "[\(startShortcut) - \(endShortcut)]")

            if shortcutGain >= 100 {
                countReducingBy100 += 1
            }
        }
    }

//    cheatsCountPerGainedTime.keys.sorted().forEach { key in
//        print(cheatsCountPerGainedTime[key, default: 0], "x -> gained:", key)
//    }

    return countReducingBy100
}

extension Grid2D {
    func neighbours(around position: Coordinate2D, inRadius radius: Int) -> some Sequence<Coordinate2D> {
        return position.neighbours(inRadius: radius).filter { contains($0) }
    }
}

extension Coordinate2D {
    func neighbours(inRadius radius: Int) -> some Sequence<Coordinate2D> {
        return (-radius...radius).lazy
            .flatMap { dy in
                let allowedXMovement = radius - abs(dy)
                return (-allowedXMovement...allowedXMovement).lazy.map { dx in
                    self.moved(by: Direction(deltaX: dx, deltaY: dy))
                }
            }
            .filter { $0 != self }
    }

    func distance(to position: Coordinate2D) -> Int {
        return abs(x - position.x) + abs(y - position.y)
    }
}

func pathDistance(in input: InputType) -> Int? {

    var visited: Set<Coordinate2D> = []
    var candidates: Set<Coordinate2D> = [input.start]

    var nodeCost: [Coordinate2D: Int] = [input.start: 0]
    var bestPathOrigin: [Coordinate2D: Coordinate2D] = [:]

    while let candidate = candidates.min(by: { nodeCost[$0]! < nodeCost[$1]! }) {
        candidates.remove(candidate)
        visited.insert(candidate)
        let currentCost = nodeCost[candidate]!

        for neighbour in input.map.cardinalNeighbours(to: candidate) {
            guard !input.map[neighbour] else { continue }
            let costFromCurrent = currentCost + 1
            if costFromCurrent < nodeCost[neighbour, default: .max] {
                nodeCost[neighbour] = costFromCurrent
                bestPathOrigin[neighbour] = candidate
                candidates.insert(neighbour)
            }
        }
    }

    return nodeCost[input.end]
}

// Djikstra
func distanceMap(from start: Coordinate2D, to end: Coordinate2D, in map: Grid2D<Bool>) -> [Coordinate2D: Int] {

    var visited: Set<Coordinate2D> = []
    var candidates: Set<Coordinate2D> = [start]

    var nodeCost: [Coordinate2D: Int] = [start: 0]
    var bestPathOrigin: [Coordinate2D: Coordinate2D] = [:]

    while let candidate = candidates.min(by: { nodeCost[$0]! < nodeCost[$1]! }) {
        candidates.remove(candidate)
        visited.insert(candidate)
        let currentCost = nodeCost[candidate]!

        for neighbour in map.cardinalNeighbours(to: candidate) {
            guard !map[neighbour] else { continue }
            let costFromCurrent = currentCost + 1
            if costFromCurrent < nodeCost[neighbour, default: .max] {
                nodeCost[neighbour] = costFromCurrent
                bestPathOrigin[neighbour] = candidate
                candidates.insert(neighbour)
            }
        }
    }

    return nodeCost
}

// MARK: - Part 2

func part2(inputParameter: InputType) -> Int {

    var countReducingBy100 = 0

    var cheatDistance = 20
    let map = inputParameter.map

    let distanceFromEnd = distanceMap(from: inputParameter.end, to: inputParameter.start, in: map)
    let nonWallPositions = Set(map.allCoordinates.filter { !map[$0] })

    var cheatsCountPerGainedTime: [Int: Int] = [:]

    for startShortcut in nonWallPositions {
        for endShortcut in map.neighbours(around: startShortcut, inRadius: cheatDistance) {
            guard !map[endShortcut] else { continue }
            let costWithShortcut = distanceFromEnd[startShortcut]! + startShortcut.distance(to: endShortcut)
            let shortcutGain = distanceFromEnd[endShortcut]! - costWithShortcut
            guard shortcutGain > 0 else { continue }

            if shortcutGain >= 50 {
                cheatsCountPerGainedTime[shortcutGain, default: 0] += 1
//                print(shortcutGain, "gained", "[\(startShortcut) - \(endShortcut)]")
            }

            if shortcutGain >= 100 {
                countReducingBy100 += 1
            }
        }
    }

//    cheatsCountPerGainedTime.keys.sorted().forEach { key in
//        print(cheatsCountPerGainedTime[key, default: 0], "x -> gained:", key)
//    }

    return countReducingBy100
}

main()
