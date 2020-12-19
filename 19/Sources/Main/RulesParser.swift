//
//  RulesParser.swift
//  
//
//  Created by Alexandre Podlewski on 19/12/2020.
//

import Foundation

extension Rule {
    struct Raw {
        typealias ID = Int
        let id: ID
        var character: Character?
        var subRulesID: [[ID]] = []
    }
}

func parseRawRules() -> [Rule.Raw.ID: Rule.Raw] {
    var rawInputs: [Rule.Raw.ID: Rule.Raw] = [:]

    while let line = readLine(), !line.isEmpty {
        let rawInput = parseRuleLine(line)
        rawInputs[rawInput.id] = rawInput
    }

    return rawInputs
}

func buildRule(id: Rule.Raw.ID, from rawInputs: [Rule.Raw.ID: Rule.Raw]) -> Rule {
    let rawInput = rawInputs[id]!

    if let character = rawInput.character {
        return .match(character: character)
    }
    let subRules = rawInput.subRulesID.map { ruleList in
        ruleList.map { buildRule(id: $0, from: rawInputs) }
    }
    return .oneOf(subRules)
}

// MARK: - Private

private func parseRuleLine(_ line: String) -> Rule.Raw {
    let idSplit = line.split(separator: ":")
    var input = Rule.Raw(id: Int(idSplit[0])!)
    let ruleContent = idSplit[1].trimmingCharacters(in: .whitespaces)
    guard ruleContent.first != "\"" else {
        input.character = ruleContent[ruleContent.index(ruleContent.startIndex, offsetBy: 1)]
        return input
    }

    let subrulesID = ruleContent.split(separator: "|")
        .map { $0.trimmingCharacters(in: .whitespaces) }
        .map { $0.split(separator: " ").map { Int($0)! } }
    input.subRulesID = subrulesID
    return input
}
