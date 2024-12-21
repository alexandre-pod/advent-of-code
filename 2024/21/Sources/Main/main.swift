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
}

func instructionsToCreate(code: String) -> [Character] {
    var movements: [Character] = []
    var currentPosition: Character = "A"
    for character in code {
        movements.append(contentsOf: movementsForCode(from: currentPosition, to: character))
        currentPosition = character
        movements.append("A")
    }
    return movements
}

func movementsForCode(from start: Character, to end: Character) -> [Character] {
    let startPosition = codePosition(for: start)
    let endPosition = codePosition(for: end)
    var movements: [Character] = []
    var currentPosition = startPosition

    if currentPosition.y == 3, endPosition.y != 3 {
        let dy = endPosition.y < currentPosition.y ? -1 : 1
        while currentPosition.y != endPosition.y {
            currentPosition.y += dy
            movements.append(dy > 0 ? "v" : "^")
        }
    }

    let dx = endPosition.x < currentPosition.x ? -1 : 1
    while currentPosition.x != endPosition.x {
        currentPosition.x += dx
        movements.append(dx > 0 ? ">" : "<")
    }
    let dy = endPosition.y < currentPosition.y ? -1 : 1
    while currentPosition.y != endPosition.y {
        currentPosition.y += dy
        movements.append(dy > 0 ? "v" : "^")
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

func instructionsToCreate(instructions: String) -> [Character] {
    var movements: [Character] = []
    var currentPosition: Character = "A"
    for character in instructions {
        movements.append(contentsOf: movementsForInstructions(from: currentPosition, to: character))
        currentPosition = character
        movements.append("A")
    }
    return movements
}

func movementsForInstructions(from start: Character, to end: Character) -> [Character] {
    let startPosition = instructionPosition(for: start)
    let endPosition = instructionPosition(for: end)
    var movements: [Character] = []
    var currentPosition = startPosition

    if currentPosition.y == 0, endPosition.y != 0 {
        currentPosition.y += 1
        movements.append("v")
    }

    let dx = endPosition.x < currentPosition.x ? -1 : 1
    while currentPosition.x != endPosition.x {
        currentPosition.x += dx
        movements.append(dx > 0 ? ">" : "<")
    }
    let dy = endPosition.y < currentPosition.y ? -1 : 1
    while currentPosition.y != endPosition.y {
        currentPosition.y += dy
        movements.append(dy > 0 ? "v" : "^")
    }

    return movements
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

// MARK: - Part 2

func part2(codes: InputType) -> Int {
    fatalError()
}

main()

//    correct 456A:
//    <v<A>>^AA<vA<A>>^AAvAA<^A>A<vA>^A<A>A<vA>^A<A>A<v<A>A>^AAvA<^A>A
//    mine:
//    v<<A>>^Av<A<A>>^AAvA<^A>AvA^Av<A>^A<A>Av<A>^A<A>Av<A<A>>^AAvA<^A>A
