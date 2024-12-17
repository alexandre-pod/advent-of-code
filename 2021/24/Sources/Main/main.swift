import Foundation

enum Operation {
    case inp(Number)
    case add(Number, Number)
    case mul(Number, Number)
    case div(Number, Number)
    case mod(Number, Number)
    case eql(Number, Number)

    enum Number {
        case variable(name: Character)
        case value(Int)
    }
}

// MARK: - Main

func main() {

    var operations: [Operation] = []

    while let line = readLine() {
        var tokenFeed = TokenFeed(characters: line.map { $0 })
        operations.append(try! parseOperation(&tokenFeed))
    }

    operations.forEach { $0.debugPrint() }

    print(part1(operations: operations))
//    print(part2())
}

// MARK: - Parser

struct TokenFeed {

    private let characters: [Character]
    private(set) var currentIndex = 0
    private(set) var endOfFeed = false

    enum Error: Swift.Error {
        case endOfFeed
        case unexpectedEndOfFeed
    }

    init(characters: [Character]) {
        self.characters = characters
    }

    var currentToken: Character? {
        guard !endOfFeed else { return nil }
        return characters[currentIndex]
    }

    var nextToken: Character? {
        guard !endOfFeed else { return nil }
        return characters[currentIndex + 1]
    }

    @discardableResult
    mutating func consumeCurrentToken() -> Character? {
        guard !endOfFeed else { return nil }
        defer {
            if characters.indices.last == currentIndex {
                endOfFeed = true
            } else {
                currentIndex += 1
            }
        }
        return characters[currentIndex]
    }
}

extension TokenFeed {
    mutating func consumeTokens(_ n: Int) throws -> [Character] {
        let tokens = (0..<n).map { _ in self.consumeCurrentToken() }

        guard tokens.allSatisfy({ $0 != nil }) else {
            throw Error.unexpectedEndOfFeed
        }

        return tokens.compactMap { $0 }
    }

    mutating func consumeToken(_ character: Character) throws {
        guard currentToken == character else { throw ParsingError.invalidSyntax }
        consumeCurrentToken()
    }
}

enum ParsingError: Error {
    case invalidSyntax
}

func parseOperation(_ tokenFeed: inout TokenFeed) throws -> Operation {

    let operatorName = try String(tokenFeed.consumeTokens(3))

    tokenFeed.consumeCurrentToken()

    let firstNumber = try parseNumber(from: &tokenFeed)

    switch operatorName {
    case "inp":
        return .inp(firstNumber)
    case "add":
        tokenFeed.consumeCurrentToken()
        let secondNumber = try parseNumber(from: &tokenFeed)
        return .add(firstNumber, secondNumber)
    case "mul":
        tokenFeed.consumeCurrentToken()
        let secondNumber = try parseNumber(from: &tokenFeed)
        return .mul(firstNumber, secondNumber)
    case "div":
        tokenFeed.consumeCurrentToken()
        let secondNumber = try parseNumber(from: &tokenFeed)
        return .div(firstNumber, secondNumber)
    case "mod":
        tokenFeed.consumeCurrentToken()
        let secondNumber = try parseNumber(from: &tokenFeed)
        return .mod(firstNumber, secondNumber)
    case "eql":
        tokenFeed.consumeCurrentToken()
        let secondNumber = try parseNumber(from: &tokenFeed)
        return .eql(firstNumber, secondNumber)
    default:
        throw ParsingError.invalidSyntax
    }
}

func parseNumber(from tokenFeed: inout TokenFeed) throws -> Operation.Number {
    if "a"..."z" ~= tokenFeed.currentToken! {
        return .variable(name: tokenFeed.consumeCurrentToken()!)
    }

    var stringNumber = ""
    while let current = tokenFeed.currentToken, "0"..."9" ~= current || current == "-" {
        stringNumber.append(tokenFeed.consumeCurrentToken()!)
    }
    return .value(Int(stringNumber)!)
}

// MARK: - Part 1

func part1(operations: [Operation]) -> Int {

//    print(isValidNumber(modelNumber: 39924989499969, using: operations))
    print(isValidNumber(modelNumber: 16811412161117, using: operations))
    return 0

//    let modelNumber = 11111111111111
//    let inputs = String(modelNumber).map { Int(String($0))! }
//    guard inputs.allSatisfy({ $0 != 0 }) else { return 0 }
//    var alu = ALU(operations: operations, inputs: inputs)
//    alu.execute()
//    print(alu.variables["z"]!)
//
//
//    return 0

//    var alu = ALU(operations: operations, inputs: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15])

//    alu.execute()

//    print(alu.variables)

//    print(isValidNumber(modelNumber: [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1], using: operations))
//
//    print(isValidNumber(modelNumber: [1, 1, 1, 1, 1, 1, 1, 1, 1, 9, 1, 1, 1, 1], using: operations))
//    print(isValidNumber(modelNumber: [9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9], using: operations))

//    var number = 99999999999999
//
//    while !isValidNumber(modelNumber: number, using: operations) {
//        print("failed:", number)
//        number -= 1
//    }

    var number = 99999999999999

    var count = 0

    while !isValidNumber(modelNumber: number, using: operations) {
        defer { count += 1 }
        if count % 100000 == 0 {
            print("failed:", number)
        }
        number -= 1
    }

    return number
}

