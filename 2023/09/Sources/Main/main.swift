import Foundation

typealias Histories = [History]

typealias History = [Int]

func main() {
    var histories: Histories = []

    while let line = readLine() {
        histories.append(line.split(separator: " ").map { Int(String($0))! })
    }

    print(part1(histories: histories))
    print(part2(histories: histories))
}

// MARK: - Part 1

func part1(histories: Histories) -> Int {
    return histories.map(\.extrapolatedValue).reduce(0, +)
}

extension History {

    var extrapolatedValue: Int {
        assert(!isEmpty)
        let firstValue = first!
        if allSatisfy({ $0 == firstValue }) {
            return firstValue
        }

        let differences = zip(self, self[1...]).map { $0.1 - $0.0 }

        let extrapolatedDifference = differences.extrapolatedValue
        return last! + extrapolatedDifference
    }

    var backwardExtrapolatedValue: Int {
        assert(!isEmpty)
        let firstValue = first!
        if allSatisfy({ $0 == firstValue }) {
            return firstValue
        }

        let differences = zip(self, self[1...]).map { $0.1 - $0.0 }

        let extrapolatedDifference = differences.backwardExtrapolatedValue
        return firstValue - extrapolatedDifference
    }
}

// MARK: - Part 2

func part2(histories: Histories) -> Int {
    return histories.map(\.backwardExtrapolatedValue).reduce(0, +)
}

main()
