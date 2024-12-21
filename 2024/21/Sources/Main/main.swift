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
        print("====", code)
        // code // numeric keypad
        // 1st robot directional keypad
        let instructionForCode = String(instructionsToCreate(code: code))
        print(instructionForCode)
        // 2st robot directional keypad
        let instruction2ForCode = String(instructionsToCreate(instructions: instructionForCode))
        print(instruction2ForCode)
        // human directional keypad
        let instruction3ForCode = String(instructionsToCreate(instructions: instruction2ForCode))
        print(instruction3ForCode)
        let shortestSequenceCount = instruction3ForCode.count
        print(shortestSequenceCount, Int(String(code.dropLast()))!)
        return shortestSequenceCount * Int(String(code.dropLast()))!
    }.reduce(0, +)

    // 159082 too high
    // 152158 too low
    // 153902 too high
    // 152942 <- Valid !

}

// attempt 1

func instructionsToCreate(code: String) -> [Character] {
    instructionsToCreate(code: Array(code))
}

func instructionsToCreate(code: [Character]) -> [Character] {
    var movements: [Character] = []
    var currentPosition: Character = "A"
    for character in code {
        movements.append(contentsOf: movementsForCode(from: currentPosition, to: character))
        currentPosition = character
        movements.append("A")
    }
    return movements
}

//func movementsForCode(from start: Character, to end: Character) -> [Character] {
//    let startPosition = codePosition(for: start)
//    let endPosition = codePosition(for: end)
//    var movements: [Character] = []
//    var currentPosition = startPosition
//
//    if currentPosition.y == 3, endPosition.y != 3 {
//        let dy = endPosition.y < currentPosition.y ? -1 : 1
//        while currentPosition.y != endPosition.y {
//            currentPosition.y += dy
//            movements.append(dy > 0 ? "v" : "^")
//        }
//    }
//
//    let dx = endPosition.x < currentPosition.x ? -1 : 1
//    while currentPosition.x != endPosition.x {
//        currentPosition.x += dx
//        movements.append(dx > 0 ? ">" : "<")
//    }
//    let dy = endPosition.y < currentPosition.y ? -1 : 1
//    while currentPosition.y != endPosition.y {
//        currentPosition.y += dy
//        movements.append(dy > 0 ? "v" : "^")
//    }
//
//    return movements
//}

