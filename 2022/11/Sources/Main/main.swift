import Foundation

typealias Monkeys = [Monkey]

struct Monkey {
    var items: [Int]
    let operation: (Int) -> Int
    let divisibleTestValue: Int
    let monkeyWhenTestTrue: Int
    let monkeyWhenTestFalse: Int
}

func main() {
    var input: Monkeys = []

    while let monkey = parseMonkey() {
        input.append(monkey)
    }

    print(part1(monkeys: input))
    print(part2(monkeys: input))
}

private func parseMonkey() -> Monkey? {
    guard
        let firstLine = readLine(),
        firstLine.starts(with: "Monkey ")
    else { return nil }
    let startingItemsLine = readLine()!
    let operationLine = readLine()!
    let testLine = readLine()!
    let testTrueLine = readLine()!
    let testFalseLine = readLine()!
    _ = readLine() // empty line

    let startingItems = startingItemsLine.split(separator: ":")[1]
        .split(separator: ",")
        .map { $0.trimmingCharacters(in: .whitespaces) }
        .filter { !$0.isEmpty }
        .map { Int(String($0))! }

    let operationLineComponents = operationLine.split(separator: " ")
    let operationValueString = String(operationLineComponents.last!)

    let otherValue: (Int) -> Int = {
        if operationValueString == "old" {
            return $0
        } else {
            return Int(operationValueString)!
        }
    }

    let operation: (Int) -> Int
    switch operationLineComponents[operationLineComponents.count - 2] {
    case "*":
        operation = { $0 * otherValue($0) }
    case "+":
        operation = { $0 + otherValue($0) }
    default:
        fatalError("Unknown operator")
    }

    let divisibleByValue = Int(String(testLine.split(separator: " ").last!))!
    let trueTarget = Int(String(testTrueLine.split(separator: " ").last!))!
    let falseTarget = Int(String(testFalseLine.split(separator: " ").last!))!

    return Monkey(
        items: startingItems,
        operation: operation,
        divisibleTestValue: divisibleByValue,
        monkeyWhenTestTrue: trueTarget,
        monkeyWhenTestFalse: falseTarget
    )
}

// MARK: - Part 1

func part1(monkeys: Monkeys) -> Int {
    var monkeys = monkeys
//    printMonkeysItems(round: 0, monkeys: monkeys)
    var inspectionCount: [Int: Int] = [:]
    for round in 1...20 {
        monkeys = executeRound(monkeys: monkeys, inspectionCount: &inspectionCount, turnType: .part1)
//        printMonkeysItems(round: round, monkeys: monkeys)
    }

//    print(inspectionCount)
    return inspectionCount.values.sorted().suffix(2).reduce(1, *)
}

func executeRound(monkeys: Monkeys, inspectionCount: inout [Int: Int], turnType: TurnType) -> Monkeys {
    var monkeys = monkeys
    monkeys.indices.forEach {
        inspectionCount[$0, default: 0] += monkeys[$0].items.count
        executeTurn(forMonkeyAtIndex: $0, monkeys: &monkeys, turnType: turnType)
    }
    return monkeys
}

enum TurnType {
    case part1
    case part2(pgcd: Int)
}

func executeTurn(forMonkeyAtIndex index: Int, monkeys: inout Monkeys, turnType: TurnType) {
    let monkey = monkeys[index]
    for item in monkey.items {
        let value: Int
        switch turnType {
        case .part1:
            value = monkey.operation(item) / 3
        case .part2(let pgcd):
            value = monkey.operation(item) % pgcd
//            (96577) // (9699690 * 29)
        }
//        let value = (monkey.operation(item) / (turnType ? 3 : 1)) % 9699690
        if value.isMultiple(of: monkey.divisibleTestValue) {
            monkeys[monkey.monkeyWhenTestTrue].items.append(value)
        } else {
            monkeys[monkey.monkeyWhenTestFalse].items.append(value)
        }
    }
    monkeys[index].items.removeAll()
}

func printMonkeysItems(round: Int, monkeys: Monkeys) {
    print("Round \(round)")
    for (index, monkey) in monkeys.enumerated() {
        print("Monkey \(index):", monkey.items.map { String($0) }.joined(separator: ", "))
    }
    print()
}

// MARK: - Part 2

func part2(monkeys: Monkeys) -> Int {

    // in sample and input, all the factors are prime numbers, so we can just multiply them, and then do modular arithmetic
    let pgcd = monkeys.map(\.divisibleTestValue).reduce(1, *)

    var monkeys = monkeys
//    printMonkeysItems(round: 0, monkeys: monkeys)
    var inspectionCount: [Int: Int] = [:]
    for round in 1...10000 {
        monkeys = executeRound(monkeys: monkeys, inspectionCount: &inspectionCount, turnType: .part2(pgcd: pgcd))
//        printMonkeysItems(round: round, monkeys: monkeys)
//        if round.isMultiple(of: 1000) || round == 1 || round == 20 {
//            print("Round \(round)")
//            printInspectionCount(inspectionCount)
//        }
    }

    return inspectionCount.values.sorted().suffix(2).reduce(1, *)
}

func printInspectionCount(_ inspectionCount: [Int: Int]) {
    for key in inspectionCount.keys.sorted() {
        print("Monkey \(key):", inspectionCount[key, default: 0])
    }
}

main()
