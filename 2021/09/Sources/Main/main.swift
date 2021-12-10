import Foundation

struct Point: Hashable {
    let x: Int
    let y: Int
}

extension Array where Element == [Int] {
    subscript(_ point: Point) -> Int {
        self[point.y][point.x]
    }

    var allPoints: [Point] {
        return (0..<self.count).flatMap { y in
            (0..<self[y].count).map { x in
                Point(x: x, y: y)
            }
        }
    }

}

// MARK: - Main

func main() {

    var grid: [[Int]] = []

    while let line = readLine() {
        grid.append(line.map { Int(String($0))! })
    }

    print(part1(grid: grid))
    print(part2(grid: grid))
}

// MARK: - Part 1

func part1(grid: [[Int]]) -> Int {

    var lowPoints: [Point] = []

    grid.allPoints.forEach { point in
        let value = grid[point]

        let adjacentValues = adjacentPoints(to: point, in: grid).map { grid[$0] }

        if adjacentValues.min()! > value {
            lowPoints.append(point)
        }
    }

    let riskLevel = lowPoints.map { grid[$0] + 1 }.reduce(0, +)
    return riskLevel
}

func adjacentPoints(to point: Point, in grid: [[Int]]) -> [Point] {
    return [
        Point(x: point.x - 1, y: point.y),
        Point(x: point.x + 1, y: point.y),
        Point(x: point.x, y: point.y - 1),
        Point(x: point.x, y: point.y + 1)
    ].filter { $0.x >= 0 && $0.x < grid[0].count && $0.y >= 0 && $0.y < grid.count }
}

// MARK: - Part 2

struct Cluster: Identifiable {
    let id: UUID
    var elements: Set<Point>

    init(id: UUID = UUID(), elements: Set<Point> = []) {
        self.id = id
        self.elements = elements
    }
}

func part2(grid: [[Int]]) -> Int {

    var edges: [Point: Set<Point>] = [:]

    grid.allPoints.forEach { point in
        guard grid[point] < 9 else { return }
        edges[point] = Set(adjacentPoints(to: point, in: grid).filter { grid[$0] != 9 })
    }

    var clusters: [Cluster] = []
    var pointsToClusterID: [Point: UUID] = [:]

    edges.keys.forEach { point in
        let adjacentPoints = edges[point, default: []]
        let adjacentClusterIDs = adjacentPoints.compactMap { pointsToClusterID[$0] }

        if adjacentClusterIDs.isEmpty {
            let newCluster = Cluster(elements: [point])
            clusters.append(newCluster)
            pointsToClusterID[point] = newCluster.id
            return
        }

        if adjacentClusterIDs.count == 1 {
            let clusterIndex = clusters.firstIndex { $0.id == adjacentClusterIDs[0] }!
            clusters[clusterIndex].elements.formUnion([point])
            pointsToClusterID[point] = adjacentClusterIDs[0]
            return
        }

        let adjacentClusters = adjacentClusterIDs.map { id in clusters.first { $0.id == id }! }

        clusters.removeAll { cluster in adjacentClusters.contains { $0.id == cluster.id } }

        let newCluster = Cluster(
            elements: adjacentClusters.reduce(Set<Point>()) { $0.union($1.elements) }.union([point])
        )
        clusters.append(newCluster)
        newCluster.elements.forEach {
            pointsToClusterID[$0] = newCluster.id
        }
    }

    let biggestClusters = clusters.sorted { $0.elements.count < $1.elements.count }.suffix(3)

    return biggestClusters.map { $0.elements.count }.reduce(1, *)
}

main()
