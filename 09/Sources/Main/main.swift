import Foundation

func main() {
    var numbers: [Int] = []
    while let line = readLine() {
        numbers.append(Int(line)!)
    }
    part1(numbers: numbers)
    part2(numbers: numbers)
}

// MARK: - Part 1

func part1(numbers: [Int]) {
    let preamble = 25
    let invalidNumber = isXMASValid(numbers: numbers, preamble: preamble)

    if let number = invalidNumber {
        print("invalidNumber: \(number)")
    } else {
        print("no invalidNumber")
    }
}

/// Returns nil if the numbers are respecting XMAS, the invalid number otherwise
func isXMASValid(numbers: [Int], preamble: Int) -> Int? {
    guard numbers.count > preamble else { return nil }
    for index in (preamble + 1)...numbers.indices.upperBound {
        let preambleNumbers = numbers[((index - preamble - 1)..<index)]
        if !numbers[index].isSumOfTwoElements(in: Array(preambleNumbers)) {
            return numbers[index]
        }
    }
    return nil
}

extension Int {
    func isSumOfTwoElements(in numbers: [Int]) -> Bool {
        for (index1, number1) in numbers.enumerated() {
            for (index2, number2) in numbers.enumerated() where index2 != index1 {
                if number1 + number2 == self {
                    return true
                }
            }
        }
        return false
    }
}

// MARK: - Part 2

func part2(numbers: [Int]) {
    let invalidNumber = isXMASValid(numbers: numbers, preamble: 25)

    guard let number = invalidNumber else {
        return print("no invalidNumber")
    }

    guard
        let (minIndex, maxIndex) = findContiguousElementsThatSum(to: number, from: numbers)
    else {
        return print("no contiguous find")
    }

    let minValue = numbers[minIndex...maxIndex].min()!
    let maxValue = numbers[minIndex...maxIndex].max()!

    print("Answer: \(minValue + maxValue)")
}

func findContiguousElementsThatSum(to value: Int, from elements: [Int]) -> (Int, Int)? {
    var lowerBound = 0
    var upperIncludedBound = 0

    while upperIncludedBound < elements.count {
        let sum = elements[lowerBound...upperIncludedBound].reduce(0, (+))
        switch sum {
        case value:
            return (lowerBound, upperIncludedBound)
        case _ where sum > value:
            if lowerBound + 1 <= upperIncludedBound {
                lowerBound += 1
            } else {
                lowerBound += 1
                upperIncludedBound += 1
            }
        case _ where sum < value:
            upperIncludedBound += 1
        default:
            fatalError()
        }
    }
    return nil
}

main()
