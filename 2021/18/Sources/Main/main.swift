import Foundation

class SnailfishNumber {

    enum NumberType {
        case regular(Int)
        case pair(SnailfishNumber, SnailfishNumber)
    }

    var type: NumberType
    var parent: SnailfishNumber?

    init(type: SnailfishNumber.NumberType, parent: SnailfishNumber?) {
        self.type = type
        self.parent = parent
    }
}

extension SnailfishNumber {
    var isPair: Bool {
        switch self.type {
        case .regular:
            return false
        case .pair:
            return true
        }
    }

    var isRegular: Bool {
        switch self.type {
        case .regular:
            return true
        case .pair:
            return false
        }
    }

    var regularValue: Int {
        switch self.type {
        case let .regular(value):
            return value
        case .pair:
            fatalError()
        }
    }

    var magnitude: Int {
        switch self.type {
        case let .regular(value):
            return value
        case let .pair(left, right):
            return 3 * left.magnitude + 2 * right.magnitude
        }
    }

    func deepCopy() -> SnailfishNumber {
        switch type {
        case let .regular(value):
            return SnailfishNumber(type: .regular(value), parent: nil)
        case let .pair(left, right):
            let leftCopy = left.deepCopy()
            let rightCopy = right.deepCopy()
            let copy = SnailfishNumber(type: .pair(leftCopy, rightCopy), parent: nil)
            leftCopy.parent = copy
            rightCopy.parent = copy
            return copy
        }
    }
}

// MARK: - Main

func main() {

    var numbers: [SnailfishNumber] = []

    while let line = readLine() {
        let number = try! parseNumber(fromString: line)
        numbers.append(number)

//        print(line)
//        print(number)
    }

    print(part1(numbers: numbers))
    print(part2(numbers: numbers))
}

// MARK: - Part 1

func part1(numbers: [SnailfishNumber]) -> Int {

    var result = numbers[0].deepCopy()

    for number in numbers[1...] {
        result = addAndReduce(result, number.deepCopy())
    }

//    print(result)
//    print(result.magnitude)

    return result.magnitude
}

// MARK: - Part 2

func part2(numbers: [SnailfishNumber]) -> Int {
    var maxMagnitude = Int.min

    for i1 in numbers.indices {
        for i2 in numbers.indices where i1 != i2 {
            let magnitude = addAndReduce(numbers[i1].deepCopy(), numbers[i2].deepCopy()).magnitude
            maxMagnitude = max(maxMagnitude, magnitude)
        }
    }

    return maxMagnitude
}

// MARK: - Tests

func test() {
    testExplodingStep(on: "[[[[[9,8],1],2],3],4]")
    testExplodingStep(on: "[7,[6,[5,[4,[3,2]]]]]")
    testExplodingStep(on: "[[6,[5,[4,[3,2]]]],1]")
    testExplodingStep(on: "[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]")
    testExplodingStep(on: "[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]")

    testSplitStep(on: "[[[[0,7],4],[15,[0,13]]],[1,1]]")
    testSplitStep(on: "[[[[0,7],4],[[7,8],[0,13]]],[1,1]]")

    testAddition(on: "[[[[4,3],4],4],[7,[[8,4],9]]]", and: "[1,1]")
}

func testExplodingStep(on string: String) {
    print("Exloding:\n\(string)")
    let number = try! parseNumber(fromString: string)
    let fourDeepPair = findPair(from: number, withDepth: 4)!
    explode(pair: fourDeepPair)
    print(number)
}

func testSplitStep(on string: String) {
    print("Splitting:\n\(string)")
    let number = try! parseNumber(fromString: string)
    let splittingNumber = findRegularNumber(from: number, greaterOrEqualTo: 10)!
    split(regularNumber: splittingNumber)
    print(number)
}

func testAddition(on leftString: String, and rightString: String) {
    print("Add:\n\(leftString) \(rightString)")
    let number = addAndReduce(try! parseNumber(fromString: leftString), try! parseNumber(fromString: rightString))
    print(number)
}

// MARK: - InputParser

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

func parseNumber(fromString string: String) throws -> SnailfishNumber {
    var tokenFeed = TokenFeed(characters: string.map { $0 })
    return try parseNumber(from: &tokenFeed)
}

