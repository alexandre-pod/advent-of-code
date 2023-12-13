import Foundation

typealias RockMap = [[Bool]]
typealias RockMaps = [RockMap]

func main() {
    var input: RockMaps = []

    var currentMap: RockMap = []
    while let line = readLine() {
        guard !line.isEmpty else {
            input.append(currentMap)
            currentMap = []
            continue
        }
        currentMap.append(line.map { $0 == "#" })
    }

    input.append(currentMap)

    print(part1(rockMaps: input))
    print(part2(rockMaps: input))
}

// MARK: - Part 1

func part1(rockMaps: RockMaps) -> Int {
//    rockMaps.forEach {
//        printRockMap($0)
//        print()
//    }

//    rockMaps.forEach {
//        print("===")
//        print(horizontalSymmetricAxis(in: $0))
//        print(verticalSymmetricAxis(in: $0))
//    }

    return rockMaps
        .map { symmetrySummary(for: $0) }
        .reduce(0, +)
}

func symmetrySummary(for rockMap: RockMap) -> Int {
    let horizontalAxis = (horizontalSymmetricAxis(in: rockMap) ?? -1) + 1
    let verticalAxis = (verticalSymmetricAxis(in: rockMap) ?? -1) + 1

    return verticalAxis + horizontalAxis * 100
}

func horizontalSymmetricAxis(in rockMap: RockMap) -> Int? {
    for horizontalAxis in 0..<(rockMap.count - 1) {

        let symmetricLines: [(Int, Int)] = (0...horizontalAxis)
            .map { ($0, 2 * horizontalAxis - $0 + 1) }
            .filter { $0.1 < rockMap.count }
        let isValid = symmetricLines
            .allSatisfy { rockMap[$0.0] == rockMap[$0.1] }
        if isValid {
            return horizontalAxis
        }
    }

    return nil
}

func verticalSymmetricAxis(in rockMap: RockMap) -> Int? {
    let transposedMap = rockMap[0].indices.map { x in rockMap.map { $0[x] } }
    return horizontalSymmetricAxis(in: transposedMap)
}

// MARK: - Part 2

func part2(rockMaps: RockMaps) -> Int {
    return rockMaps
        .map { symmetrySummaryWithOneError(for: $0) }
        .reduce(0, +)
}

func symmetrySummaryWithOneError(for rockMap: RockMap) -> Int {
    let horizontalAxis = (horizontalSymmetricAxisWithOneError(in: rockMap) ?? -1) + 1
    let verticalAxis = (verticalSymmetricAxisWithOneError(in: rockMap) ?? -1) + 1
    return verticalAxis + horizontalAxis * 100
}

func horizontalSymmetricAxisWithOneError(in rockMap: RockMap) -> Int? {
    for horizontalAxis in 0..<(rockMap.count - 1) {
        let symmetricLines: [(Int, Int)] = (0...horizontalAxis)
            .map { ($0, 2 * horizontalAxis - $0 + 1) }
            .filter { $0.1 < rockMap.count }
        let errors = symmetricLines
            .map { zip(rockMap[$0.0], rockMap[$0.1]).filter { $0.0 != $0.1 }.count }
            .reduce(0, +)
        if errors == 1 {
            return horizontalAxis
        }
    }
    return nil
}

func verticalSymmetricAxisWithOneError(in rockMap: RockMap) -> Int? {
    let transposedMap = rockMap[0].indices.map { x in rockMap.map { $0[x] } }
    return horizontalSymmetricAxisWithOneError(in: transposedMap)
}

// MARK: - Vizualisation

func printRockMap(_ map: RockMap) {
    map.forEach {
        printRockLine($0)
    }
}

func printRockLine(_ rockLine: [Bool]) {
    print(rockLine.map { $0 ? "#" : "." }.joined())
}

main()
