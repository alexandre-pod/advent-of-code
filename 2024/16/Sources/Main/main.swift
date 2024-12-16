import Foundation

struct Maze {
    let map: Grid2D<Bool>
    let start: Coordinate2D
    let end: Coordinate2D
}

func main() {
    let input = parseMaze()!

    print(part1(maze: input))
    print(part2(maze: input))
}

func parseMaze() -> Maze? {
    var cells: [[Bool]] = []
    var start: Coordinate2D?
    var end: Coordinate2D?

    while let line = readLine() {
        if let startX = Array(line).firstIndex(of: "S") {
            start = Coordinate2D(x: startX, y: cells.count)
        }
        if let endX = Array(line).firstIndex(of: "E") {
            end = Coordinate2D(x: endX, y: cells.count)
        }
        cells.append(line.map { $0 == "#" })
    }

    guard let start, let end else { return nil }

    return Maze(
        map: Grid2D(cells: cells),
        start: start,
        end: end
    )
}

// MARK: - Part 1

func part1(maze: Maze) -> Int {
//    maze.printMap()

    let startNode = OrientedNode(position: maze.start, orientation: .east)
    let endNodes = Orientation.allCases.map { OrientedNode(position: maze.start, orientation: $0) }

    let (edges, edgeCost) = createWeightedGraph(from: maze)

    // Dikjstra
    var visited: Set<OrientedNode> = []
    var candidates: Set<OrientedNode> = [startNode]

    var costGrid: [OrientedNode: Int] = [:]
    var bestMoveSource: [OrientedNode: OrientedNode] = [:]

    costGrid[startNode] = 0


    while let candidate = candidates.min(by: { costGrid[$0]! < costGrid[$1]! }) {
        candidates.remove(candidate)
        visited.insert(candidate)

        let currentCost = costGrid[candidate]!

        if candidate.position == maze.end {
            return currentCost
        }

        for edge in edges[candidate, default: []] {
            let otherNode = edge.start == candidate ? edge.end : edge.start
            if visited.contains(otherNode) { continue }

            let otherCostFromCandidate = currentCost + edgeCost[edge]!
            if otherCostFromCandidate < costGrid[otherNode, default: .max] {
                costGrid[otherNode] = otherCostFromCandidate
                bestMoveSource[otherNode] = candidate
                candidates.insert(otherNode)
            }
        }
    }

    fatalError("No path to end found")
}

func createWeightedGraph(from maze: Maze) -> (edges: [OrientedNode: Set<Edge<OrientedNode>>], edgeCost: [Edge<OrientedNode>: Int]) {
    var edges: [OrientedNode: Set<Edge<OrientedNode>>] = [:]
    var edgeCost: [Edge<OrientedNode>: Int] = [:]

    for position in maze.map.allCoordinates where !maze.map[position] {
        let north = OrientedNode(position: position, orientation: .north)
        let south = OrientedNode(position: position, orientation: .south)
        let east = OrientedNode(position: position, orientation: .east)
        let west = OrientedNode(position: position, orientation: .west)

        let rotations = [
            Edge(north, east),
            Edge(north, west),
            Edge(south, east),
            Edge(south, west)
        ]
        rotations.forEach {
            edgeCost[$0] = 1000
            edges[$0.start, default: []].insert($0)
            edges[$0.end, default: []].insert($0)
        }

        let moves = [
            Edge(
                OrientedNode(position: position, orientation: .north),
                OrientedNode(position: position.moved(by: .down), orientation: .north)
            ),
            Edge(
                OrientedNode(position: position, orientation: .east),
                OrientedNode(position: position.moved(by: .right), orientation: .east)
            ),
            Edge(
                OrientedNode(position: position, orientation: .south),
                OrientedNode(position: position.moved(by: .up), orientation: .south)
            ),
            Edge(
                OrientedNode(position: position, orientation: .west),
                OrientedNode(position: position.moved(by: .left), orientation: .west)
            )
        ].filter { !maze.map[$0.start.position] && !maze.map[$0.end.position] }

        moves.forEach {
            edgeCost[$0] = 1
            edges[$0.start, default: []].insert($0)
            edges[$0.end, default: []].insert($0)
        }
    }

    return (edges, edgeCost)
}

