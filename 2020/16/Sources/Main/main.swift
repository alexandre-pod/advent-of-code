import Foundation

typealias Rule = [ClosedRange<Int>]
typealias Rules = [(name: String, rule: Rule)]
typealias Ticket = [Int]

func main() {
    let rules = parseRules()
    let yourTicket = parseYourTicket()
    let nearbyTickets = parseNearbyTickets()

    part1(rules: rules, nearbyTickets: nearbyTickets)
    part2(rules: rules, yourTicket: yourTicket, nearbyTickets: nearbyTickets)
}

func parseRules() -> Rules {
    var rules: Rules = []
    while let ruleLine = readLine(), !ruleLine.isEmpty {
        let ruleName = String(ruleLine.split(separator: ":")[0])
        let ruleValues = ruleLine.split(separator: ":")[1].trimmingCharacters(in: .whitespaces)
        let ranges = ruleValues.split(separator: " ").filter { $0 != "or" }

        let rule: Rule = ranges.map { stringRange in
            let lowerBound = Int(stringRange.split(separator: "-")[0])!
            let upperBound = Int(stringRange.split(separator: "-")[1])!
            return lowerBound...upperBound
        }
        rules.append((name: ruleName, rule: rule))
    }
    return rules
}

func parseYourTicket() -> Ticket {
    _ = readLine() // your ticket:
    let ticket = readLine()!.split(separator: ",").map { Int($0)! }
    _ = readLine() // blank line
    return ticket
}

func parseNearbyTickets() -> [Ticket] {
    _ = readLine() // nearby tickets:
    var nearbyTickets: [Ticket] = []
    while let ticketLine = readLine(), !ticketLine.isEmpty {
        nearbyTickets.append(ticketLine.split(separator: ",").map { Int($0)! })
    }
    return nearbyTickets
}

// MARK: - Part 1

func part1(rules: Rules, nearbyTickets: [Ticket]) {
    var rangesGroup = RangeGroup()
    rules.flatMap(\.rule).forEach {
        rangesGroup.addRange($0)
    }

    let allInvalidValues = nearbyTickets.flatMap { $0 }.filter { !rangesGroup.contains($0) }
    let answer = allInvalidValues.reduce(0, (+))

    print("answer: \(answer)")
}

// MARK: - Part 2

func part2(rules: Rules, yourTicket: Ticket, nearbyTickets: [Ticket]) {
    let validTickets = removeInvalidTickets(nearbyTickets, with: rules) + [yourTicket]

    let ruleRangeGroups: [RangeGroup] = rules.map { RangeGroup(from: $0.rule) }
    var ruleValidForIndex: [Set<Int>] = ruleRangeGroups.map { _ in Set(yourTicket.indices) }

    for validTicket in validTickets {
        for (index, fieldValue) in validTicket.enumerated() {
            let validRuleIndexes = ruleValidForIndex.enumerated().filter { $0.1.contains(index) }.map(\.offset)
            validRuleIndexes.forEach { ruleIndex in
                if !ruleRangeGroups[ruleIndex].contains(fieldValue) {
                    ruleValidForIndex[ruleIndex].remove(index)
                }
            }
        }
    }
    let reducedRules = reduceRuleValidForIndex(ruleValidForIndex)

    let departureIndexes = rules.enumerated().filter { $0.element.name.starts(with: "departure") }.map(\.offset)
    let allPossibleDepartureIndex = reducedRules.enumerated().filter({ departureIndexes.contains($0.offset) }).map(\.element)
    let departureIndices = Set( allPossibleDepartureIndex.flatMap { $0 } )

    let answer = departureIndices.map { yourTicket[$0] }.reduce(1, (*))
    print("answer: \(answer)")
}

func reduceRuleValidForIndex(_ ruleValidForIndex: [Set<Int>]) -> [Set<Int>] {
    var result = ruleValidForIndex
    var finishedIndexes: Set<Int> = Set()
    while
        let decidedIndex = result.enumerated()
            .filter({ !finishedIndexes.contains($0.offset) })
            .filter({ $0.element.count == 1 })
            .map(\.offset)
            .first
    {
        let lockedValue = result[decidedIndex].first!
        finishedIndexes.insert(decidedIndex)
        result.indices
            .filter { $0 != decidedIndex }
            .forEach {
            result[$0].remove(lockedValue)
        }
    }
    return result
}

func removeInvalidTickets(_ tickets: [Ticket], with rules: Rules) -> [Ticket] {
    var rangesGroup = RangeGroup()
    rules.flatMap(\.rule).forEach {
        rangesGroup.addRange($0)
    }
    return tickets.filter { $0.allSatisfy { rangesGroup.contains($0) } }
}

extension RangeGroup {
    init(from rule: Rule) {
        var group = RangeGroup()
        rule.forEach { group.addRange($0) }
        self = group
    }
}

main()
