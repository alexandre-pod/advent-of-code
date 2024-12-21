import Foundation

typealias InputType = [String]

func main() {
    var input: InputType = []

    while let line = readLine() {
        input.append(line)
    }

    print(part1(codes: input))
    print(part2(codes: input))
}

// MARK: - Part 1

func part1(codes: InputType) -> Int {

    return codes.map { code in
        let keys = Array(code)
        var cache: [CacheKey: Int] = [:]
        let inputCountForHuman = directionKeyboardKeysCountToEnterKeys(keys, intermediateRobots: 3, isDoorCode: true, cache: &cache)

        return inputCountForHuman * Int(String(code.dropLast()))!
    }.reduce(0, +)
}

// MARK: - Part 2

func part2(codes: InputType) -> Int {

    var result = 0

    for code in codes {
        let keys = Array(code)
//        print("----", code)

        var cache: [CacheKey: Int] = [:]

//        let directInput = directionKeyboardKeysCountToEnterKeys(keys, intermediateRobots: 0, isDoorCode: true, cache: &cache)
//        cache = [:]
//        print(directInput)
//        let inputForRobot1 = directionKeyboardKeysCountToEnterKeys(keys, intermediateRobots: 1, isDoorCode: true, cache: &cache)
//        cache = [:]
//        print(inputForRobot1)
//        let inputForRobot2 = directionKeyboardKeysCountToEnterKeys(keys, intermediateRobots: 2, isDoorCode: true, cache: &cache)
//        cache = [:]
//        print(inputForRobot2)

        // Gives the rame response than part 1
        // 3 = 2 (robot) + 1 (human)
//        let inputCountForHuman = directionKeyboardKeysCountToEnterKeys(keys, intermediateRobots: 3, isDoorCode: true, cache: &cache)
//        print(inputCountForHuman)

        // 26 = + 25 (robot) + 1 (human)
        let inputCountForHuman = directionKeyboardKeysCountToEnterKeys(keys, intermediateRobots: 26, isDoorCode: true, cache: &cache)
//        print(inputCountForHuman)

        result += inputCountForHuman * Int(String(code.dropLast()))!
    }

    return result

    // Sample input answers
    // '029A': 82050061710 * 29
    // '980A': 72242026390 * 980
    // '179A': 81251039228 * 179
    // '456A': 80786362258 * 456
    // '379A': 77985628636 * 379
    // result: 154115708116294
}

main()

// MARK: - Common

struct CacheKey: Hashable {
    let keys: [Character]
    let isDoorCode: Bool
    let intermediateRobots: Int
}

func directionKeyboardKeysCountToEnterKeys(
    _ keys: [Character],
    intermediateRobots: Int,
    isDoorCode: Bool,
    cache: inout [CacheKey: Int]
) -> Int {
    if intermediateRobots == 0 {
        // we are directly tapping the keys, so the answer if the number of keys
        return keys.count
    }

    let key = CacheKey(
        keys: keys,
        isDoorCode: isDoorCode,
        intermediateRobots: intermediateRobots
    )
    if let value = cache[key] {
        return value
    }

    if isDoorCode {
        var finalKeysCount = 0
        var robotPosition: Character = "A"
        for key in keys {
            let possibleMovesIncludingA = allMovementsForCode(from: robotPosition, to: key).map { $0 + ["A"] }
            robotPosition = key

            // `possibleMovesIncludingA` represent the action robot2 should enter to have robot1 enter `letter`
            // at the start and end of `movementsAndInput` all robots are on A (because start or all of them pressing A)

            finalKeysCount += possibleMovesIncludingA
                .map { move in
                    directionKeyboardKeysCountToEnterKeys(
                        move,
                        intermediateRobots: intermediateRobots - 1,
                        isDoorCode: false,
                        cache: &cache
                    )
                }
                .min()!
        }

        cache[key] = finalKeysCount
        return finalKeysCount
    } else {
        var finalKeysCount = 0
        var robotPosition: Character = "A"
        for key in keys {
            let possibleMovesIncludingA = allMovementsForInstructions(from: robotPosition, to: key).map { $0 + ["A"] }
            robotPosition = key

            // `possibleMovesIncludingA` represent the action robot2 should enter to have robot1 enter `letter`
            // at the start and end of `movementsAndInput` all robots are on A (because start or all of them pressing A)

            finalKeysCount += possibleMovesIncludingA
                .map { move in
                    directionKeyboardKeysCountToEnterKeys(
                        move,
                        intermediateRobots: intermediateRobots - 1,
                        isDoorCode: false,
                        cache: &cache
                    )
                }
                .min()!
        }

        cache[key] = finalKeysCount
        return finalKeysCount
    }
}

