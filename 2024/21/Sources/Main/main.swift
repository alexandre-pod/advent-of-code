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

    // Attempt 2
//        print("Expected:")
//        for code in codes {
//            print("--- \(code)")
//            let possibilities = allInstructionsCombinationsToCreate(code: code)
//            print(possibilities.customDebugDescription)
//    //        let aaa = allInstructionsCombinationsToCreate(instructionsCombinations: possibilities)
//    //        print(aaa.customDebugDescription)
//        }

//    print("refactored:")

    // Attempt 3

//    for code in codes {
//        print("--- \(code)")
//        let firstRobotPossibleInstructions = possibleInstructionsToCreate(code: code) // 1st robot
////        dump(possibilities)
//        print(firstRobotPossibleInstructions)
////        print(String(firstRobotPossibleInstructions.shortestInstruction))
//        let secondRobotPossibleInstructions = possibleInstructionsToCreate(
//            possibleInstructions: firstRobotPossibleInstructions,
//            fromStartPosition: "A"
//        ).forceOneOfToFinishOnSamePosition()
//        print(secondRobotPossibleInstructions)
//        print(String(secondRobotPossibleInstructions.shortestInstruction))
//
//        fatalError()
//        let humanPossibleInstructions = possibleInstructionsToCreate(
//            possibleInstructions: secondRobotPossibleInstructions,
//            fromStartPosition: "A"
//        ).forceOneOfToFinishOnSamePosition()
//        print(humanPossibleInstructions)
//        print(humanPossibleInstructions.shortestInstruction.count)
////        let aaa = allInstructionsCombinationsToCreate(instructionsCombinations: possibilities)
//        //        print(aaa.customDebugDescription)
//    }

//    allPossibleInstructionsToCreate(code: "029A")

//    fatalError()

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

