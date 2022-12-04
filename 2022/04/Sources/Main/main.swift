import Foundation

struct RangePair {
    let first: ClosedRange<Int>
    let second: ClosedRange<Int>
}

func main() {
    var rangePairs: [RangePair] = []

    while let line = readLine() {
        let ranges = line.split(separator: ",")
        let firstComponents = ranges[0].split(separator: "-").map { Int($0)! }
        let secondComponents = ranges[1].split(separator: "-").map { Int($0)! }
        rangePairs.append(
            RangePair(
                first: firstComponents[0]...firstComponents[1],
                second: secondComponents[0]...secondComponents[1]
            )
        )
    }

    print(part1(rangePairs: rangePairs))
    print(part2(rangePairs: rangePairs))
}

// MARK: - Part 1

func part1(rangePairs: [RangePair]) -> Int {
    return rangePairs
        .filter { $0.first.fullyContains($0.second) || $0.second.fullyContains($0.first) }
        .count
}

extension ClosedRange where Bound: Comparable {
    func fullyContains(_ range: Self) -> Bool {
        return contains(range.lowerBound) && contains(range.upperBound)
    }
}

// MARK: - Part 2

func part2(rangePairs: [RangePair]) -> Int {
    return rangePairs
        .filter { $0.first.overlaps($0.second) || $0.second.overlaps($0.first) }
        .count
}

main()