func movementsForCode(from start: Character, to end: Character) -> [Character] {
    let startPosition = codePosition(for: start)
    let endPosition = codePosition(for: end)
    var movements: [Character] = []
    var currentPosition = startPosition

    // we prefer to do those actions in this order < v > ^ (because < and v are far from A)

    // but if we need to to ^/v to prevent empty spot, we do them in priority
    // we repeat same key a maximum number of time (reduce number of action on the robot controling the actions)

    if currentPosition.y == 3, endPosition.y != 3, endPosition.x == 0 {
        while currentPosition.y > endPosition.y {
            currentPosition.y -= 1
            movements.append("^")
        }
    }

    if currentPosition.y != 3, endPosition.y == 3, currentPosition.x == 0 {
        while currentPosition.x < endPosition.x {
            currentPosition.x += 1
            movements.append(">")
        }
    }

    while currentPosition.x > endPosition.x {
        currentPosition.x -= 1
        movements.append("<")
    }
    while currentPosition.y < endPosition.y {
        currentPosition.y += 1
        movements.append("v")
    }
    while currentPosition.x < endPosition.x {
        currentPosition.x += 1
        movements.append(">")
    }
    while currentPosition.y > endPosition.y {
        currentPosition.y -= 1
        movements.append("^")
    }
    return movements
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

//var instructionsCache: [Never: Int] = [:]

func instructionsToCreate(instructions: String, from startPosition: Character = "A") -> [Character] {
    var movements: [Character] = []
    var currentPosition: Character = startPosition
    for character in instructions {
        movements.append(contentsOf: movementsForInstructions(from: currentPosition, to: character))
        currentPosition = character
        movements.append("A")
    }
    return movements
}

//func movementsForInstructions(from start: Character, to end: Character) -> [Character] {
//    let startPosition = instructionPosition(for: start)
//    let endPosition = instructionPosition(for: end)
//    var movements: [Character] = []
//    var currentPosition = startPosition
//
//    if currentPosition.y == 0, endPosition.y != 0 {
//        currentPosition.y += 1
//        movements.append("v")
//    }
//    if currentPosition.x > 0, currentPosition.y != endPosition.y {
//        currentPosition.y -= 1
//        movements.append("^")
//    }
//
//    let dx = endPosition.x < currentPosition.x ? -1 : 1
//    while currentPosition.x != endPosition.x {
//        currentPosition.x += dx
//        movements.append(dx > 0 ? ">" : "<")
//    }
//    let dy = endPosition.y < currentPosition.y ? -1 : 1
//    while currentPosition.y != endPosition.y {
//        currentPosition.y += dy
//        movements.append(dy > 0 ? "v" : "^")
//    }
//
//    return movements
//}

func movementsForInstructions(from start: Character, to end: Character) -> [Character] {
    let startPosition = instructionPosition(for: start)
    let endPosition = instructionPosition(for: end)
    var movements: [Character] = []
    var currentPosition = startPosition

    if currentPosition.y == 0, endPosition.y != 0, endPosition.x == 0 {
        currentPosition.y += 1
        movements.append("v")
    }
    while currentPosition.x > endPosition.x {
        currentPosition.x -= 1
        movements.append("<")
    }
    while currentPosition.y < endPosition.y {
        currentPosition.y += 1
        movements.append("v")
    }
    while currentPosition.x < endPosition.x {
        currentPosition.x += 1
        movements.append(">")
    }
    while currentPosition.y > endPosition.y {
        currentPosition.y -= 1
        movements.append("^")
    }
    return movements
}

//    func movementsForInstructions(from start: Character, to end: Character) -> [Character] {
//        guard start != end else { return [] }
//
//        switch (start, end) {
//        case ("A", "^"): return ["<"]
//        case ("A", ">"): return ["v"]
//        case ("A", "v"): return ["v", "<"]
//        case ("A", "<"): return ["v", "<", "<"]
//        case ("^", "A"): return [">"]
//        case ("^", ">"): return ["v", ">"]
//        case ("^", "v"): return ["v"]
//        case ("^", "<"): return ["v", "<"]
//        case (">", "A"): return ["^"]
//        case (">", "^"): return ["<", "^"]
//        case (">", "<"): return ["<", "<"]
//        case (">", "v"): return ["<"]
//        case ("v", "A"): return ["^", ">"]
//        case ("v", "^"): return ["^"]
//        case ("v", "<"): return ["<"]
//        case ("v", ">"): return [">"]
//        case ("<", "A"): return [">", ">", "^"]
//        case ("<", "^"): return [">", "^"]
//        case ("<", ">"): return [">", ">"]
//        case ("<", "v"): return [">"]
//        default: fatalError()
//        }
//    }

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

// MARK: - Part 2

func part2(codes: InputType) -> Int {

//    let aaaa = allInstructionsCombinationsToCreate(code: "029A")
//    print(aaaa)
//    print(aaaa.listKeyValidInputs.map { String($0) })
//
//    fatalError()

    var result = 0

    for code in codes {
        let keys = Array(code)
        print("----", code)

        var cache: [CacheKey: Int] = [:]

        let directInput = directionKeyboardKeysCountToEnterKeys(keys, intermediateRobots: 0, isDoorCode: true, cache: &cache)
        cache = [:]
//        print(directInput)
        let inputForRobot1 = directionKeyboardKeysCountToEnterKeys(keys, intermediateRobots: 1, isDoorCode: true, cache: &cache)
        cache = [:]
//        print(inputForRobot1)
        let inputForRobot2 = directionKeyboardKeysCountToEnterKeys(keys, intermediateRobots: 2, isDoorCode: true, cache: &cache)
        cache = [:]
//        print(inputForRobot2)

        // Gives the rame response than part 1
        // 3 = 2 (robot) + 1 (human)
//        let inputForHuman = directionKeyboardKeysCountToEnterKeys(keys, intermediateRobots: 3, isDoorCode: true, cache: &cache)
//        print(inputForHuman)

        // 26 = + 25 (robot) + 1 (human)
        let inputForHuman = directionKeyboardKeysCountToEnterKeys(keys, intermediateRobots: 26, isDoorCode: true, cache: &cache)
        print(inputForHuman)

        result += inputForHuman * Int(String(code.dropLast()))!
    }

    return result

    // Sample answers
    // '029A': 82050061710 * 29
    // '980A': 72242026390 * 980
    // '179A': 81251039228 * 179
    // '456A': 80786362258 * 456
    // '379A': 77985628636 * 379
    // result: 154115708116294


    fatalError()
//        return codes.map { code in
//            print("====", code)
//            // code // numeric keypad
//            // 1st robot directional keypad
//            var instructionForCode = String(instructionsToCreate(code: code))
//    //        print(instructionForCode)
//            for i in 1...25 {
//                print(i, instructionForCode.count)
//                instructionForCode = String(instructionsToCreate(instructions: instructionForCode))
//            }
//            // 2st robot directional keypad
//    //        let instruction2ForCode = String(instructionsToCreate(instructions: instructionForCode))
//    //        print(instruction2ForCode)
//    //        // human directional keypad
//    //        let instruction3ForCode = String(instructionsToCreate(instructions: instruction2ForCode))
//    //        print(instruction3ForCode)
//            let shortestSequenceCount = instructionForCode.count
//    //        print(shortestSequenceCount, Int(String(code.dropLast()))!)
//            return shortestSequenceCount * Int(String(code.dropLast()))!
//        }.reduce(0, +)
}

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
//            let movementsAndInput = movementsForCode(from: robotPosition, to: key) + ["A"]
            let possibleMoves = allMovementsForCode(from: robotPosition, to: key).map { $0 + ["A"] }
            robotPosition = key

            // `movementsAndInput` represent the action robot2 should enter to have robot1 enter `letter`
            // at the start and end of `movementsAndInput` all robots are on A (because start or all of them pressing A)

            finalKeysCount += possibleMoves
                .map { move in
                    directionKeyboardKeysCountToEnterKeys(
                        move,
                        intermediateRobots: intermediateRobots - 1,
                        isDoorCode: false,
                        cache: &cache
                    )
                }
                .min()!

//            finalKeysCount += directionKeyboardKeysCountToEnterKeys(
//                movementsAndInput,
//                intermediateRobots: intermediateRobots - 1,
//                isDoorCode: false,
//                cache: &cache
//            )
        }

        cache[key] = finalKeysCount
        return finalKeysCount
    } else {
        var finalKeysCount = 0
        var robotPosition: Character = "A"
        for key in keys {
//            let movementsAndInput = movementsForInstructions(from: robotPosition, to: key) + ["A"]
            let possibleMoves = allMovementsForInstructions(from: robotPosition, to: key).map { $0 + ["A"] }
            robotPosition = key

            // `movementsAndInput` represent the action robot2 should enter to have robot1 enter `letter`
            // at the start and end of `movementsAndInput` all robots are on A (because start or all of them pressing A)

            finalKeysCount += possibleMoves
                .map { move in
                    directionKeyboardKeysCountToEnterKeys(
                        move,
                        intermediateRobots: intermediateRobots - 1,
                        isDoorCode: false,
                        cache: &cache
                    )
                }
                .min()!

//            finalKeysCount += directionKeyboardKeysCountToEnterKeys(
//                movementsAndInput,
//                intermediateRobots: intermediateRobots - 1,
//                isDoorCode: false,
//                cache: &cache
//            )
        }

        cache[key] = finalKeysCount
        return finalKeysCount
    }

    fatalError()
}


