import Foundation

struct BagRule {
    let color: String
    let containedBagColor: [ContainedBags]
    
    struct ContainedBags: Equatable {
        let count: Int
        let color: String
    }
}


func main() {
    var rules: [BagRule] = []
    while let line = readLine() {
        rules.append(parseRule(from: line))
    }

    partOne(rules: rules)
    partTwo(rules: rules)
}

// MARK: - Parsing

func parseRule(from line: String) -> BagRule {
    let spaceSplitted = line.split(separator: " ")
    let bagColor = spaceSplitted.prefix(2).joined(separator: " ")
    assert(spaceSplitted[2] == "bags")
    assert(spaceSplitted[3] == "contain")
    return BagRule(
        color: bagColor,
        containedBagColor: parseColorAndCount(from: spaceSplitted[4...])
    )
}

func parseColorAndCount(from subsequence: ArraySlice<Substring>) -> [BagRule.ContainedBags] {
    let firstIndex = subsequence.indices.lowerBound
    guard subsequence.first != nil && subsequence.first != "no" else { return [] }
    let count = Int(subsequence[firstIndex])!
    let color = [subsequence[firstIndex + 1], subsequence[firstIndex + 2]].joined(separator: " ")
    return [BagRule.ContainedBags(count: count, color: color)]
        + parseColorAndCount(from: subsequence[(firstIndex + 4)...])
}

// MARK: - Part 1

func partOne(rules: [BagRule]) {
    var containedGraph: [String: Set<String>] = [:]
    
    for rule in rules {
        rule.containedBagColor.map(\.color).forEach { color in
            containedGraph[color, default: []].insert(rule.color)
        }
    }
    
    let initialBag = "shiny gold"
    let nodes = getDescendentNodes(from: initialBag, in: containedGraph, ignoring: [])
    print("part1: \(nodes.count)")
}

func getDescendentNodes(
    from node: String,
    in containedGraph: [String: Set<String>],
    ignoring ignoredNodes: Set<String>
) -> Set<String> {
    let newNodes = (containedGraph[node] ?? []).filter { !ignoredNodes.contains($0) }
    return Set(newNodes + newNodes.flatMap { childNode in
        getDescendentNodes(from: childNode, in: containedGraph, ignoring: ignoredNodes.union(newNodes))
    })
}

// MARK: - Part 2

func partTwo(rules: [BagRule]) {
    let initialBag = "shiny gold"
    let totalCount = countBags(for: initialBag, in: rules)
    print("part2: \(totalCount)")
    
}

func countBags(for bagColor: String, in rules: [BagRule]) -> Int {
    guard let rule = rules.first(where: { $0.color == bagColor }) else { return 0 }
    return rule.containedBagColor.reduce(0) { (count, containedBags) -> Int in
        return count + containedBags.count + containedBags.count * countBags(for: containedBags.color, in: rules)
    }
}

main()
