import Foundation

let debugPrint = false

struct Node: Identifiable, Hashable {
    let id: String

    var isBig: Bool {
        return id.first?.isUppercase ?? false
    }
}

typealias GraphEdges = [Node: Set<Node>]

// MARK: - Main

func main() {

    var edges: GraphEdges = [:]

    while let lineComponents = readLine()?.split(separator: "-").map({ Node(id: String($0)) }) {
        let start = lineComponents[0]
        let end = lineComponents[1]

        edges[start, default: []].insert(end)
        edges[end, default: []].insert(start)
    }

    print(part1(edges: edges))
    print(part2(edges: edges))
}

// MARK: - Part 1

func part1(edges: GraphEdges) -> Int {

    let startNode = Node(id: "start")
    let endNode = Node(id: "end")

    if debugPrint {
        edges.forEach {
            print($0, $1)
        }
    }

    return countPaths(from: startNode, to: endNode, edges: edges, seenSmallNodes: [], currentPath: [])
}

func countPaths(
    from startNode: Node,
    to endNode: Node,
    edges: GraphEdges,
    seenSmallNodes: Set<Node>,
    currentPath: [Node]
) -> Int {
    if startNode == endNode {
        if debugPrint {
            print((currentPath + [endNode]).map(\.id).joined(separator: "->"))
        }
        return 1
    }

    let updatedSeenSmallNodes = startNode.isBig ? seenSmallNodes : seenSmallNodes.union([startNode])

    return edges[startNode, default: []]
        .filter {
            $0.isBig || !seenSmallNodes.contains($0)
        }
        .reduce(0) { partialResult, nextNode in
            return partialResult + countPaths(
                from: nextNode,
                to: endNode,
                edges: edges,
                seenSmallNodes: updatedSeenSmallNodes,
                currentPath: currentPath + [startNode]
            )
        }
}

// MARK: - Part 2

func part2(edges: GraphEdges) -> Int {

    return countPaths2(
        from: Node(id: "start"),
        to: Node(id: "end"),
        edges: edges,
        seenSmallNodes: [],
        currentPath: []
    )
}

func countPaths2(
    from startNode: Node,
    to endNode: Node,
    edges: GraphEdges,
    seenSmallNodes: Set<Node>,
    currentPath: [Node]
) -> Int {
    if startNode == endNode {
        if debugPrint {
            print((currentPath + [endNode]).map(\.id).joined(separator: "->"))
        }
        return 1
    }

    let updatedSeenSmallNodes = startNode.isBig ? seenSmallNodes : seenSmallNodes.union([startNode])

    return edges[startNode, default: []]
        .filter { $0 != Node(id: "start") }
        .reduce(0) { partialResult, nextNode in
            if seenSmallNodes.contains(nextNode) {
                return partialResult + countPaths(
                    from: nextNode,
                    to: endNode,
                    edges: edges,
                    seenSmallNodes: updatedSeenSmallNodes,
                    currentPath: currentPath + [startNode]
                )
            } else {
                return partialResult + countPaths2(
                    from: nextNode,
                    to: endNode,
                    edges: edges,
                    seenSmallNodes: updatedSeenSmallNodes,
                    currentPath: currentPath + [startNode]
                )
            }
        }
}

main()
