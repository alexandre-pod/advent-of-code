import Foundation

func main() {
    let positions = readLine()!.split(separator: ",").map { Int($0)! }

    print(part1(positions: positions))
    print(part2(positions: positions))
}

typealias HorizontalPosition = Int

func part1(positions: [Int]) -> Int {

    var positionsDict: [HorizontalPosition: Int] = [:]
    positions.forEach {
        positionsDict[$0, default: 0] += 1
    }

    let minPosition = positions.min()!
    let maxPosition = positions.max()!

    let bestPosition = (minPosition...maxPosition)
        .map {
            ($0, costForGoingPart1(toPosition: $0, positions: positionsDict))
        }
        .min { $0.1 < $1.1 }

    return bestPosition!.1
}

func costForGoingPart1(toPosition targetPosition: Int, positions: [HorizontalPosition: Int]) -> Int {
    return positions.reduce(0) {
        $0 + abs($1.key - targetPosition) * $1.value
    }
}

func part2(positions: [Int]) -> Int {

    var positionsDict: [HorizontalPosition: Int] = [:]
    positions.forEach {
        positionsDict[$0, default: 0] += 1
    }

    let minPosition = positions.min()!
    let maxPosition = positions.max()!

    let bestPosition = (minPosition...maxPosition)
        .map {
            ($0, costForGoingPart2(toPosition: $0, positions: positionsDict))
        }
        .min { $0.1 < $1.1 }

    return bestPosition!.1
}

func costForGoingPart2(toPosition targetPosition: Int, positions: [HorizontalPosition: Int]) -> Int {
    return positions.reduce(0) {
        let travelDistance: Int = abs($1.key - targetPosition)
        let travelCost: Int = travelDistance * (travelDistance + 1) / 2
        return $0 + travelCost * $1.value
    }
}

main()