struct OrientedNode: Hashable {
    let position: Coordinate2D
    let orientation: Orientation
}

enum Orientation: CaseIterable {
    case north
    case east
    case south
    case west
}

struct Edge<Node: Comparable & Hashable>: Hashable {
    let start: Node
    let end: Node

    init(_ node1: Node, _ node2: Node) {
        if node1 < node2 {
            start = node1
            end = node2
        } else {
            start = node2
            end = node1
        }
    }
}

extension OrientedNode: Comparable {
    static func < (lhs: OrientedNode, rhs: OrientedNode) -> Bool {
        return (lhs.position.x, lhs.position.y, lhs.orientation) < (rhs.position.x, rhs.position.y, rhs.orientation)
    }
}

extension Orientation: Comparable {
    static func < (lhs: Orientation, rhs: Orientation) -> Bool {
        return lhs.order < rhs.order
    }

    // MARK: - Private

    private var order: Int {
        return switch self {
        case .north: 0
        case .east: 1
        case .south: 2
        case .west: 3
        }
    }
}

// MARK: - Part 2

func part2(maze: Maze) -> Int {
//    maze.printMap()

    let startNode = OrientedNode(position: maze.start, orientation: .east)
    let endNodes = Orientation.allCases.map { OrientedNode(position: maze.end, orientation: $0) }

    let (edges, edgeCost) = createWeightedGraph(from: maze)

    // Dikjstra
    var visited: Set<OrientedNode> = []
    var candidates: Set<OrientedNode> = [startNode]

    var costGrid: [OrientedNode: Int] = [:]
    var bestMoveSource: [OrientedNode: Set<OrientedNode>] = [:]

    costGrid[startNode] = 0

    while let candidate = candidates.min(by: { costGrid[$0]! < costGrid[$1]! }) {
        candidates.remove(candidate)
        visited.insert(candidate)

        let currentCost = costGrid[candidate]!

        for edge in edges[candidate, default: []] {
            let otherNode = edge.start == candidate ? edge.end : edge.start
            if visited.contains(otherNode) { continue }

            let otherCostFromCandidate = currentCost + edgeCost[edge]!
            if otherCostFromCandidate <= costGrid[otherNode, default: .max] {
                costGrid[otherNode] = otherCostFromCandidate
                bestMoveSource[otherNode, default: []].insert(candidate)
                candidates.insert(otherNode)
            }
        }
    }

//    endNodes.forEach {
//        print("\($0) -> \(costGrid[$0]!)")
//    }

    let minCost = endNodes.map { costGrid[$0]! }.min()
    let minEndNodes = endNodes.filter { costGrid[$0]! == minCost }

    var nodesInBestPaths: Set<OrientedNode> = []
    var remainingNodes = Set(minEndNodes)

    while let node = remainingNodes.first {
        remainingNodes.remove(node)
        nodesInBestPaths.insert(node)
        for source in bestMoveSource[node, default: []] where !nodesInBestPaths.contains(source) {
            remainingNodes.insert(source)
        }
    }

    let positionsInBestPaths = Set(nodesInBestPaths.map(\.position))

    maze.map.map { position, isWall -> Character in
        if isWall {
            return "█"
        } else {
            return positionsInBestPaths.contains(position) ? "O" : " "
        }
    }.printDebug(celltoCharacter: \.self)

    return positionsInBestPaths.count
}

main()


// MARK: - Debug

extension Maze {
    func printMap() {
        let printableMap = map.map { position, isWall -> Character in
            if position == start {
                return "S"
            }
            if position == end {
                return "E"
            }
            return isWall ? "#" : "."
        }
        printableMap.printDebug(celltoCharacter: \.self)
    }
}


extension Grid2D {

    func map<T>(transform: (Coordinate2D, Cell) -> T) -> Grid2D<T> {
        Grid2D<T>(
            cells: cells.enumerated().map { y, row in
                row.enumerated().map { x, cell in
                    transform(Coordinate2D(x: x, y: y), cell)
                }
            }
        )
    }

    func with(cell: Cell, at: Coordinate2D) -> Self {
        var copy = self
        copy[at] = cell
        return copy
    }
}
