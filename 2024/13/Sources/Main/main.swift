import Foundation

typealias MachineConfigs = [MachineConfig]

func main() {
    var input: MachineConfigs = []

    while let line = parseMachineConfig() {
        input.append(line)
    }

    print(part1(machines: input))
    print(part2(machines: input))
}

struct MachineConfig {
    let buttonAMove: Coordinate2D
    let buttonBMove: Coordinate2D
    let prizePosition: Coordinate2D
}

func parseMachineConfig() -> MachineConfig? {
    guard let buttonALine = readLine() else {
        return nil
    }
    let buttonBLine = readLine()!
    let prizeLine = readLine()!
    _ = readLine()

    let matchA = try! #/Button A: X\+(\d+), Y\+(\d+)/#.wholeMatch(in: buttonALine)!
    let matchB = try! #/Button B: X\+(\d+), Y\+(\d+)/#.wholeMatch(in: buttonBLine)!
    let prize = try! #/Prize: X=(\d+), Y=(\d+)/#.wholeMatch(in: prizeLine)!

    return MachineConfig(
        buttonAMove: Coordinate2D(x: Int(matchA.output.1)!, y: Int(matchA.output.2)!),
        buttonBMove: Coordinate2D(x: Int(matchB.output.1)!, y: Int(matchB.output.2)!),
        prizePosition: Coordinate2D(x: Int(prize.output.1)!, y: Int(prize.output.2)!)
    )
}

// MARK: - Part 1

func part1(machines: MachineConfigs) -> Int {
//    machines.forEach {
//        print($0)
//        print(minCostForPrice(of: $0))
//    }

    return machines
        .compactMap { minCostForPrice(of: $0) }
        .reduce(0, +)
}

let aCost = 3
let bCost = 1

func minCostForPrice(of machine: MachineConfig, aLimit: Int = 100) -> Int? {
    let xTarget = machine.prizePosition.x
    let yTarget = machine.prizePosition.y
    for aNumber in 0...aLimit {
        let xRemaining = xTarget - aNumber * machine.buttonAMove.x
        let yRemaining = yTarget - aNumber * machine.buttonAMove.y
        if xRemaining < 0 || yRemaining < 0 {
            return nil
        }
        if xRemaining == 0, yRemaining == 0 {
            return aCost * aNumber
        }

        if xRemaining.isMultiple(of: machine.buttonBMove.x),
           yRemaining.isMultiple(of: machine.buttonBMove.y) {
            let bNumber = xRemaining / machine.buttonBMove.x
            let bNumberForY = yRemaining / machine.buttonBMove.y

            if bNumber != bNumberForY { continue }

//            print("A: \(aNumber); B: \(bNumber)")
            return aCost * aNumber + bCost * bNumber
        }
    }

    return nil
}

// MARK: - Part 2

import simd

func part2(machines: MachineConfigs) -> Int {
    // Bruteforce not working
//    return machines
//        .map { $0.fixPrizePositionForPart2() }
//        .compactMap { minCostForPrice(of: $0, aLimit: Int.max) }
//        .reduce(0, +)

//    return machines
//        .map { $0.fixPrizePositionForPart2() }
//        .compactMap { minCostForPriceUsingSIMD(of: $0) }
//        .reduce(0, +)

    return machines
        .map { $0.fixPrizePositionForPart2() }
        .compactMap { minCostForPriceUsingIntOnly(of: $0) }
        .reduce(0, +)

}

private func minCostForPriceUsingSIMD(of machine: MachineConfig) -> Int? {
    let aVector = Vector2D(machine.buttonAMove)
    let bVector = Vector2D(machine.buttonBMove)
    let prizeVector = Vector2D(machine.prizePosition)
    let matrix1 = simd_double2x2(
        aVector,
        bVector
    )
    let inverseMatrix1 = matrix1.inverse
    let transformedCoordinates = inverseMatrix1 * prizeVector

    let aCount = Int(transformedCoordinates.x.rounded())
    let bCount = Int(transformedCoordinates.y.rounded())


    let aPart = aCount * machine.buttonAMove
    let bPart = bCount * machine.buttonBMove

    guard aPart + bPart == machine.prizePosition else { return nil }

    return aCount * aCost + bCount * bCost
}

private func minCostForPriceUsingIntOnly(of machine: MachineConfig) -> Int? {
    // matrix change from (0, 1) -> (1, 0)
    // |a c|   |x|   |x_2|           1 /    | d -c|   |x_2|   |x|
    // |b d| . |y| = |y_2|   <==>  ad - bc  |-b  a| . |y_2| = |y|
    // where x_2 and y_2 the coordinates of the price

    let a = machine.buttonAMove.x
    let b = machine.buttonAMove.y
    let c = machine.buttonBMove.x
    let d = machine.buttonBMove.y
    let x_2 = machine.prizePosition.x
    let y_2 = machine.prizePosition.y

    let divider = a * d - b * c
    guard divider != 0 else { return nil }

    let x =  d * x_2 - c * y_2
    let y = -b * x_2 + a * y_2

    guard x.isMultiple(of: divider),
          y.isMultiple(of: divider)
    else { return nil }

    let aCount = x / divider
    let bCount = y / divider

    return aCount * aCost + bCount * bCost
}

extension Coordinate2D {
    static func * (_ lhs: Int, _ rhs: Self) -> Coordinate2D {
        rhs * lhs
    }

    static func * (_ lhs: Self, _ rhs: Int) -> Coordinate2D {
        Coordinate2D(x: lhs.x * rhs, y: lhs.y * rhs)
    }
}

extension MachineConfig {
    func fixPrizePositionForPart2() -> Self {
        MachineConfig(
            buttonAMove: buttonAMove,
            buttonBMove: buttonBMove,
            prizePosition: Coordinate2D(
                x: prizePosition.x + 10_000_000_000_000,
                y: prizePosition.y + 10_000_000_000_000
            )
        )
    }
}

main()
