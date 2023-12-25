import Foundation

typealias Links = [(String, [String])]

func main() {
    var input: Links = []

    while let line = readLine() {
        let parts = line.split(separator: ":")
        let left = String(parts[0])
        let right = String(parts[1]).trimmingCharacters(in: .whitespaces).split(separator: " ").map { String($0) }
        input.append((left, right))
    }

//    part1(links: input)
    print(part1(links: input))
//    print(part2(links: input))
}

// MARK: - Part 1

func part1Visualization(links: Links) -> Int {

    var edges: [String: Set<String>] = [:]

    links.forEach { (edge, connectedTo) in
        connectedTo.forEach {
            edges[edge, default: []].insert($0)
            edges[$0, default: []].insert(edge)

        }
    }

    //    graph {
    //        a -- b;
    //        b -- c;
    //        a -- c;
    //        d -- c;
    //        e -- c;
    //        e -- a;
    //    }

    print("graph {")

    links.forEach { (edge, connectedTo) in
        connectedTo.forEach {
            print("    \(edge) -- \($0)")

        }
    }

    print("}")

    // swift run < sample > graph-input.dot
    // sfdp -x -Tsvg graph-input.dot > tmp.svg

    let toCutEdges: [Edge] = [
        Edge(node1: "sgc", node2: "xvk"),
        Edge(node1: "cvx", node2: "dph"),
        Edge(node1: "pzc", node2: "vps")
    ]


    var splitedEdges = edges
    toCutEdges.forEach {
        splitedEdges.without($0)
    }

    let dikjstraDistances = dikjstra(from: "sgc", edges: splitedEdges)

    print("dikjstraDistances count", dikjstraDistances.count)
    print("edges.keys.count", edges.keys.count)

    let group1 = edges.keys.count - dikjstraDistances.count
    let group2 = edges.keys.count - group1

    return group1 * group2
}

func part1(links: Links) -> Int {
    var edges: [String: Set<String>] = [:]

    links.forEach { (edge, connectedTo) in
        connectedTo.forEach {
            edges[edge, default: []].insert($0)
            edges[$0, default: []].insert(edge)

        }
    }

    print(edges.keys)
    edges.forEach {
        print("\($0.key) : \($0.value.count)")
    }

//    let dikjstra = dikjstra(from: "jqt", edges: edges)
//    print(dikjstra)

//    print(allNodesAccessible(in: edges))
//    print(edges.allEdges.count)
//
//    let edgesCombinations = allThreeCombination(of: edges.allEdges)
//
//    print(edgesCombinations.count)

    let largestGroup = largestPartialGroup(fromGroup: [links.first!.0], remainingCutLines: 3, edges: edges)!
    print(largestGroup)

    let group1 = edges.keys.count - largestGroup.count
    let group2 = edges.keys.count - group1
    return group1 * group2
}

extension EdgeGraph where Value == Set<Key> {
    mutating func without(_ edge: Edge<Key>) {
        self[edge.node1]?.remove(edge.node2)
        self[edge.node2]?.remove(edge.node1)
    }
}

var cache: [CacheKey: Set<String>] = [:]

struct CacheKey: Hashable {
    let group: Set<String>
    let remainingCutLines: Int
    let edges: EdgeGraph<String>
}