func allMovementsForCode(from start: Character, to end: Character) -> [[Character]] {
    let startPosition = codePosition(for: start)
    let endPosition = codePosition(for: end)
    var validMovements: [[Character]] = []

    let horizontalMovements: [Character] = startPosition.x < endPosition.x
    ? Array(repeating: ">", count: endPosition.x - startPosition.x)
    : Array(repeating: "<", count: startPosition.x - endPosition.x)
    let verticalMovements: [Character] = startPosition.y < endPosition.y
    ? Array(repeating: "v", count: endPosition.y - startPosition.y)
    : Array(repeating: "^", count: startPosition.y - endPosition.y)

    validMovements = allCombinationMixing(horizontalMovements, verticalMovements)
        .filter { moves in
            var currentPosition = startPosition
            for move in moves {
                switch move {
                case "A": break
                case "<": currentPosition.x -= 1
                case ">": currentPosition.x += 1
                case "^": currentPosition.y -= 1
                case "v": currentPosition.y += 1
                default: fatalError()
                }
                if currentPosition.x == 0, currentPosition.y == 3 {
                    return false
                }
            }
            return true
        }
    return validMovements
}

func allMovementsForInstructions(from start: Character, to end: Character) -> [[Character]] {
    let startPosition = instructionPosition(for: start)
    let endPosition = instructionPosition(for: end)
    var validMovements: [[Character]] = []

    let horizontalMovements: [Character] = startPosition.x < endPosition.x
    ? Array(repeating: ">", count: endPosition.x - startPosition.x)
    : Array(repeating: "<", count: startPosition.x - endPosition.x)
    let verticalMovements: [Character] = startPosition.y < endPosition.y
    ? Array(repeating: "v", count: endPosition.y - startPosition.y)
    : Array(repeating: "^", count: startPosition.y - endPosition.y)

    validMovements = allCombinationMixing(horizontalMovements, verticalMovements)
        .filter { moves in
            var currentPosition = startPosition
            for move in moves {
                switch move {
                case "A": break
                case "<": currentPosition.x -= 1
                case ">": currentPosition.x += 1
                case "^": currentPosition.y -= 1
                case "v": currentPosition.y += 1
                default: fatalError()
                }
                if currentPosition.x == 0, currentPosition.y == 0 {
                    return false
                }
            }
            return true
        }
    return validMovements
}

func allCombinationMixing(_ part1: [Character], _ part2: [Character]) -> [[Character]] {
    guard !part1.isEmpty else { return [part2] }
    guard !part2.isEmpty else { return [part1] }
    return [
        allCombinationMixing(Array(part1.dropFirst()), part2).map { [part1[0]] + $0 },
        allCombinationMixing(part1, Array(part2.dropFirst())).map { [part2[0]] + $0 }
    ].flatMap { $0 }
}

func codePosition(for code: Character) -> SIMD2<Int> {
    return switch code {
    case "9": SIMD2(x: 2, y: 0)
    case "8": SIMD2(x: 1, y: 0)
    case "7": SIMD2(x: 0, y: 0)
    case "6": SIMD2(x: 2, y: 1)
    case "5": SIMD2(x: 1, y: 1)
    case "4": SIMD2(x: 0, y: 1)
    case "3": SIMD2(x: 2, y: 2)
    case "2": SIMD2(x: 1, y: 2)
    case "1": SIMD2(x: 0, y: 2)
    case "0": SIMD2(x: 1, y: 3)
    case "A": SIMD2(x: 2, y: 3)
    default: fatalError()
    }
}

func instructionPosition(for code: Character) -> SIMD2<Int> {
    return switch code {
    case "^": SIMD2(x: 1, y: 0)
    case "A": SIMD2(x: 2, y: 0)
    case "<": SIMD2(x: 0, y: 1)
    case "v": SIMD2(x: 1, y: 1)
    case ">": SIMD2(x: 2, y: 1)
    default: fatalError()
    }
}

