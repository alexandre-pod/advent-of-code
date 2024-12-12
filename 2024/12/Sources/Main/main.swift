import Foundation

typealias PuzzleMap = Grid2D<Character>

func main() {
    var cells: [[Character]] = []

    while let line = readLine() {
        cells.append(Array(line))
    }

    let input = Grid2D<Character>(cells: cells)
    print(part1(puzzleMap: input))
    print(part2(puzzleMap: input))
}

// MARK: - Part 1

func part1(puzzleMap: PuzzleMap) -> Int {

//    puzzleMap.printDebug(celltoCharacter: \.self)

    let regions = findRegionsAreaAndPerimeter(from: puzzleMap)

//    for (id, region) in regions.enumerated() {
//        print("> \(id)")
//        print("cells count:", region.surface.count)
//        print("perimeter:", region.perimeter.count)
//    }

    return regions
        .map { $0.surface.count * $0.perimeter.count }
        .reduce(0, +)
}

func findRegionsAreaAndPerimeter(from puzzleMap: PuzzleMap) -> [(surface: Set<Coordinate2D>, perimeter: Set<Edge>)] {
    var currentRegionID = 0
    var regionCells: [Int: Set<Coordinate2D>] = [:]
    var regionPerimeters: [Int: Set<Edge>] = [:]

    var remainingCells: Set<Coordinate2D> = Set(puzzleMap.allCoordinates)

    while let cell = remainingCells.first {
        let variant = puzzleMap[cell]

        var regionPositions: Set<Coordinate2D> = []
        var regionCandidates: Set<Coordinate2D> = [cell]
        var perimeter: Set<Edge> = []

        while let candidate = regionCandidates.first {
            regionCandidates.remove(candidate)
            regionPositions.insert(candidate)

            for neighbour in candidate.cardinalNeighbours() {
                guard puzzleMap.contains(neighbour) else {
                    perimeter.insert(Edge(source: candidate, destination: neighbour))
                    continue
                }
                let neighbourVariant = puzzleMap[neighbour]
                if variant == neighbourVariant {
                    if regionPositions.contains(neighbour) {
                        /* no-op */
                    } else {
                        regionCandidates.insert(neighbour)
                    }
                } else {
                    perimeter.insert(Edge(source: candidate, destination: neighbour))
                }
            }
        }

        regionPositions.forEach {
            remainingCells.remove($0)
        }

        regionCells[currentRegionID] = regionPositions
        regionPerimeters[currentRegionID] = perimeter

        currentRegionID += 1
    }

    return regionCells.keys
        .map { id in
            let area = regionCells[id, default: []]
            let perimeter = regionPerimeters[id, default: []]
            return (area, perimeter)
        }
}

extension Coordinate2D {
    func cardinalNeighbours() -> [Coordinate2D] {
        return [(-1, 0), (1, 0), (0, -1), (0, 1)]
            .map { Direction(deltaX: $0.0, deltaY: $0.1) }
            .map { moved(by: $0) }
    }
}

//    // Non directional
//    struct Edge: Hashable {
//        let source: Coordinate2D
//        let destination: Coordinate2D
//
//        init(source: Coordinate2D, destination: Coordinate2D) {
//            if (source.x, source.y) < (destination.x, destination.y) {
//                self.source = source
//                self.destination = destination
//            } else {
//                self.source = destination
//                self.destination = source
//            }
//        }
//    }

// Directional
struct Edge: Hashable {
    let source: Coordinate2D
    let destination: Coordinate2D

    init(source: Coordinate2D, destination: Coordinate2D) {
        self.source = source
        self.destination = destination
    }
}

// MARK: - Part 2

func part2(puzzleMap: PuzzleMap) -> Int {
//    puzzleMap.printDebug(celltoCharacter: \.self)

    let regions = findRegionsAreaAndPerimeter(from: puzzleMap)

//    for (id, region) in regions.enumerated() {
//        print("> \(id) [\(puzzleMap[region.surface.first!])]")
//        print("cells count:", region.surface.count)
//        print("perimeter:", region.perimeter.count)
//        print("sides:", countSides(from: region.perimeter))
//    }

    return regions
        .map { $0.surface.count * countSides(from: $0.perimeter) }
        .reduce(0, +)
}

func countSides(from edges: Set<Edge>) -> Int {
    var sides = 0

    var remainingEdges = edges

    while let edge = remainingEdges.first {
        remainingEdges.remove(edge)
        sides += 1

        let validDirections: [Direction]
        if edge.source.x == edge.destination.x {
            validDirections = [Direction.left, Direction.right]
        } else {
            validDirections = [Direction.up, Direction.down]
        }

        for direction in validDirections {
            var currentEdge = edge
            while edges.contains(currentEdge) {
                remainingEdges.remove(currentEdge)
                currentEdge = Edge(
                    source: currentEdge.source.moved(by: direction),
                    destination: currentEdge.destination.moved(by: direction)
                )
            }
        }

    }
    return sides
}

main()