//func isValidNumber(modelNumber: Int, using operations: [Operation]) -> Bool {
//    let inputs = String(modelNumber).map { Int(String($0))! }
//    guard inputs.allSatisfy({ $0 != 0 }) else { return false }
//    var alu = ALU(operations: operations, inputs: inputs)
//    alu.execute()
//    return alu.variables["z"] == 0
//}

func isValidNumber(modelNumber: Int, using operations: [Operation]) -> Bool {
    let input = String(modelNumber).map { Int(String($0))! }

//    let input = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]

    var z = 0
    z = addBlock(z: z, input: input[0], divideFactor: 1, param1: 12, param2: 9)
    z = addBlock(z: z, input: input[1], divideFactor: 1, param1: 12, param2: 4)
    z = addBlock(z: z, input: input[2], divideFactor: 1, param1: 12, param2: 2)
    z = addBlock(z: z, input: input[3], divideFactor: 26, param1: -9, param2: 5)
    z = addBlock(z: z, input: input[4], divideFactor: 26, param1: -9, param2: 1)
    z = addBlock(z: z, input: input[5], divideFactor: 1, param1: 14, param2: 6)
    z = addBlock(z: z, input: input[6], divideFactor: 1, param1: 14, param2: 11)
    z = addBlock(z: z, input: input[7], divideFactor: 26, param1: -10, param2: 15)
    z = addBlock(z: z, input: input[8], divideFactor: 1, param1: 15, param2: 7)
    z = addBlock(z: z, input: input[9], divideFactor: 26, param1: -2, param2: 12)
    z = addBlock(z: z, input: input[10], divideFactor: 1, param1: 11, param2: 15)
    z = addBlock(z: z, input: input[11], divideFactor: 26, param1: -15, param2: 9)
    z = addBlock(z: z, input: input[12], divideFactor: 26, param1: -9, param2: 12)
    z = addBlock(z: z, input: input[13], divideFactor: 26, param1: -3, param2: 12)

    return z == 0
}

func addBlock(z: Int, input: Int, divideFactor: Int, param1: Int, param2: Int) -> Int {
    let x = ((z % 26) + param1) == input ? 0 : 1
    let y = 25 * x + 1
    return (z / divideFactor) * y + (input + param2) * x
}

struct ALU {
    let operations: [Operation]
    var inputs: [Int]
    var currentIndex = 0
    var variables: [Character: Int] = [
        "w": 0,
        "x": 0,
        "y": 0,
        "z": 0
    ]

    mutating func execute() {
        operations.forEach {
            $0.execute(on: &self)
            print(variables["z"]!)
        }
    }
}

extension Operation {
    func execute(on alu: inout ALU) {
        switch self {
        case .inp(let number):
            guard case let .variable(variable) = number else { fatalError() }
            alu.variables[variable] = alu.inputs.removeFirst()
        case .add(let numberA, let number):
            guard case let .variable(variable) = numberA else { fatalError() }
            alu.variables[variable]! += number.value(in: alu)
        case .mul(let numberA, let number):
            guard case let .variable(variable) = numberA else { fatalError() }
            alu.variables[variable]! *= number.value(in: alu)
        case .div(let numberA, let number):
            guard case let .variable(variable) = numberA else { fatalError() }
            alu.variables[variable]! /= number.value(in: alu)
        case .mod(let numberA, let number):
            guard case let .variable(variable) = numberA else { fatalError() }
            alu.variables[variable]! %= number.value(in: alu)
        case .eql(let numberA, let number):
            guard case let .variable(variable) = numberA else { fatalError() }
            alu.variables[variable] = alu.variables[variable]! == number.value(in: alu)
            ? 1
            : 0
        }
    }
}

extension Operation.Number {
    func value(in alu: ALU) -> Int {
        switch self {
        case let .variable(name: name):
            return alu.variables[name]!
        case let .value(value):
            return value
        }
    }
}

// MARK: - Part 2

func part2() -> Int {

    return 0
}

// MARK: - Tests

func test1(input: Int) {
    var operations: [Operation] = []
    for line in try! String(contentsOf: URL(fileURLWithPath: "sample1", relativeTo: nil)).split(separator: "\n") {
        var tokenFeed = TokenFeed(characters: line.map { $0 })
        operations.append(try! parseOperation(&tokenFeed))
    }

    var alu = ALU(operations: operations, inputs: [input])
    alu.execute()
    print(input, "->", alu.variables["x"]!)
}

func test2(input1: Int, input2: Int) {
    var operations: [Operation] = []
    for line in try! String(contentsOf: URL(fileURLWithPath: "sample2", relativeTo: nil)).split(separator: "\n") {
        var tokenFeed = TokenFeed(characters: line.map { $0 })
        operations.append(try! parseOperation(&tokenFeed))
    }

    var alu = ALU(operations: operations, inputs: [input1, input2])
    alu.execute()
    print([input1, input2], "->", alu.variables["z"]!)
}

