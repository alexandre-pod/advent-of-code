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
//    print(part1(links: input))
    print(part1Try2(links: input))
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

//    print("dikjstraDistances count", dikjstraDistances.count)
//    print("edges.keys.count", edges.keys.count)

    let group1 = edges.keys.count - dikjstraDistances.count
    let group2 = edges.keys.count - group1

    return group1 * group2
}

typealias EdgeGraph<Node: Hashable> = [Node: Set<Node>]
extension EdgeGraph where Value == Set<Key> {
    mutating func without(_ edge: Edge<Key>) {
        self[edge.node1]?.remove(edge.node2)
        self[edge.node2]?.remove(edge.node1)
    }
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

struct Edge<Node: Hashable>: Hashable {
    let node1: Node
    let node2: Node
}

// MARK: - No Part 2 - Day 25

//func part2(links: Links) -> Int {
//    fatalError()
//}

main()