func largestPartialGroup(
    fromGroup group: Set<String>,
    remainingCutLines: Int,
    edges: EdgeGraph<String>,
    callDepth: Int = 0
) -> Set<String>? {

    if group.count == edges.keys.count {
        return []
    }

    let cacheKey = CacheKey(group: group, remainingCutLines: remainingCutLines, edges: edges)

    if let value = cache[cacheKey] {
        return value
    }

    let neighbours = group.flatMap { edges[$0] ?? [] }.filter { !group.contains($0) }

    guard !neighbours.isEmpty else {
        if group.count < edges.keys.count {
            print("FOUND: \(group)")
            cache[cacheKey] = group
            return group
        }
        cache[cacheKey] = []
        return []
    }

    let biggestByAdding = neighbours
        .compactMap {
            largestPartialGroup(
                fromGroup: group.union([$0]),
                remainingCutLines: remainingCutLines,
                edges: edges,
                callDepth: callDepth + 1
            )
        }
        .max { $0.count < $1.count }

    guard remainingCutLines > 0 else {
        cache[cacheKey] = biggestByAdding
        return biggestByAdding
    }

    let neighborsEdges = group.flatMap { node in
        (edges[node] ?? []).map { Edge(node1: node, node2: $0) }
    }

//    print("\(callDepth) neighborsEdges: \(neighborsEdges)")

//    print("[\(callDepth)] biggestByCutting")
    let biggestByCutting = neighborsEdges
        .compactMap {
            var updatedEdges = edges
            updatedEdges[$0.node1]?.remove($0.node2)
            updatedEdges[$0.node2]?.remove($0.node1)
            return largestPartialGroup(
                fromGroup: group,
                remainingCutLines: remainingCutLines - 1,
                edges: updatedEdges,
                callDepth: callDepth + 1
            )
        }
        .max { $0.count < $1.count }

//    if let biggestByAdding {
//        print("[\(callDepth)] biggestByAdding", biggestByAdding)
//    }
//    if let biggestByCutting {
//        print("[\(callDepth)] biggestByCutting", biggestByCutting)
//    }

    let bestGroup = [biggestByAdding, biggestByCutting].compactMap { $0 }.max { $0.count < $1.count }

    cache[cacheKey] = bestGroup

    return bestGroup
}

func allThreeCombination<T>(of array: [T]) -> [(T, T, T)] {
    return (0..<(array.count - 2)).flatMap { i1 -> [(T, T, T)] in
        (i1..<(array.count - 1)).flatMap { i2 -> [(T, T, T)] in
            (i2..<array.count).map { i3 -> (T, T, T) in
                (array[i1], array[i2], array[i3])
            }
        }
    }
}

func splitGroups(
    from edges: [String: Set<String>],
    withAllowedCuts allowedCuts: Int
) -> (Set<String>, Set<String>) {

    var group1: Set<String> = []
    var nearGroup1: Set<String> = []

    let (node, neighbours) = edges.first!

    group1.insert(node)
    nearGroup1.formUnion(neighbours)


    fatalError()
}

typealias EdgeGraph<Node: Hashable> = [Node: Set<Node>]

func allNodesAccessible(in edges: EdgeGraph<String>) -> Bool {
    let dikjstra = dikjstra(from: "jqt", edges: edges)
    return dikjstra.keys.count == edges.keys.count
}

func dikjstra(from node: String, edges: [String: Set<String>]) -> [String: Int] {
    var distances: [String: Int] = [node: 0]

    var done: Set<String> = []
    var toProcess: Set<String> = [node]


    while !toProcess.isEmpty {
        let closest = toProcess.min { distances[$0]! < distances[$1]! }!

        toProcess.remove(closest)
        done.insert(closest)

        (edges[closest] ?? []).filter { !done.contains($0) }.forEach {
            toProcess.insert($0)
            distances[$0] = distances[closest]! + 1
        }
    }

    return distances
}

extension EdgeGraph where Value == Set<Key> {

    var allEdges: [Edge<Key>] {
        var edges: Set<Edge<Key>> = []

        keys.forEach { node in
            self[node]?.forEach { neighbor in
                if edges.contains(Edge(node1: node, node2: neighbor))
                    || edges.contains(Edge(node1: neighbor, node2: node)) { return }
                edges.insert(Edge(node1: node, node2: neighbor))
            }
        }

        return Array(edges)
    }
}

struct Edge<Node: Hashable>: Hashable {
    let node1: Node
    let node2: Node
}

// MARK: - No Part 2 - Day 25

//func part2(links: Links) -> Int {
//    fatalError()
//}

main()