// attempt 1

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
    if currentPosition.x > 0, currentPosition.y != endPosition.y {
        currentPosition.y -= 1
        movements.append("^")
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

// Exaustive list of possible solution is oto hard to construct

//  // attempt 2
//
//    typealias Instructions = [Character]
//    typealias InstructionsAlternatives = [[Character]]
//    typealias InstructionsCombinations = [InstructionsAlternatives]
//
//    func allInstructionsCombinationsToCreate(code: String) -> InstructionsCombinations {
//        var movementPossibilities: InstructionsCombinations = []
//        var currentPosition: Character = "A"
//        for character in code {
//            movementPossibilities.append(allMovementsForCode(from: currentPosition, to: character))
//            currentPosition = character
//            movementPossibilities.append([["A"]])
//        }
//        return movementPossibilities
//    }
//
//    func allInstructionsCombinationsToCreate(instructionsCombinations: InstructionsCombinations) -> InstructionsCombinations {
//        let combinations = instructionsCombinations.regroup()
//    //    if combinations.count == 1 {
//    //        allInstructionsCombinationsToCreate(instructions: <#T##Instructions#>)
//    //    }
//        print(combinations)
//        for alternatives in combinations {
//            if alternatives.count == 1 {
//                print(
//                    alternatives.customDebugDescription,
//                    "<-",
//                    allInstructionsCombinationsToCreate(instructions: alternatives[0]).customDebugDescription
//                )
//            } else {
//                let newAlternatives = alternatives.flatMap { allInstructionsCombinationsToCreate(instructions: $0) }
//                print(alternatives.customDebugDescription, "<-", newAlternatives.customDebugDescription)
//            }
//        }
//        fatalError()
//    //    return
//    //    instructionsCombinations.map { possibilities in
//    //        possibilities.flatMap { allInstructionsCombinationsToCreate(instructions: $0) }
//    //    }
//        fatalError()
//    //    var movementPossibilities: InstructionsCombinations = []
//    //    var currentPosition: Character = "A"
//    //    for character in code {
//    //        movementPossibilities.append(allMovementsForCode(from: currentPosition, to: character))
//    //        currentPosition = character
//    //        movementPossibilities.append([["A"]])
//    //    }
//    //    return movementPossibilities
//    }
//
//    extension InstructionsCombinations {
//        func regroup() -> InstructionsCombinations {
//            var possibilities: [InstructionsAlternatives] = []
//
//            var currentSimple: [Character] = []
//            for alternatives in self {
//                if alternatives.count == 1 {
//                    currentSimple.append(contentsOf: alternatives[0])
//                } else {
//                    if !currentSimple.isEmpty {
//                        possibilities.append([currentSimple])
//                        currentSimple = []
//                    }
//                    possibilities.append(alternatives)
//                }
//            }
//            if !currentSimple.isEmpty {
//                possibilities.append([currentSimple])
//                currentSimple = []
//            }
//
//            return possibilities
//        }
//    }
//
//    func allInstructionsCombinationsToCreate(instructions: Instructions) -> InstructionsCombinations {
//        var movementPossibilities: InstructionsCombinations = []
//        var currentPosition: Character = "A"
//        for character in instructions {
//            movementPossibilities.append(allMovementsForInstructions(from: currentPosition, to: character))
//            currentPosition = character
//            movementPossibilities.append([["A"]])
//        }
//        return movementPossibilities
//    }
//
//
//    func allMovementsForCode(from start: Character, to end: Character) -> [[Character]] {
//        let startPosition = codePosition(for: start)
//        let endPosition = codePosition(for: end)
//        var validMovements: [[Character]] = []
//
//        let horizontalMovements: [Character] = startPosition.x < endPosition.x
//        ? Array(repeating: ">", count: endPosition.x - startPosition.x)
//        : Array(repeating: "<", count: startPosition.x - endPosition.x)
//        let verticalMovements: [Character] = startPosition.y < endPosition.y
//        ? Array(repeating: "v", count: endPosition.y - startPosition.y)
//        : Array(repeating: "^", count: startPosition.y - endPosition.y)
//
//        validMovements = allCombinationMixing(horizontalMovements, verticalMovements)
//            .filter { moves in
//                var currentPosition = startPosition
//                for move in moves {
//                    switch move {
//                    case "A": break
//                    case "<": currentPosition.x -= 1
//                    case ">": currentPosition.x += 1
//                    case "^": currentPosition.y -= 1
//                    case "v": currentPosition.y += 1
//                    default: fatalError()
//                    }
//                    if currentPosition.x == 0, currentPosition.y == 3 {
//                        return false
//                    }
//                }
//                return true
//            }
//        return validMovements
//    }
//
//    func allMovementsForInstructions(from start: Character, to end: Character) -> [[Character]] {
//        let startPosition = instructionPosition(for: start)
//        let endPosition = instructionPosition(for: end)
//        var validMovements: [[Character]] = []
//
//        let horizontalMovements: [Character] = startPosition.x < endPosition.x
//            ? Array(repeating: ">", count: endPosition.x - startPosition.x)
//            : Array(repeating: "<", count: startPosition.x - endPosition.x)
//        let verticalMovements: [Character] = startPosition.y < endPosition.y
//            ? Array(repeating: "v", count: endPosition.y - startPosition.y)
//            : Array(repeating: "^", count: startPosition.y - endPosition.y)
//
//        validMovements = allCombinationMixing(horizontalMovements, verticalMovements)
//            .filter { moves in
//                var currentPosition = startPosition
//                for move in moves {
//                    switch move {
//                    case "A": break
//                    case "<": currentPosition.x -= 1
//                    case ">": currentPosition.x += 1
//                    case "^": currentPosition.y -= 1
//                    case "v": currentPosition.y += 1
//                    default: fatalError()
//                    }
//                    if currentPosition.x == 0, currentPosition.y == 0 {
//                        return false
//                    }
//                }
//                return true
//            }
//        return validMovements
//    }
//
//    func allCombinationMixing(_ part1: [Character], _ part2: [Character]) -> [[Character]] {
//        guard !part1.isEmpty else { return [part2] }
//        guard !part2.isEmpty else { return [part1] }
//        return [
//            allCombinationMixing(Array(part1.dropFirst()), part2).map { [part1[0]] + $0 },
//            allCombinationMixing(part1, Array(part2.dropFirst())).map { [part2[0]] + $0 }
//        ].flatMap { $0 }
//    }
//
//    // attempt 3
//
//    enum PossibleInstructions {
//        case single([Character], finalPosition: Character)
//        case oneOf([PossibleInstructions])
//        case chainOf([PossibleInstructions])
//    }
//
//    extension PossibleInstructions {
//        var simplified: PossibleInstructions {
//            switch self {
//    //        case .single(let array):
//    //            return self
//            case .oneOf(let array) where array.count == 1:
//                return array[0].simplified
//            case .chainOf(let array) where array.count == 1:
//                return array[0].simplified
//            case .chainOf(let array):
//                var simplifiedList: [PossibleInstructions] = []
//                var currentSingle: [Character] = []
//                var lastFinalPosition: Character = "?"
//                for possibleInstruction in array.map(\.simplified) {
//                    if case let .single(directInstructions, finalPosition) = possibleInstruction {
//                        currentSingle.append(contentsOf: directInstructions)
//                        lastFinalPosition = finalPosition
//                    } else {
//                        if !currentSingle.isEmpty {
//                            assert(lastFinalPosition != "?")
//                            simplifiedList.append(.single(currentSingle, finalPosition: lastFinalPosition))
//                            currentSingle = []
//                            lastFinalPosition = "?"
//                        }
//                        simplifiedList.append(possibleInstruction)
//                        assert(currentSingle.isEmpty)
//                    }
//                }
//                if !currentSingle.isEmpty {
//                    assert(lastFinalPosition != "?")
//                    simplifiedList.append(.single(currentSingle, finalPosition: lastFinalPosition))
//                    currentSingle = []
//                    lastFinalPosition = "?"
//                }
//                assert(currentSingle.isEmpty)
//                return simplifiedList.count == 1 ? simplifiedList[0] : .chainOf(simplifiedList)
//            default:
//                return self
//            }
//        }
//    }
//
//    extension PossibleInstructions: CustomDebugStringConvertible {
//        var debugDescription: String {
//            switch self {
//            case .single(let array, _):
//                return String(array)
//            case .oneOf(let array):
//                return "(" + array.map(\.debugDescription).joined(separator: " | ") + ")"
//            case .chainOf(let array):
//                return array.map(\.debugDescription).joined()
//            }
//        }
//    }
//
//    func possibleInstructionsToCreate(code: String) -> PossibleInstructions {
//        var instructionsChain: [PossibleInstructions] = []
//        var currentPosition: Character = "A"
//        for character in code {
//            instructionsChain.append(possibleInstructionsForCodeMove(from: currentPosition, to: character))
//            currentPosition = character
//            instructionsChain.append(.single(["A"], finalPosition: character))
//        }
//        return .chainOf(instructionsChain).simplified.forceOneOfToFinishOnSamePosition()
//    }
//
//    func possibleInstructionsToCreate(
//        possibleInstructions: PossibleInstructions,
//        fromStartPosition startPosition: Character // = "A"
//    ) -> PossibleInstructions {
//        print("possibleInstructionsToCreate(\(possibleInstructions), fromStartPosition: \(startPosition)")
//        switch possibleInstructions {
//        case let .single(instructions, _):
//            return possibleInstructionsToCreate(instructions: instructions)
//        case let .oneOf(possibilities):
//            // remove duplicates ?
//            return .oneOf(possibilities.map {
//                possibleInstructionsToCreate(possibleInstructions: $0, fromStartPosition: startPosition)
//            }
//            )
//        case let .chainOf(parts):
//            var finalParts: [PossibleInstructions] = []
//            var currentPosition = startPosition
//            for part in parts {
//                let finalPart = possibleInstructionsToCreate(
//                    possibleInstructions: part,
//                    fromStartPosition: currentPosition
//                )
//                currentPosition = finalPart.finalPosition!
//                finalParts.append(finalPart)
//            }
//            return .chainOf(finalParts)
//    //        return .chainOf(parts.map {
//    //            possibleInstructionsToCreate(possibleInstructions: $0, fromStartPosition: startPosition) // this start should change
//    //        })
//        }
//    }
//
//    extension PossibleInstructions {
//        var finalPosition: Character? {
//            switch self {
//            case .single(let array, let finalPosition):
//                return finalPosition
//            case .oneOf(let array):
//                let finalPositions = array.map(\.finalPosition)
//                if finalPositions.allSatisfy({ $0 == finalPositions[0] }) {
//                    return finalPositions[0]
//                } else {
//                    print(finalPositions)
//                    return nil
//    //                fatalError("Impossible case to debug: \(self), \(finalPositions)")
//                }
//    //            return
//            case .chainOf(let array):
//                return array.last!.finalPosition
//            }
//        }
//
//        var isOneOfWithMultipleFinalPosition: Bool {
//            return finalPosition == nil
//        }
//    }
//
//    extension PossibleInstructions {
//        func forceOneOfToFinishOnSamePosition() -> PossibleInstructions {
//            print("QSDF")
//            switch self {
//            case .single(let array, let finalPosition):
//                return self
//            case .oneOf(let array):
//                guard isOneOfWithMultipleFinalPosition else { return self }
//                fatalError("Invalid state, cannot reconcile end of oneOfs without knowing next value")
//            case .chainOf(let array):
//                var fixedChain: [PossibleInstructions] = []
//
//                var i = 0
//                while i < array.count {
//                    print("Check", array[i], "-> \(array[i].isOneOfWithMultipleFinalPosition)")
//                    if array[i].isOneOfWithMultipleFinalPosition {
//                        let patchedNext = array[i + 1].droppingFirstInstruction()
//                        print("PATCHED", patchedNext)
//                        switch array[i] {
//                        case .oneOf(let array):
//                            fixedChain.append(array[i].addingAtEnd(patchedNext.1, finalPosition: "A"))
//                            fixedChain.append(patchedNext.0)
//                        default: fatalError()
//                        }
//                        i += 2
//                    } else {
//                        fixedChain.append(array[i])
//                        i += 1
//                    }
//                }
//
//                return .chainOf(fixedChain)
//
//                fatalError("Not implemented")
//    //            return self
//            }
//        }
//
//        func droppingFirstInstruction() -> (PossibleInstructions, Character) {
//            switch self {
//            case .single(let array, let finalPosition):
//                return (.single(Array(array.dropFirst()), finalPosition: finalPosition), array.first!)
//            case .oneOf(let array):
//                var patched = array.map { $0.droppingFirstInstruction() }
//                precondition(Set(patched.map(\.1)).count == 1)
//                return (.oneOf(patched.map(\.0)), patched.map(\.1)[0])
//            case .chainOf(let array):
//                let (patchedFirst, firstInstruction) = array[0].droppingFirstInstruction()
//                return (.chainOf([patchedFirst] + array.dropFirst()), firstInstruction)
//            }
//        }
//
//        func addingAtEnd(_ instruction: Character, finalPosition: Character) -> PossibleInstructions {
//            switch self {
//            case .single(let array, _):
//                return .single(array + [instruction], finalPosition: finalPosition)
//            case .oneOf(let array):
//                return .oneOf(array.map { $0.addingAtEnd(instruction, finalPosition: finalPosition) })
//            case .chainOf(let array):
//                return .chainOf(array.dropLast() + [array.last!.addingAtEnd(instruction, finalPosition: finalPosition)])
//            }
//        }
//    }
//
//    func possibleInstructionsToCreate(instructions: [Character]) -> PossibleInstructions {
//        var instructionsChain: [PossibleInstructions] = []
//        var currentPosition: Character = "A"
//        for character in instructions {
//            instructionsChain.append(possibleInstructionsForMoveInstructions(from: currentPosition, to: character))
//            currentPosition = character
//            instructionsChain.append(.single(["A"], finalPosition: currentPosition))
//        }
//        return .chainOf(instructionsChain).simplified
//    }
//
//    func possibleInstructionsForCodeMove(from start: Character, to end: Character) -> PossibleInstructions {
//        let startPosition = codePosition(for: start)
//        let endPosition = codePosition(for: end)
//        var validMovements: [[Character]] = []
//
//        let horizontalMovements: [Character] = startPosition.x < endPosition.x
//        ? Array(repeating: ">", count: endPosition.x - startPosition.x)
//        : Array(repeating: "<", count: startPosition.x - endPosition.x)
//        let verticalMovements: [Character] = startPosition.y < endPosition.y
//        ? Array(repeating: "v", count: endPosition.y - startPosition.y)
//        : Array(repeating: "^", count: startPosition.y - endPosition.y)
//
//        validMovements = allCombinationMixing(horizontalMovements, verticalMovements)
//            .filter { moves in
//                var currentPosition = startPosition
//                for move in moves {
//                    switch move {
//                    case "A": break
//                    case "<": currentPosition.x -= 1
//                    case ">": currentPosition.x += 1
//                    case "^": currentPosition.y -= 1
//                    case "v": currentPosition.y += 1
//                    default: fatalError()
//                    }
//                    if currentPosition.x == 0, currentPosition.y == 3 {
//                        return false
//                    }
//                }
//                return true
//            }
//        return PossibleInstructions.oneOf(validMovements.map { .single($0, finalPosition: end) })
//    }
//
//    func possibleInstructionsForMoveInstructions(from start: Character, to end: Character) -> PossibleInstructions {
//        let startPosition = instructionPosition(for: start)
//        let endPosition = instructionPosition(for: end)
//        var validMovements: [[Character]] = []
//
//        let horizontalMovements: [Character] = startPosition.x < endPosition.x
//        ? Array(repeating: ">", count: endPosition.x - startPosition.x)
//        : Array(repeating: "<", count: startPosition.x - endPosition.x)
//        let verticalMovements: [Character] = startPosition.y < endPosition.y
//        ? Array(repeating: "v", count: endPosition.y - startPosition.y)
//        : Array(repeating: "^", count: startPosition.y - endPosition.y)
//
//        validMovements = allCombinationMixing(horizontalMovements, verticalMovements)
//            .filter { moves in
//                var currentPosition = startPosition
//                for move in moves {
//                    switch move {
//                    case "A": break
//                    case "<": currentPosition.x -= 1
//                    case ">": currentPosition.x += 1
//                    case "^": currentPosition.y -= 1
//                    case "v": currentPosition.y += 1
//                    default: fatalError()
//                    }
//                    if currentPosition.x == 0, currentPosition.y == 0 {
//                        return false
//                    }
//                }
//                return true
//            }
//        return PossibleInstructions.oneOf(validMovements.map { .single($0, finalPosition: end) })
//    }
//
//    extension PossibleInstructions {
//        var shortestInstruction: [Character] {
//            switch self {
//            case .single(let array, _):
//                return array
//            case .oneOf(let array):
//                return array.map(\.shortestInstruction).min { $0.count < $1.count }!
//            case .chainOf(let array):
//                return array.flatMap(\.shortestInstruction)
//            }
//        }
//    }


// MARK: - Part 2

func part2(codes: InputType) -> Int {
    fatalError()
}

main()

//    correct 456A:
//    <v<A>>^AA<vA<A>>^AAvAA<^A>A<vA>^A<A>A<vA>^A<A>A<v<A>A>^AAvA<^A>A
//    mine:
//    v<<A>>^Av<A<A>>^AAvA<^A>AvA^Av<A>^A<A>Av<A>^A<A>Av<A<A>>^AAvA<^A>A

// MARK: - Debug


//    extension Instructions {
//        var customDebugDescription: String {
//            return String(self)
//        }
//    }
//
//    extension InstructionsAlternatives {
//        var customDebugDescription: String {
//            if count == 1 {
//                self[0].customDebugDescription
//            } else {
//                "(" + self.map(\.customDebugDescription).joined(separator: " | ") + ")"
//            }
//        }
//    }
//
//    extension InstructionsCombinations {
//        var customDebugDescription: String {
//            self.map(\.customDebugDescription).joined()
//        }
//    }
