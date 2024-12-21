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

    if currentPosition.y == 0, endPosition.y != 0 {
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

    var result = 0

    for code in codes {
        let keys = Array(code)
        print("----", code)

        var cache: [CacheKey: Int] = [:]

        let directInput = directionKeyboardKeysCountToEnterKeys(keys, for: 1, lastRobot: 1, cache: &cache)
        cache = [:]
//        print(directInput)
        let inputForRobot1 = directionKeyboardKeysCountToEnterKeys(keys, for: 1, lastRobot: 2, cache: &cache)
        cache = [:]
//        print(inputForRobot1)
        let inputForRobot2 = directionKeyboardKeysCountToEnterKeys(keys, for: 1, lastRobot: 3, cache: &cache)
        cache = [:]
//        print(inputForRobot2)

        // Gives the rame response than part 1
        // 4 = 1 (door) + 2 (robot) + 1 (human)
        let inputForHuman = directionKeyboardKeysCountToEnterKeys(keys, for: 1, lastRobot: 4, cache: &cache)
        print(inputForHuman)

        // 27 = 1 (door) + 25 (robot) + 1 (human)
//        let inputForHuman = directionKeyboardKeysCountToEnterKeys(keys, for: 1, lastRobot: 27, cache: &cache)
//        print(inputForHuman)

        result += inputForHuman * Int(String(code.dropLast()))!
    }

    return result


    // 304661348613172 too high

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
    let robotNumber: Int
    let lastRobot: Int
}

func directionKeyboardKeysCountToEnterKeys(
    _ keys: [Character],
    for robotNumber: Int,
    lastRobot: Int,
    cache: inout [CacheKey: Int]
) -> Int {
    if robotNumber == lastRobot {
        // we are directly tapping the keys, so the answer if the number of keys
        return keys.count
    }

    let key = CacheKey(keys: keys, robotNumber: robotNumber, lastRobot: lastRobot)
    if let value = cache[key] {
        return value
    }

    if robotNumber == 1 {
        var finalKeysCount = 0
        var robotPosition: Character = "A"
        for key in keys {
            let movementsAndInput = movementsForCode(from: robotPosition, to: key) + ["A"]
            robotPosition = key

            // `movementsAndInput` represent the action robot2 should enter to have robot1 enter `letter`
            // at the start and end of `movementsAndInput` all robots are on A (because start or all of them pressing A)

            finalKeysCount += directionKeyboardKeysCountToEnterKeys(
                movementsAndInput,
                for: robotNumber + 1,
                lastRobot: lastRobot,
                cache: &cache
            )
        }

        cache[key] = finalKeysCount
        return finalKeysCount
    } else {
        var finalKeysCount = 0
        var robotPosition: Character = "A"
        for key in keys {
            let movementsAndInput = movementsForInstructions(from: robotPosition, to: key) + ["A"]
            robotPosition = key

            // `movementsAndInput` represent the action robot2 should enter to have robot1 enter `letter`
            // at the start and end of `movementsAndInput` all robots are on A (because start or all of them pressing A)

            finalKeysCount += directionKeyboardKeysCountToEnterKeys(
                movementsAndInput,
                for: robotNumber + 1,
                lastRobot: lastRobot,
                cache: &cache
            )
        }

        cache[key] = finalKeysCount
        return finalKeysCount
    }

    fatalError()
}

func instructionsToTap(
    keys: [Character],
    afterRobots depth: Int // 0 = numerical keypad, >0 = directional keypad
) -> [Character] {
//    guard depth > 0 else {
//        return keys
//    }

    if depth == 1 {
        var directionalInstructions = instructionsToCreate(code: keys)
        return directionalInstructions
    }


    let directionalKeys = instructionsToTap(
        keys: keys,
        afterRobots: depth - 1
    )


    fatalError()
}

//    func instructions(
//        toWrite instruction: Character,
//    //    from position: inout Character,
//        afterIntermediateRobotsCount intermediateRobots: Int
//    ) -> [Character] {
//
//        if intermediateRobots == 0 { // human can press directly
//            return [instruction]
//        }
//        // we need to move the robot, then press A
//    //    let intermediateInstructions = movementsForInstructions(from: "A", to: instruction) + ["A"]
//    //
//    //    var currentPosition = "A"
//    //    for intermediateInstruction in intermediateInstructions {
//    //
//    //        minInstructions(toWrite: <#T##Character#>, afterIntermediateRobotsCount: <#T##Int#>)
//    //
//    //    }
//
//
//    //    let aaaa = minInstructions(toWrite: <#T##Character#>, from: <#T##Character#>, afterIntermediateRobotsCount: <#T##Int#>)
//
//    }

func minInstructionsCountToCreate(instruction: Character, afterIntermediateRobotsCount intermediateRobots: Int) -> Int {

    if intermediateRobots == 0 {
        var movements = movementsForInstructions(from: "A", to: instruction) + ""
        return movements.count + 1
    }





    fatalError()

//    var movementsCount = 0
//    var currentPosition: Character = "A"
//    for character in instructions {
//        movementsCount += movementsForInstructions(from: currentPosition, to: character).count
//        currentPosition = character
//        movementsCount.append("A")
//    }
//    return movements
}

//func minInstructionsCountToCreate(instructions: String) -> Int {
//    var movementsCount = 0
//    var currentPosition: Character = "A"
//    for character in instructions {
//        movementsCount += movementsForInstructions(from: currentPosition, to: character).count
//        currentPosition = character
//        movementsCount.append("A")
//    }
//    return movements
//}

main()

//    correct 456A:
//    <v<A>>^AA<vA<A>>^AAvAA<^A>A<vA>^A<A>A<vA>^A<A>A<v<A>A>^AAvA<^A>A
//    mine:
//    v<<A>>^Av<A<A>>^AAvA<^A>AvA^Av<A>^A<A>Av<A>^A<A>Av<A<A>>^AAvA<^A>A
