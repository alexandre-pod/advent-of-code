import Foundation

struct Equation {
    let result: Int
    let numbers: [Int]
}

func main() {
    var equations: [Equation] = []

    while let line = readLine() {
        let dotSplit = line.split(separator: ":")
        equations.append(
            Equation(
                result: Int(dotSplit[0])!,
                numbers: dotSplit[1].split(separator: " ", omittingEmptySubsequences: true).map { Int($0)! }
            )
        )
    }

    print(part1(equations: equations))
    print(part2(equations: equations))
}

// MARK: - Part 1

func part1(equations: [Equation]) -> Int {
    return equations
        .filter { equation in
            findOperations(forResult: equation.result, withNumbers: equation.numbers, allowingConcat: false) != nil
        }
        .map(\.result)
        .reduce(0, +)
}

enum Operation {
    case add
    case multiply
    case concat
}

func findOperations(forResult result: Int, withNumbers numbers: [Int], allowingConcat: Bool) -> [Operation]? {
    assert(!numbers.isEmpty)
    if numbers.count == 1 {
        if result == numbers[0] {
            return []
        } else {
            return nil
        }
    }

    let firstNumber = numbers[0]
    let secondNumber = numbers[1]
    if let operations = findOperations(
        forResult: result,
        withNumbers: [firstNumber + secondNumber] + numbers[2...],
        allowingConcat: allowingConcat
    ) {
        return [.add] + operations
    }
    if let operations = findOperations(
        forResult: result,
        withNumbers: [firstNumber * secondNumber] + numbers[2...],
        allowingConcat: allowingConcat
    ) {
        return [.multiply] + operations
    }
    if allowingConcat {
        let concatenatedNumber = Int(String(firstNumber) + String(secondNumber))!
        if let operations = findOperations(
            forResult: result,
            withNumbers: [concatenatedNumber] + numbers[2...],
            allowingConcat: allowingConcat
        ) {
            return [.concat] + operations
        }
    }

    return nil
}

// MARK: - Part 2

func part2(equations: [Equation]) -> Int {
    return equations
        .filter { equation in
            findOperations(forResult: equation.result, withNumbers: equation.numbers, allowingConcat: true) != nil
        }
        .map(\.result)
        .reduce(0, +)
}

main()
