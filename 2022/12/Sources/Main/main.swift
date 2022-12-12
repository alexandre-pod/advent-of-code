import Foundation

typealias HeightMap = Map<Character>

func main() {
    var grid: [[Character]] = []

    while let line = readLine() {
        grid.append(line.map { $0 })
    }

    let input = Map(grid)

    print(part1(heightMap: input))
    print(part2(heightMap: input))
}

// MARK: - Part 1

struct ProblemGraph {
    let startPoint: MapCoordinate
    let endPoint: MapCoordinate
    let edges: [MapCoordinate: [MapCoordinate]]
}

func part1(heightMap: HeightMap) -> Int {
    let graph = problemGraph(from: heightMap)!
    let distanceMap = distanceMap(from: heightMap, problemGraph: graph)
    return distanceMap[graph.startPoint]
}

func problemGraph(from heightMap: HeightMap) -> ProblemGraph? {
    var edges: [MapCoordinate: [MapCoordinate]] = [:]
    var start: MapCoordinate?
    var end: MapCoordinate?

    heightMap.allCoordinates.forEach {
        if heightMap[$0] == "S" {
            start = $0
        } else if heightMap[$0] == "E" {
            end = $0
        }
        let endHeight = height(for: heightMap[$0])
        edges[$0] = $0.neighbors(in: heightMap)
            .filter { height(for: heightMap[$0]) + 1 >= endHeight }
    }

    guard
        let startPoint = start,
        let endPoint = end
    else { return nil }
    return ProblemGraph(startPoint: startPoint, endPoint: endPoint, edges: edges)
}

func distanceMap(from heightMap: HeightMap, problemGraph: ProblemGraph) -> Map<Int> {
    var distanceMap = Map<Int>(width: heightMap.width, height: heightMap.height, repeatElement: Int.max)

    let remainingNodes: LinkedList<MapCoordinate> = [problemGraph.endPoint]
    var finishedNodes: Set<MapCoordinate> = []
    distanceMap[problemGraph.endPoint] = 0

    while let node = remainingNodes.head {
        remainingNodes.remove(node: node)
        let coordinate = node.value

        let distance = distanceMap[coordinate]
        (problemGraph.edges[coordinate] ?? [])
            .filter { !finishedNodes.contains($0) }
            .forEach {
                distanceMap[$0] = min(distance + 1, distanceMap[$0])

                if !finishedNodes.contains($0), !remainingNodes.contains($0) {
                    remainingNodes.append($0)
                }
            }

        finishedNodes.insert(coordinate)
    }

    return distanceMap
}

func height(for character: Character) -> Int {
    switch character {
    case "S":
        return 0
    case "E":
        return 25
    default:
        return Int(character.asciiValue! - Character("a").asciiValue!)
    }
}

extension MapCoordinate {
    func neighbors<T>(in map: Map<T>) -> [MapCoordinate] {
        return MapDirection.allCases
            .map { move(along: $0) }
            .filter { map.isValid($0) }
    }
}

// MARK: - Part 2

func part2(heightMap: HeightMap) -> Int {
    let graph = problemGraph(from: heightMap)!
    let distanceMap = distanceMap(from: heightMap, problemGraph: graph)
    let startCandidates = heightMap.allCoordinates.filter { height(for: heightMap[$0]) == 0 }
    return startCandidates.map { distanceMap[$0] }.min()!
}

main()
