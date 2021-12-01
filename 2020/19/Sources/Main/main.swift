import Foundation

indirect enum Rule: Hashable {
    case match(character: Character)
    case oneOf([[Rule]])
}

func main() {
    let rawRules = parseRawRules()
    let messages = parseMessages()

    part1(rawRules: rawRules, messages: messages)
    part2(rawRules: rawRules, messages: messages)
}

func parseMessages() -> [String] {
    var messages: [String] = []
    while let line = readLine(), !line.isEmpty {
        messages.append(line)
    }
    return messages
}

// MARK: - Part 1

func part1(rawRules: [Rule.Raw.ID: Rule.Raw], messages: [String]) {
    let rule0 = buildRule(id: 0, from: rawRules)
    let answer = messages.filter { isMessageValid($0, for: rule0) }.count
    print("answer: \(answer)")
}

func isMessageValid(_ message: String, for rule: Rule) -> Bool {
    let validEndIndicies = validEndIndiciesMessages(
        message,
        for: rule,
        fromIndex: message.startIndex
    )
    return validEndIndicies.contains(message.endIndex)
}

func validEndIndiciesMessages(
    _ message: String,
    for rule: Rule,
    fromIndex index: String.Index
) -> [String.Index]  {
    guard index <= message.endIndex else { return [message.endIndex] }
    switch rule {
    case let .match(character):
        if message[index] == character {
            return [message.index(after: index)]
        } else {
            return []
        }
    case let .oneOf(possibleRules):
        var validEndIndicies: [String.Index] = []
        for rulesSet in possibleRules {
            validEndIndicies.append(contentsOf: validEndIndiciesMessages(message, for: rulesSet, fromIndex: index))
        }
        return validEndIndicies
    }
}

func validEndIndiciesMessages(
    _ message: String,
    for rules: [Rule],
    fromIndex index: String.Index
) -> [String.Index]  {
    guard !rules.isEmpty else {
        return [index]
    }
    return validEndIndiciesMessages(message, for: rules[0], fromIndex: index)
        .flatMap {
            validEndIndiciesMessages(message, for: Array(rules[1...]), fromIndex: $0)
        }
}

// MARK: - Part2

func part2(rawRules: [Rule.Raw.ID: Rule.Raw], messages: [String]) {
    var patchedRawRules = rawRules
    patchedRawRules[8] = Rule.Raw(id: 8, character: nil, subRulesID: [[42], [42, 8]])
    patchedRawRules[11] = Rule.Raw(id: 11, character: nil, subRulesID: [[42, 31], [42, 11, 31]])

    let answer = messages.filter { isMessageValid2($0, forRawRules: patchedRawRules) }.count
    print("answer: \(answer)")
}

func isMessageValid2(_ message: String, forRawRules rawRules: [Rule.Raw.ID: Rule.Raw]) -> Bool {
    let validEndIndicies = validEndIndiciesMessages2(
        message,
        for: rawRules[0]!,
        fromIndex: message.startIndex,
        rawRules: rawRules
    )
    return validEndIndicies.contains(message.endIndex)
}

func validEndIndiciesMessages2(
    _ message: String,
    for rule: Rule.Raw,
    fromIndex index: String.Index,
    rawRules: [Rule.Raw.ID: Rule.Raw]
) -> [String.Index]  {
    guard index < message.endIndex else { return [] }
    if let character = rule.character {
        if message[index] == character {
            return [message.index(after: index)]
        } else {
            return []
        }
    } else {
        var validEndIndicies: [String.Index] = []
        for rulesSet in rule.subRulesID {
            validEndIndicies.append(
                contentsOf: validEndIndiciesMessages2(
                    message,
                    for: rulesSet.map { rawRules[$0]! },
                    fromIndex: index,
                    rawRules: rawRules
                )
            )
        }
        return validEndIndicies
    }
}

func validEndIndiciesMessages2(
    _ message: String,
    for rules: [Rule.Raw],
    fromIndex index: String.Index,
    rawRules: [Rule.Raw.ID: Rule.Raw]
) -> [String.Index]  {
    guard !rules.isEmpty else {
        return [index]
    }
    return validEndIndiciesMessages2(message, for: rules[0], fromIndex: index, rawRules: rawRules)
        .flatMap {
            validEndIndiciesMessages2(message, for: Array(rules[1...]), fromIndex: $0, rawRules: rawRules)
        }
}

// MARK: - Debug

extension Rule: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case let .match(character):
            return String(character)
        case let .oneOf(rulesList):
            return rulesList.map(\.debugDescription).joined(separator: " | ")
        }
    }
}

main()
