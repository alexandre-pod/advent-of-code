import Foundation

typealias InputType = [String: Set<String>]

func main() {
    var input: InputType = [:]

    while let line = readLine() {
        let nodes = line.split(separator: "-")
        let node1 = String(nodes[0])
        let node2 = String(nodes[1])
        input[node1, default: []].insert(node2)
        input[node2, default: []].insert(node1)
    }

    print(part1(connections: input))
    print(part2(connections: input))
}

// MARK: - Part 1

func part1(connections: InputType) -> Int {
//    print(connections)

    let groups = findGroupOfThree(in: connections)

//    for group in groups.sorted() {
//        print(group)
//    }
//    print("All groups count", groups.count)

    let possibleGroups = groups.filter { $0.contains { $0.hasPrefix("t") } }

//    for group in possibleGroups.sorted() {
//        print(group)
//    }
    return possibleGroups.count
}

func findGroupOfThree(in connections: InputType) -> Set<[String]> {
    var groups: Set<[String]> = []

    for (node, connectedNodes) in connections where connectedNodes.count >= 2 {
        for node1 in connectedNodes {
            let commonConnections = connections[node1, default: []].intersection(connectedNodes)

            for node2 in commonConnections {
                groups.insert([node1, node, node2].sorted())
            }
        }
    }

    return groups
}

extension [String]: @retroactive Comparable {
    public static func < (lhs: Array<Element>, rhs: Array<Element>) -> Bool {
        for (lhsElement, rhsElement) in zip(lhs, rhs) {
            if lhsElement < rhsElement {
                return true
            }
            if lhsElement > rhsElement {
                return false
            }
        }
        return false
    }
}

// MARK: - Part 2

func part2(connections: InputType) -> String {

    let groups = findGroupOfThree(in: connections)
    let possibleGroups = groups.filter { $0.contains { $0.hasPrefix("t") } }

    var cache: [Set<String>: Set<String>] = [:]
    let allGreatestGroup = possibleGroups
        .map {
            findLargestGroup(
                startingFrom: Set($0),
                connections: connections,
                cache: &cache
            )
        }

    let largestGroup = allGreatestGroup.max { $0.count < $1.count }!

//    print(largestGroup)
    return largestGroup.sorted().joined(separator: ",")
}

func findLargestGroup(
    startingFrom initialGroup: Set<String>,
    connections: InputType,
    cache: inout [Set<String>: Set<String>]
) -> Set<String> {
    assert(!initialGroup.isEmpty)

    if let value = cache[initialGroup] {
        return value
    }

    let firstNode = initialGroup.first!
    var nextCandidates = connections[firstNode, default: []]
    for node in initialGroup {
        nextCandidates.formIntersection(connections[node, default: []])
    }
    if nextCandidates.isEmpty {
        cache[initialGroup] = initialGroup
        return initialGroup
    }

    let largestGroup = nextCandidates
        .map {
            findLargestGroup(
                startingFrom: initialGroup.union([$0]),
                connections: connections,
                cache: &cache
            )
        }
        .max { $0.count < $1.count }!

    cache[initialGroup] = largestGroup
    return largestGroup
}


main()