main()

//    correct 456A:
//    <v<A>>^AA<vA<A>>^AAvAA<^A>A<vA>^A<A>A<vA>^A<A>A<v<A>A>^AAvA<^A>A
//    mine:
//    v<<A>>^Av<A<A>>^AAvA<^A>AvA^Av<A>^A<A>Av<A>^A<A>Av<A<A>>^AAvA<^A>A

// MARK: - Exhaustive instructions

typealias Instructions = [Character]
typealias InstructionsAlternatives = [[Character]]
typealias InstructionsCombinations = [InstructionsAlternatives]

func allInstructionsCombinationsToCreate(code: String) -> InstructionsCombinations {
    var movementPossibilities: InstructionsCombinations = []
    var currentPosition: Character = "A"
    for character in code {
        movementPossibilities.append(allMovementsForCode(from: currentPosition, to: character))
        currentPosition = character
        movementPossibilities.append([["A"]])
    }
    return movementPossibilities
}

extension InstructionsCombinations {
    var listKeyValidInputs: [[Character]] {
        var validKeys: [[Character]] = []

        for alternative in self {
            if validKeys.isEmpty {
                validKeys = alternative
            } else {
                let beforeValidKeys = validKeys
                validKeys = alternative.flatMap { addition in
                    beforeValidKeys.map { $0 + addition }
                }
            }
        }

        return validKeys
    }
//    func regroup() -> InstructionsCombinations {
//        var possibilities: [InstructionsAlternatives] = []
//
//        var currentSimple: [Character] = []
//        for alternatives in self {
//            if alternatives.count == 1 {
//                currentSimple.append(contentsOf: alternatives[0])
//            } else {
//                if !currentSimple.isEmpty {
//                    possibilities.append([currentSimple])
//                    currentSimple = []
//                }
//                possibilities.append(alternatives)
//            }
//        }
//        if !currentSimple.isEmpty {
//            possibilities.append([currentSimple])
//            currentSimple = []
//        }
//
//        return possibilities
//    }
}

func allInstructionsCombinationsToCreate(instructions: Instructions) -> InstructionsCombinations {
    var movementPossibilities: InstructionsCombinations = []
    var currentPosition: Character = "A"
    for character in instructions {
        movementPossibilities.append(allMovementsForInstructions(from: currentPosition, to: character))
        currentPosition = character
        movementPossibilities.append([["A"]])
    }
    return movementPossibilities
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
