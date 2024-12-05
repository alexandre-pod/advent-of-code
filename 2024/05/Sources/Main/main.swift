import Foundation

struct InputType {
    var rules: [PageOrderRule]
    var prints: [[Int]]
}

struct PageOrderRule {
    let first: Int
    let second: Int
}

func main() {
    var rules: [PageOrderRule] = []
    var prints: [[Int]] = []

    while let line = readLine(), !line.isEmpty {
        let numbers = line.split(separator: "|").map { Int($0)! }
        rules.append(PageOrderRule(first: numbers[0], second: numbers[1]))
    }

    while let line = readLine(), !line.isEmpty {
        prints.append(line.split(separator: ",").map { Int($0)! })
    }

    let input = InputType(rules: rules, prints: prints)

    print(part1(inputParameter: input))
    print(part2(inputParameter: input))
}

// MARK: - Part 1

func part1(inputParameter: InputType) -> Int {
//    print(inputParameter)

    var followingPages: [Int: [Int]] = [:]
    for rule in inputParameter.rules {
        followingPages[rule.first, default: []].append(rule.second)
    }

    return inputParameter.prints
        .filter { isPrintOrderValid($0, followingPages: followingPages) }
        .map { $0[$0.count / 2] }
        .reduce(0, +)
}

func isPrintOrderValid(_ print: [Int], followingPages: [Int: [Int]]) -> Bool {
    var invalidPages: Set<Int> = []
    for page in print.reversed() {
        guard !invalidPages.contains(page) else { return false }
        invalidPages.formUnion(followingPages[page, default: []])
    }
    return true
}

// MARK: - Part 2

func part2(inputParameter: InputType) -> Int {

    var followingPages: [Int: [Int]] = [:]
    var precedingPages: [Int: [Int]] = [:]
    for rule in inputParameter.rules {
        followingPages[rule.first, default: []].append(rule.second)
        precedingPages[rule.second, default: []].append(rule.first)
    }

    let invalidPrints = inputParameter.prints.filter { !isPrintOrderValid($0, followingPages: followingPages) }

    var result = 0

    for invalidPrint in invalidPrints {
//        print(invalidPrint)
//        for rule in concernedRules {
//            print(rule)
//        }

        let validOrder = findValidOrder(for: Set(invalidPrint), withRules: inputParameter.rules)
//        print("Fixed: ", validOrder)
        result += validOrder[validOrder.count / 2]
    }

    return result
}

func findValidOrder(for pages: Set<Int>, withRules rules: [PageOrderRule]) -> [Int] {
    if pages.count <= 1 { return Array(pages) }
    let concernedRules = rules.filter {
        pages.contains($0.first) && pages.contains($0.second)
    }

    let firstPage = pages.first { firstCandidate in
        return concernedRules.allSatisfy { $0.second != firstCandidate }
    }!

    return [firstPage] + findValidOrder(for: pages.subtracting([firstPage]), withRules: concernedRules)
}

main()

extension PageOrderRule: CustomStringConvertible {

    var description: String {
        "\(first)|\(second)"
    }
}