func test3(input: Int) {
    var operations: [Operation] = []
    for line in try! String(contentsOf: URL(fileURLWithPath: "sample3", relativeTo: nil)).split(separator: "\n") {
        var tokenFeed = TokenFeed(characters: line.map { $0 })
        operations.append(try! parseOperation(&tokenFeed))
    }

    var alu = ALU(operations: operations, inputs: [input])
    alu.execute()
    print(input, "->", alu.variables["w"]!, alu.variables["x"]!, alu.variables["y"]!, alu.variables["z"]!)
}

func tests() {
    print("test 1")
    test1(input: 10)
    test1(input: -10)

    print("test 2")
    test2(input1: 1, input2: 1)
    test2(input1: 1, input2: 3)
    test2(input1: 1, input2: 10)
    test2(input1: 10, input2: 1)

    print("test 3")
    test3(input: 0)
    test3(input: 1)
    test3(input: 2)
    test3(input: 4)
    test3(input: 8)
    test3(input: 15)
}

// MARK: - Start

main()
//tests()

// MARK: - Debug

extension Operation {

    func debugPrint() {
        switch self {
        case .inp(let number):
            guard case let .variable(variable) = number else { fatalError() }
            print("\(variable) <- readValue()")
        case .add(let numberA, let number):
            guard case let .variable(variable) = numberA else { fatalError() }
            print("\(variable) = \(variable) + \(number)")
        case .mul(let numberA, let number):
            guard case let .variable(variable) = numberA else { fatalError() }
            print("\(variable) = \(variable) * \(number)")
        case .div(let numberA, let number):
            guard case let .variable(variable) = numberA else { fatalError() }
            print("\(variable) = \(variable) / \(number)")
        case .mod(let numberA, let number):
            guard case let .variable(variable) = numberA else { fatalError() }
            print("\(variable) = \(variable) % \(number)")
        case .eql(let numberA, let number):
            guard case let .variable(variable) = numberA else { fatalError() }
            print("\(variable) = \(variable) == \(number)")
        }
    }
}

extension Operation.Number: CustomStringConvertible {
    var description: String {
        switch self {
        case .variable(let name):
            return String(name)
        case .value(let value):
            return String(value)
        }
    }
}


func findZInput(forZOutput zOutput: Int, divideFactor: Int, param1: Int, param2: Int) -> [Int: [Int]] {
    var result: [Int: [Int]] = [:]
    for input in 1...9 {
        for zInput in 0...10000 {
            if addBlock(z: zInput, input: input, divideFactor: divideFactor, param1: param1, param2: param2) == zOutput {
                result[input, default: []].append(zInput)
            }
            //            if testAllInputs(z: zInput, divideFactor: divideFactor, param1: param1, param2: param2) {
            //
            //            }
        }
    }
    return result
}

//print(findZInput(forZOutput: 0, divideFactor: 26, param1: -3, param2: 12))
//print(findZInput(forZOutput: 12, divideFactor: 26, param1: -9, param2: 12))

//var possibilities: [[Int: Int]] = []

//let parameters = [
//    (1, 12, 9),
//    (1, 12, 4),
//    (1, 12, 2),
//    (26, -9, 5),
//    (26, -9, 1),
//    (1, 14, 6),
//    (1, 14, 11),
//    (26, -10, 15),
//    (1, 15, 7),
//    (26, -2, 12),
//    (1, 11, 15),
//    (26, -15, 9),
//    (26, -9, 12),
//    (26, -3, 12)
//]
//
//func findBestConfiguration(atStep step: Int, forTargetZOutput zOutput: Int) -> [Int]? {
//
//    let zInputs = findZInput(forZOutput: zOutput, divideFactor: parameters[step].0, param1: parameters[step].1, param2: parameters[step].2)
////    print("step \(step)", zInputs)
//
//    if step == 0 {
//        if let maxFound = zInputs.filter({ $0.value.contains(0) }).map(\.key).max() {
//            return [maxFound]
//        }
//        return nil
//    }
//
//    let configurations: [[Int]] = zInputs.flatMap { inputs -> [[Int]] in
//        let configs = inputs.value.compactMap { findBestConfiguration(atStep: step - 1, forTargetZOutput: $0) }
//        guard !configs.isEmpty else { return [] }
//
//        if step == 13 {
//            print("result?", configs.map { [inputs.key] + $0 })
//        }
//
//        return configs.map { [inputs.key] + $0 }
//
//        //        guard let config = findBestConfiguration(atStep: step - 1, forTargetZOutput: inputs.value) else { return nil }
//        //        if step == 13 {
//        //            print("result?", ($0.key, config))
//        //        }
//        //        return (inputs.key, config)
//    }
//
//    if let maxValue = configurations.max(by: { $0[0] < $1[0] }) {
//        return maxValue
//    }
//
//    return nil
//
//}

//print(findBestConfiguration(atStep: 13, forTargetZOutput: 0))


