import Foundation

typealias InputType = [[Int]]

func main() {
    var input: InputType = []

    while let line = readLine() {
        input.append(line.split(separator: " ").map { Int($0)! })
    }

    print(part1(inputParameter: input))
    print(part2(inputParameter: input))
}

// MARK: - Part 1

func part1(inputParameter: InputType) -> Int {
    return inputParameter.filter { $0.isReportSafe }.count
}

extension [Int] {

    var isReportSafe: Bool {
        isReportSafeAscending || isReportSafeDescending
    }

    var isReportSafeAscending: Bool {
        zip(self, self.dropFirst()).map { $0.1 - $0.0 }.allSatisfy { distance in
            (1...3).contains(distance)
        }
    }

    var isReportSafeDescending: Bool {
        zip(self, self.dropFirst()).map { $0.1 - $0.0 }.allSatisfy { distance in
            (1...3).contains(-distance)
        }
    }
}

// MARK: - Part 2

func part2(inputParameter: InputType) -> Int {
    return inputParameter.filter { $0.isReportSafePart2 }.count
}

extension [Int] {

    var isReportSafePart2: Bool {
        if isReportSafeAscending || isReportSafeDescending {
            return true
        }
        return enumerateAllAlternativeCombinations.contains {
            return $0.isReportSafe
        }
    }

    var enumerateAllAlternativeCombinations: [[Int]] {
        return indices.map { skipIndex in
            self.enumerated().filter { $0.offset != skipIndex }.map(\.element)
        }
    }
}

main()
