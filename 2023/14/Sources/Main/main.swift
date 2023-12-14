import Foundation

typealias Map = [[Rock?]]

enum Rock: Character {
    case round = "O"
    case square = "#"
}

func main() {
    var input: Map = []

    while let line = readLine() {
        input.append(line.map { Rock(rawValue: $0) })
    }

    print(part1(map: input))
    print(part2(map: input))
}

// MARK: - Part 1

func part1(map: Map) -> Int {
    let tiltedMap = map.rolledNorth
    return tiltedMap.northWeight
}

extension [[Rock?]] {
    var rolledNorth: [[Rock?]] {
        var tiltedMap = self

        var rollingSpot = Swift.Array(repeating: 0, count: self[0].count)

        for y in tiltedMap.indices {
            for x in tiltedMap[y].indices {
                let rock = tiltedMap[y][x]
                if rock == .round {
                    tiltedMap[y][x] = nil
                    tiltedMap[rollingSpot[x]][x] = .round
                    rollingSpot[x] += 1
                } else if rock == .square {
                    rollingSpot[x] = y + 1
                }
            }
        }

        return tiltedMap
    }

    var rotatedClockwise: [[Rock?]] {
        var copy = self
        let width = self[0].count
        let height = self.count
        for y in self.indices {
            for x in self[y].indices {
                copy[x][width - y - 1] = self[y][x]
            }
        }
        return copy
    }

    var northWeight: Int {
        let roundCountPerLine = self.map { $0.reduce(0) { $0 + ($1 == .round ? 1 : 0) } }
        return zip(roundCountPerLine.reversed(), 1...roundCountPerLine.count).map { $0.0 * $0.1 }.reduce(0, +)
    }
}

// MARK: - Part 2

func part2(map: Map) -> Int {
    var iteration = 0
    var currentMap = map

    var mapHistory: [Map: Int] = [:]

    let iterationTarget = 1_000_000_000

    while iteration < iterationTarget {
        currentMap = currentMap.cycled
        iteration += 1
        if let lastSeenAtIteration = mapHistory[currentMap] {
            let cycle = iteration - lastSeenAtIteration
            let remainingIterations = iterationTarget - iteration
            iteration += remainingIterations - (remainingIterations % cycle)
        }
        mapHistory[currentMap] = iteration
//        print(iteration, currentMap.northWeight)
    }

    return currentMap.northWeight
}

extension [[Rock?]] {
    var cycled: Self {
        var copy = self

        copy = copy.rolledNorth
        copy = copy.rotatedClockwise
        copy = copy.rolledNorth
        copy = copy.rotatedClockwise
        copy = copy.rolledNorth
        copy = copy.rotatedClockwise
        copy = copy.rolledNorth
        copy = copy.rotatedClockwise

        return copy
    }
}

// MARK: - Visualisation

extension [[Rock?]] {
    func display() {
        forEach {
            print(String($0.map { $0?.rawValue ?? "." }))
        }
        print()
    }
}

main()
