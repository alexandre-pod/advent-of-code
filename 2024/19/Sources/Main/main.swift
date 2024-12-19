import Foundation

struct InputType {
    let patterns: [String]

    let wantedCombinations: [String]
}

func main() {

    let patterns = readLine()!.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
    _ = readLine()

    var wantedCombinations: [String] = []

    while let line = readLine() {
        wantedCombinations.append(line)
    }

    let input = InputType(
        patterns: patterns,
        wantedCombinations: wantedCombinations
    )

    print(part1(inputParameter: input))
    print(part2(inputParameter: input))
}

// MARK: - Part 1

func part1(inputParameter: InputType) -> Int {
    let possibleCombinations = inputParameter.wantedCombinations.filter {
//        print($0)
        var cache: [String: Bool] = [:]
        return canForm($0, using: inputParameter.patterns, cache: &cache)
    }

    return possibleCombinations.count
}

func canForm(_ combination: String, using patterns: [String], cache: inout [String: Bool]) -> Bool {
//    print("canForm(\(wantedCombinations), using: \(patterns))")
    guard !combination.isEmpty else { return true }
    if let result = cache[combination] {
        return result
    }
    let prefixPatterns = patterns.filter { combination.hasPrefix($0) }

    let isPossible = prefixPatterns.contains {
        let remaining = String(combination.dropFirst($0.count))
        return canForm(remaining, using: patterns, cache: &cache)
    }
    cache[combination] = isPossible
    return isPossible
}

// MARK: - Part 2

func part2(inputParameter: InputType) -> Int {

    let arrangementsCounts = inputParameter.wantedCombinations.map {
//        print($0)
        var cache: [String: Int] = [:]
        return possibleTowelArrangementCount(for: $0, using: inputParameter.patterns, cache: &cache)
    }

    return arrangementsCounts.reduce(0, +)
}

func possibleTowelArrangementCount(for combination: String, using patterns: [String], cache: inout [String: Int]) -> Int {
//    print("towelArrangementFor(\(combination), using: patterns, cache: cache)")
    guard !combination.isEmpty else { return 1 }
    if let result = cache[combination] {
        return result
    }
    let prefixPatterns = patterns.filter { combination.hasPrefix($0) }

    let count = prefixPatterns.map {
        let remaining = String(combination.dropFirst($0.count))
        return possibleTowelArrangementCount(for: remaining, using: patterns, cache: &cache)
    }.reduce(0, +)

    cache[combination] = count
    return count
}

//func towelArrangementFor(_ combination: String, using patterns: [String], cache: inout [String: [[String]]]) -> [[String]]? {
//    print("towelArrangementFor(\(combination), using: patterns, cache: cache)")
//    guard !combination.isEmpty else { return [[]] }
//    if let result = cache[combination] {
//        return result
//    }
//    let prefixPatterns = patterns.filter { combination.hasPrefix($0) }
//
//    var possibilities: [[String]] = []
//
//    for pattern in prefixPatterns {
//        let remaining = String(combination.dropFirst(pattern.count))
//        if let arrangement = towelArrangementFor(remaining, using: patterns, cache: &cache) {
//            possibilities.append(contentsOf: arrangement.map { [pattern] + $0 })
//        }
//    }
//
//    if possibilities.isEmpty {
//        return nil
//    }
//
//    cache[combination] = possibilities
//    return possibilities
//}

main()
