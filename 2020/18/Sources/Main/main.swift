import Foundation

indirect enum GroupedTokens: Equatable {
    case multiply
    case add
    case value(Int)
    case group([GroupedTokens])
}

func main() {
    var groupedTokens: [GroupedTokens] = []

    while let line = readLine() {
        groupedTokens.append(parseLine(line))
    }

    part1(groupedTokens: groupedTokens)
    part2(groupedTokens: groupedTokens)
}

func parseLine(_ line: String) -> GroupedTokens {
    let cleanedLine = line.filter { $0 != " " }
    return parseGroupToken(cleanedLine, fromIndex: cleanedLine.startIndex).0
}

func parseGroupToken(_ line: String, fromIndex startIndex: String.Index) -> (GroupedTokens, endIndex: String.Index) {
    guard startIndex < line.endIndex else { return (.group([]), startIndex) }

    var groupResult: [GroupedTokens] = []

    var currentIndex = startIndex
    while currentIndex < line.endIndex {
        switch line[currentIndex] {
        case "(":
            let (group, nextIndex) = parseGroupToken(line, fromIndex: line.index(currentIndex, offsetBy: 1))
            groupResult.append(group)
            currentIndex = nextIndex
        case ")":
            return (.group(groupResult), endIndex: line.index(currentIndex, offsetBy: 1))
        default:
            groupResult.append(parseUniqueToken(line, atIndex: currentIndex))
            currentIndex = line.index(currentIndex, offsetBy: 1)
        }
    }

    return (.group(groupResult), startIndex)
}

func parseUniqueToken(_ line: String, atIndex startIndex: String.Index) -> GroupedTokens {
    switch line[startIndex] {
    case "0"..."9":
        return .value(Int(String(line[startIndex]))!)
    case "+":
        return .add
    case "*":
        return .multiply
    default:
        fatalError("Unrecognized token at index: \(startIndex) (\(line[startIndex]))")
    }
}

// MARK: - Part 1

func part1(groupedTokens: [GroupedTokens]) {
    let operations = groupedTokens.map { $0.part1Operations() }
    let values = operations.map { $0.evaluate() }

    let answer = values.reduce(0, (+))
    print("answer: \(answer)")
}

extension GroupedTokens {
    func part1Operations() -> Operation {
        switch self {
        case .multiply, .add:
            fatalError("Invalid syntax")
        case let .value(value):
            return Value(value: value)
        case let .group(tokens):
            return tokens.groupOperationsPart1()
        }
    }
}

extension Array where Element == GroupedTokens {

    func groupOperationsPart1() -> Operation {
        var leftOperation: Operation

        var currentToken = 0
        switch self[currentToken] {
        case let .value(value):
            leftOperation = Value(value: value)
        case let .group(tokens):
            leftOperation = tokens.groupOperationsPart1()
        default:
            fatalError()
        }
        currentToken = 1

        while self.indices.contains(currentToken) {
            switch self[currentToken] {
            case .multiply:
                let rightOperation = self[currentToken + 1].part1Operations()
                leftOperation = Multiplication(a: leftOperation, b: rightOperation)
                currentToken += 2
            case .add:
                let rightOperation = self[currentToken + 1].part1Operations()
                leftOperation = Addition(a: leftOperation, b: rightOperation)
                currentToken += 2
            default:
                fatalError()
            }
        }

        return leftOperation
    }
}

// MARK: - Part 2

func part2(groupedTokens: [GroupedTokens]) {

//    groupedTokens.forEach {
//        print("=====")
//        print($0)
//        print($0.groupAddFirst())
//        print($0.part2Operations())
//        print($0.part2Operations().evaluate())
//    }

    let operations = groupedTokens.map { $0.part2Operations() }
    let values = operations.map { $0.evaluate() }
    let answer = values.reduce(0, (+))
    print("answer: \(answer)")
}



extension GroupedTokens {
    func part2Operations() -> Operation {
        switch self {
        case .multiply, .add:
            fatalError("Invalid syntax")
        case let .value(value):
            return Value(value: value)
        case let .group(tokens):
            return tokens.groupOperationsAddFirst()
        }
    }

    func groupAddFirst() -> GroupedTokens {
        switch self {
        case .multiply, .add, .value:
            return self
        case let .group(tokens):
            return .group(tokens.groupRemainingAdditions())
        }
    }
}

extension Array where Element == GroupedTokens {

    func groupOperationsAddFirst() -> Operation {
        return groupRemainingAdditions().groupOperationsPart1()
    }

    var containsUngroupedAdditions: Bool {
        return self.count > 3 && self.contains(.add)
    }

    func groupRemainingAdditions() -> [GroupedTokens] {
        var copy = self.map { $0.groupAddFirst() }
        guard count > 3, let firstAddIndex = firstIndex(of: .add) else {
            return copy
        }
        let rightToken = copy.remove(at: firstAddIndex + 1)
        let addToken = copy.remove(at: firstAddIndex)
        let leftToken = copy.remove(at: firstAddIndex - 1)

        copy.insert(.group([leftToken, addToken, rightToken]), at: firstAddIndex - 1)

        while copy.containsUngroupedAdditions {
            copy = copy.groupRemainingAdditions()
        }

        return copy
    }
}

// MARK: - Debug

extension GroupedTokens: CustomStringConvertible {
    var description: String {
        switch self {
        case .multiply:
            return "*"
        case .add:
            return "+"
        case let .value(value):
            return String(value)
        case let .group(elements):
            return "[" + elements.map(\.description).joined() + "]"
        }
    }
}

extension Value: CustomStringConvertible {
    var description: String {
        return String(value)
    }
}

extension Addition: CustomStringConvertible {
    var description: String {
        return "(" + a.description + " + " + b.description + ")"
    }
}

extension Multiplication: CustomStringConvertible {
    var description: String {
        return "(" + a.description + " * " + b.description + ")"
    }
}

main()
