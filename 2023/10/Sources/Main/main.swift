import Foundation

struct Coordinates: Hashable {
    let x: Int
    let y: Int
}

typealias Node = Coordinates
struct PipeGraph {
    let startNode: Node
    let edges: [Node: [Node]]
    let pipes: [Node: Pipe]
}

enum Pipe: Character {
    case none = "."
    case start = "S"
    case vertical = "|"
    case horizontal = "-"
    case northEast = "L"
    case northWest = "J"
    case southWest = "7"
    case southEast = "F"
}

func main() {
    let input = parsePipeGraph()

    print(part1(pipeGraph: input))
    print(part2(pipeGraph: input))
}

func parsePipeGraph() -> PipeGraph {
    var edges: [Node: [Node]] = [:]
    var pipes: [Node: Pipe] = [:]
    var startNode: Node = Node(x: -1, y: -1)
    var y = 0
    while let line = readLine() {
        defer { y += 1 }
        line.map { Pipe(rawValue: $0)! }.enumerated().forEach { (x, pipe) in
            let node = Node(x: x, y: y)
            edges[node] = pipe.connectingCoordinates(from: node)
            pipes[node] = pipe
            if pipe == .start {
                startNode = node
            }
        }
    }
    edges[startNode] = startNode.neighbours.filter { edges[$0]?.contains(startNode) ?? false }
    pipes[startNode] = Pipe.pipeFor(node: startNode, edges: edges[startNode] ?? [])
    return PipeGraph(startNode: startNode, edges: edges, pipes: pipes)
}

extension Pipe {
    func connectingCoordinates(from position: Coordinates) -> [Coordinates] {
        self.connectingOffsets.map {
            Coordinates(x: position.x + $0.dx, y: position.y + $0.dy)
        }
    }

    static func pipeFor(node: Node, edges: [Node]) -> Pipe {
        guard !edges.isEmpty else { return .none }
        assert(edges.count == 2)
        let offsets = edges
            .map { Node(x: $0.x - node.x, y: $0.y - node.y) }
        switch Set(offsets) {
        case [Node(x: 0, y: -1), Node(x: 0, y: 1)]:
            return .vertical
        case [Node(x: -1, y: 0), Node(x: 1, y: 0)]:
            return .horizontal
        case [Node(x: 0, y: -1), Node(x: 1, y: 0)]:
            return .northEast
        case [Node(x: 0, y: -1), Node(x: -1, y: 0)]:
            return .northWest
        case [Node(x: 0, y: 1), Node(x: -1, y: 0)]:
            return .southWest
        case [Node(x: 0, y: 1), Node(x: 1, y: 0)]:
            return .southEast
        default:
            fatalError()
        }
    }

    private var connectingOffsets: [(dx: Int, dy: Int)] {
        switch self {
        case .none, .start:
            return []
        case .vertical:
            return [(0, -1), (0, 1)]
        case .horizontal:
            return [(-1, 0), (1, 0)]
        case .northEast:
            return [(0, -1), (1, 0)]
        case .northWest:
            return [(0, -1), (-1, 0)]
        case .southWest:
            return [(0, 1), (-1, 0)]
        case .southEast:
            return [(0, 1), (1, 0)]
        }
    }
}

extension Coordinates {
    var neighbours: [Coordinates] {
        return (-1...1).flatMap { dx in
            (-1...1).filter { abs($0) + abs(dx) == 1 }.map { dy in
                Coordinates(x: x + dx, y: y + dy)
            }
        }
    }
}

// MARK: - Part 1

func part1(pipeGraph: PipeGraph) -> Int {
    return pipeGraph.distancesFromMainLoopStart.values.max()!
}

extension PipeGraph {
    var distancesFromMainLoopStart: [Node: Int] {
        var distances: [Node: Int] = [:]
        distances[self.startNode] = 0
        var remainingNodes: [Node] = [self.startNode]

        while !remainingNodes.isEmpty {
            let currentNodes = remainingNodes
            remainingNodes.removeAll(keepingCapacity: true)
            for node in currentNodes {
                let currentDistance = distances[node]!
                self.edges[node]?
                    .filter { distances[$0] == nil }
                    .forEach {
                        distances[$0] = currentDistance + 1
                        remainingNodes.append($0)
                    }
            }
        }
        return distances
    }
}

// MARK: - Part 2

func part2(pipeGraph: PipeGraph) -> Int {
    let mainLoopPipes = Set(pipeGraph.distancesFromMainLoopStart.map(\.key))

    let minX = mainLoopPipes.map(\.x).min()!
    let maxX = mainLoopPipes.map(\.x).max()!
    let minY = mainLoopPipes.map(\.y).min()!
    let maxY = mainLoopPipes.map(\.y).max()!

    var withinLoopNodes: Set<Node> = []

    for y in minY...maxY {
        var currentMainLoopEncountered = 0
        var lastPipeSeen: Pipe?
        for x in minX...maxX {
            let node = Node(x: x, y: y)
            if mainLoopPipes.contains(node) {
                let currentPipe = pipeGraph.pipes[node]!
                if  currentPipe == .horizontal { continue }
                switch (lastPipeSeen, currentPipe) {
                case (.southEast, .northWest), (.northEast, .southWest):
                    continue
                default:
                    break
                }
                currentMainLoopEncountered += 1
                lastPipeSeen = currentPipe
            } else {
                if currentMainLoopEncountered % 2 == 1 {
                    withinLoopNodes.insert(node)
                }
            }
        }
    }

    var displayBuffer = DisplayBuffer()

    mainLoopPipes.forEach {
        displayBuffer.renderPipe(pipe: pipeGraph.pipes[$0]!, at: $0)
    }
    displayBuffer.renderPipe(pipe: .start, at: pipeGraph.startNode)
    withinLoopNodes.forEach {
        displayBuffer.pixels[$0] = "I"
    }

    displayBuffer.print()

    return withinLoopNodes.count
}

// MARK: - Helper - Visualisation

struct DisplayBuffer {
    var pixels: [Node: Character] = [:]

    mutating func renderPipe(pipe: Pipe, at node: Node) {
        pixels[node] = pipe == .none ? nil : pipe.displayValue
    }

    func print() {
        let minX = pixels.keys.map(\.x).min()!
        let maxX = pixels.keys.map(\.x).max()!
        let minY = pixels.keys.map(\.y).min()!
        let maxY = pixels.keys.map(\.y).max()!
        for y in minY...maxY {
            let line = (minX...maxX)
                .map { pixels[Node(x: $0, y: y)] ?? "." }
                .map { String($0) }
                .joined()
            Swift.print(line)
        }
    }
}

extension Pipe {
    var displayValue: Character {
        return switch self {
        case .none: "."
        case .start: "S"
        case .vertical: "│"
        case .horizontal: "─"
        case .northEast: "└"
        case .northWest: "┘"
        case .southWest: "┐"
        case .southEast: "┌"
        }
    }
}

main()