func parseNumber(from tokenFeed: inout TokenFeed) throws -> SnailfishNumber {
    if tokenFeed.currentToken == "[" {
        try tokenFeed.consumeToken("[")
        let leftNumber = try parseNumber(from: &tokenFeed)
        try tokenFeed.consumeToken(",")
        let rightNumber = try parseNumber(from: &tokenFeed)
        try tokenFeed.consumeToken("]")

        let pair = SnailfishNumber(type: .pair(leftNumber, rightNumber), parent: nil)
        leftNumber.parent = pair
        rightNumber.parent = pair
        return pair
    } else {
        var stringNumber = ""
        while "0"..."9" ~= tokenFeed.currentToken! {
            stringNumber.append(tokenFeed.consumeCurrentToken()!)
        }
        let value = Int(stringNumber)!
        return SnailfishNumber(type: .regular(value), parent: nil)
    }
}

// MARK: - Puzzle logic

func addAndReduce(_ left: SnailfishNumber, _ right: SnailfishNumber) -> SnailfishNumber {
    let result = SnailfishNumber(type: .pair(left, right), parent: nil)
    left.parent = result
    right.parent = result

    var needsMoreSteps = true

    while needsMoreSteps {
        needsMoreSteps = false
        while let deepPair = findPair(from: result, withDepth: 4) {
            explode(pair: deepPair)
        }

        if let bigRegular = findRegularNumber(from: result, greaterOrEqualTo: 10) {
            split(regularNumber: bigRegular)
            needsMoreSteps = true
        }
    }

    return result
}

func findPair(from number: SnailfishNumber, withDepth depth: Int) -> SnailfishNumber? {
    switch number.type {
    case .regular:
        return nil
    case let .pair(left, right):
        if depth == 0, left.isRegular, right.isRegular {
            return number
        }
        return findPair(from: left, withDepth: depth - 1) ?? findPair(from: right, withDepth: depth - 1)
    }
}

func findRegularNumber(from number: SnailfishNumber, greaterOrEqualTo limit: Int) -> SnailfishNumber? {
    switch number.type {
    case let .regular(value) where value >= limit:
        return number
    case .regular:
        return nil
    case let .pair(left, right):
        return findRegularNumber(from: left, greaterOrEqualTo: limit)
        ?? findRegularNumber(from: right, greaterOrEqualTo: limit)
    }
}

func explode(pair: SnailfishNumber) {
    guard
        case let .pair(left, right) = pair.type,
        left.isRegular,
        right.isRegular
    else { fatalError() }
    let leftRegular = findRegularNumberToTheLeft(from: pair)
    let rightRegular = findRegularNumberToTheRight(from: pair)

    if let leftRegular = leftRegular {
        leftRegular.type = .regular(leftRegular.regularValue + left.regularValue)
    }
    if let rightRegular = rightRegular {
        rightRegular.type = .regular(rightRegular.regularValue + right.regularValue)
    }
    pair.type = .regular(0)
}

func findRegularNumberToTheLeft(from number: SnailfishNumber) -> SnailfishNumber? {
    guard
        let parent = number.parent,
        case .pair(let left, let right) = parent.type
    else { return nil }

    if number === left {
        return findRegularNumberToTheLeft(from: parent)
    }
    if number === right {
        var rightMostNumber = left
        while case let .pair(_, rightNode) = rightMostNumber.type {
            rightMostNumber = rightNode
        }
        guard case .regular = rightMostNumber.type else { fatalError() }
        return rightMostNumber
    }

    fatalError("Invalid state")
}

func findRegularNumberToTheRight(from number: SnailfishNumber) -> SnailfishNumber? {
    guard
        let parent = number.parent,
        case .pair(let left, let right) = parent.type
    else { return nil }

    if number === right {
        return findRegularNumberToTheRight(from: parent)
    }
    if number === left {
        var leftMostNumber = right
        while case let .pair(leftNode, _) = leftMostNumber.type {
            leftMostNumber = leftNode
        }
        guard case .regular = leftMostNumber.type else { fatalError() }
        return leftMostNumber
    }

    fatalError("Invalid state")
}

func split(regularNumber: SnailfishNumber) {
    guard case let .regular(value) = regularNumber.type else { fatalError() }
    let leftNumber = SnailfishNumber(type: .regular(value / 2), parent: regularNumber)
    let rightNumber = SnailfishNumber(type: .regular((value + 1) / 2), parent: regularNumber)
    regularNumber.type = .pair(leftNumber, rightNumber)
}

// MARK: - Start

main()

//test()

// MARK: - Debug

extension SnailfishNumber: CustomStringConvertible {
    var description: String {
        switch type {
        case let .regular(value):
            return String(value)
        case let .pair(left, right):
            return "[\(left.description),\(right.description)]"
        }
    }
}
