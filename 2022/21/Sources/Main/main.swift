import Foundation

struct Monkey {
    let name: String
    let action: Action
}

enum Action {
    case number(Int)
    case operation(String, Operator, String)
}

enum Operator: Character {
    case plus = "+"
    case minus = "-"
    case divide = "/"
    case multiply = "*"
}

typealias InputType = [Monkey]

func main() {
    var input: InputType = []

    while let line = readLine() {
        let components = line.split(separator: ":")
        let name = String(components[0])
        let rightPart = components[1].trimmingCharacters(in: .whitespaces)
        let rightComponents = rightPart.split(separator: " ")
        let action: Action
        if rightComponents.count == 3 {
            action = .operation(
                String(rightComponents[0]),
                Operator(rawValue: rightComponents[1].first!)!,
                String(rightComponents[2])
            )
        } else {
            action = .number(Int(String(rightPart))!)
        }
        input.append(Monkey(name: name, action: action))
    }

    print(part1(inputParameter: input))
    print(part2(inputParameter: input))
}

// MARK: - Part 1

func part1(inputParameter: InputType) -> Int {
    var monkeyActionMap: [String: Action] = [:]

    inputParameter.forEach {
        monkeyActionMap[$0.name] = $0.action
    }

    return resolveNumber(for: "root", with: monkeyActionMap)
}

func resolveNumber(for monkey: String, with allActions: [String: Action]) -> Int {
    switch allActions[monkey]! {
    case let .number(value):
        return value
    case let .operation(monkey1, operation, monkey2):
        return operation.execute(
            resolveNumber(for: monkey1, with: allActions),
            resolveNumber(for: monkey2, with: allActions)
        )
    }
}

extension Operator {
    func execute(_ value1: Int, _ value2: Int) -> Int {
        switch self {
        case .plus:
            return value1 + value2
        case .minus:
            return value1 - value2
        case .divide:
            return value1 / value2
        case .multiply:
            return value1 * value2
        }
    }
}

// MARK: - Part 2

func part2(inputParameter: InputType) -> Int {
    var monkeyActionMap: [String: Action2] = [:]

    inputParameter.forEach {
        monkeyActionMap[$0.name] = Action2(from: $0.action)
    }

    monkeyActionMap["humn"] = .symbolicValue

    guard case let .operation(monkey1, _, monkey2) = monkeyActionMap["root"] else {
        fatalError()
    }

    let left = resolveNumber2(for: monkey1, with: monkeyActionMap)
    let right = resolveNumber2(for: monkey2, with: monkeyActionMap)

    let symbolicOperation: OperationResult
    let value: Int

    if left.isSymbolic {
        symbolicOperation = left
        value = right.asValue
    } else {
        symbolicOperation = right
        value = left.asValue
    }

    let symbolValue = resolveSymbol(fromFormula: symbolicOperation, equalTo: value)
//    print("Result:", symbolValue)
    return symbolValue
}

enum Action2 {
    case number(Int)
    case operation(String, Operator, String)
    case symbolicValue

    init(from action: Action) {
        switch action {
        case .number(let int):
            self = .number(int)
        case let .operation(monkey1, operation, monkey2):
            self = .operation(monkey1, operation, monkey2)
        }
    }
}

indirect enum OperationResult {
    case symbol
    case value(Int)
    case symbolicValue(OperationResult, Operator, OperationResult)

    var isSymbolic: Bool {
        switch self {
        case .value:
            return false
        case .symbolicValue, .symbol:
            return true
        }
    }

    var asValue: Int {
        guard case .value(let value) = self else { fatalError() }
        return value
    }
}

func resolveNumber2(for monkey: String, with allActions: [String: Action2]) -> OperationResult {
    switch allActions[monkey]! {
    case let .number(value):
        return .value(value)
    case let .operation(monkey1, operation, monkey2):
        let result1 = resolveNumber2(for: monkey1, with: allActions)
        let result2 = resolveNumber2(for: monkey2, with: allActions)
        if !result1.isSymbolic, !result2.isSymbolic {
            return .value(operation.execute( result1.asValue, result2.asValue))
        } else {
            return .symbolicValue(result1, operation, result2)
        }
    case .symbolicValue:
        return .symbol
    }
}

func resolveSymbol(fromFormula operation: OperationResult, equalTo result: Int) -> Int {
//    print("\(operation) == \(result)")
    switch operation {
    case .symbol:
        return result
    case .value:
        fatalError("Was expecting a symbolic element")
    case let .symbolicValue(left, operation, right):
        if case let .value(leftValue) = left {
            switch operation {
            case .plus:
                return resolveSymbol(fromFormula: right, equalTo: result - leftValue)
            case .minus:
                return resolveSymbol(fromFormula: right, equalTo: leftValue - result)
            case .divide:
                return resolveSymbol(fromFormula: right, equalTo: leftValue / result)
            case .multiply:
                return resolveSymbol(fromFormula: right, equalTo: result / leftValue)
            }
        } else if case let .value(rightValue) = right {
            switch operation {
            case .plus:
                return resolveSymbol(fromFormula: left, equalTo: result - rightValue)
            case .minus:
                return resolveSymbol(fromFormula: left, equalTo: result + rightValue)
            case .divide:
                return resolveSymbol(fromFormula: left, equalTo: result * rightValue)
            case .multiply:
                return resolveSymbol(fromFormula: left, equalTo: result / rightValue)
            }
        } else {
            fatalError()
        }
    }
}

extension OperationResult: CustomStringConvertible {
    var description: String {
        switch self {
        case .symbol:
            return "x"
        case .value(let int):
            return "\(int)"
        case .symbolicValue(let operationResult, let operation, let operationResult2):
            return "(\(operationResult) \(operation.rawValue) \(operationResult2))"
        }
    }
}

main()
