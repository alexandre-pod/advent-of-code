//
//  part1.swift
//
//
//  Created by Alexandre Podlewski on 31/12/2023.
//

import Foundation

func part1Try2(links: Links) -> Int {
    var graph = Part1Graph<String>()

    links.forEach { (node, neighbours) in
        graph.addNode(node)

        for neighbour in neighbours {
            graph.addNode(neighbour)
            graph.addEdge(node, neighbour, weight: 1)
        }
    }

    let (group1, group2, cutCost) = graph.minimalCut()
    print((group1, group2, cutCost))
    assert(cutCost == 3)
    return group1.count * group2.count
}

private struct Part1Graph<Node: Hashable> {

    private(set) var nodes: [Node]
    private(set) var edges: [Set<Int>]
    private(set) var weights: [[Int]]

    private var nodesIndexMapping: [Node: Int]

    init() {
        nodes = []
        nodesIndexMapping = [:]
        edges = []
        weights = []
    }

    mutating func addNode(_ node: Node) {
        guard !nodesIndexMapping.keys.contains(node) else { return }
        let index = nodes.count
        nodes.append(node)
        edges.append([])
        weights.indices.forEach {
            weights[$0].append(-1)
        }
        weights.append(Array(repeating: -1, count: nodes.count))
        nodesIndexMapping[node] = index
    }

    mutating func removeNode(_ node: Node) {
        assert(nodesIndexMapping.keys.contains(node))
        let index = nodesIndexMapping[node]!
        removeNode(at: index)
    }

    mutating func removeNode(at index: Int) {
        nodes.remove(at: index)
        edges.remove(at: index)
        weights.remove(at: index)
        weights.indices.forEach {
            weights[$0].remove(at: index)
        }
        edges.indices.forEach {
            edges[$0].remove(index)
            edges[$0] = Set(edges[$0].map { $0 > index ? $0 - 1 : $0 })
        }
        nodesIndexMapping.removeAll()
        nodes.enumerated().forEach {
            nodesIndexMapping[$0.element] = $0.offset
        }
    }

    mutating func addEdge(_ node1: Node, _ node2: Node, weight: Int) {
        assert(nodesIndexMapping.keys.contains(node1))
        assert(nodesIndexMapping.keys.contains(node2))
        let i1 = nodesIndexMapping[node1]!
        let i2 = nodesIndexMapping[node2]!
        addEdge(index1: i1, index2: i2, weight: weight)
    }

    mutating func addEdge(index1: Int, index2: Int, weight: Int) {
        edges[index1].insert(index2)
        edges[index2].insert(index1)
        weights[index1][index2] = weight
        weights[index2][index1] = weight
    }

    mutating func removeEdge(_ node1: Node, _ node2: Node) {
        assert(nodesIndexMapping.keys.contains(node1))
        assert(nodesIndexMapping.keys.contains(node2))
        let i1 = nodesIndexMapping[node1]!
        let i2 = nodesIndexMapping[node2]!
        removeEdge(index1: i1, index2: i2)
    }

    mutating func removeEdge(index1: Int, index2: Int) {
        edges[index1].remove(index2)
        edges[index2].remove(index1)
        weights[index1][index2] = -1
        weights[index2][index1] = -1
    }
}

extension Part1Graph {
    func mergingNodes(_ node1: Node, _ node2: Node, mergedNode: (Node, Node) -> Node) -> Self {
        assert(nodesIndexMapping.keys.contains(node1))
        assert(nodesIndexMapping.keys.contains(node2))
        let node1Index = nodesIndexMapping[node1]!
        let node2Index = nodesIndexMapping[node2]!
        let i1 = min(node1Index, node2Index)
        let i2 = max(node1Index, node2Index)

        var copy = self

        copy.removeNode(at: i2)
        let newNode = mergedNode(node1, node2)
        copy.nodes[i1] = newNode
        copy.nodesIndexMapping[node1] = nil
        copy.nodesIndexMapping[newNode] = i1

        for i2Neighbour in self.edges[i2] where i2Neighbour != i1 {
            let i1NeighbourWeight = max(0, weights[i1][i2Neighbour])
            let i2NeighbourWeight = max(0, weights[i2][i2Neighbour])
            copy.addEdge(
                index1: i1,
                index2: i2Neighbour > i2 ? i2Neighbour - 1 : i2Neighbour,
                weight: i1NeighbourWeight + i2NeighbourWeight
            )
        }

        return copy
    }
}

extension Part1Graph where Node == String {
    /// https://en.wikipedia.org/wiki/Stoer–Wagner_algorithm
    func minimalCut() -> (group1: Set<Node>, group2: Set<Node>, cutCost: Int) {
        print("minimalCut with nodes: \(nodes.count)")
        guard nodes.count > 2 else {
            let weight = max(0, weights[0][1])
            return ( [nodes[0]], [nodes[1]], weight)
        }
        let (group1, group2, cost) = phase(fromIndex: nodes.indices.randomElement()!)
        return (Set(group1.map { nodes[$0] }), Set(group2.map { nodes[$0] }), cost)
    }

    // MARK: - Private

    private func phase(fromIndex firstIndex: Int) -> (group1: Set<Int>, group2: Set<Int>, cutCost: Int) {
        var group: Set<Int> = [firstIndex]

        var groupNeighbours: Set<Int> = edges[firstIndex]
        var s: Int = firstIndex
        var t: Int = groupNeighbours.first!
        var stCutCost: Int = -1

        while !groupNeighbours.isEmpty {
            let (tightlyConnected, cutCost) = groupNeighbours
                .map { nodeIndex in (nodeIndex, weightSumBetween(nodeIndex: nodeIndex, group: group)) }
                .max { $0.1 < $1.1 }!
            s = t
            t = tightlyConnected
            stCutCost = cutCost

            groupNeighbours.remove(tightlyConnected)
            group.insert(tightlyConnected)
            edges[tightlyConnected]
                .filter { !group.contains($0) }
                .forEach { groupNeighbours.insert($0) }
        }

        let mergedNode = "\(nodes[s])+\(nodes[t])"
        let stMergedGraph = self.mergingNodes(nodes[s], nodes[t]) { "\($0)+\($1)" }

        let (mergedGroup1, mergedGroup2, mergedCutCost) = stMergedGraph.minimalCut() // stMergedGraph.phase(fromIndex: 0)

        if mergedCutCost < stCutCost {
            let group1 = mergedGroup1
                .flatMap { $0 == mergedNode ? [nodes[s], nodes[t]] : [$0] }
                .map { nodesIndexMapping[$0]! }
            let group2 = mergedGroup2
                .flatMap { $0 == mergedNode ? [nodes[s], nodes[t]] : [$0] }
                .map { nodesIndexMapping[$0]! }
            return (Set(group1), Set(group2), mergedCutCost)
        }
        return (group.subtracting([t]), [t], stCutCost)
    }

    private func weightSumBetween(nodeIndex: Int, group: Set<Int>) -> Int {
        return self.edges[nodeIndex]
            .filter { group.contains($0) }
            .map { weights[$0][nodeIndex] }
            .filter { $0 != -1 }
            .reduce(0, +)
    }
}
