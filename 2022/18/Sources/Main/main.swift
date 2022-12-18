import Foundation

struct Point3D: Hashable {
    let x: Int
    let y: Int
    let z: Int
}

typealias LavaPositions = [Point3D]

func main() {
    var lavaPositions: LavaPositions = []

    while let line = readLine() {
        let components = line.split(separator: ",")
        lavaPositions.append(
            Point3D(
                x: Int(String(components[0]))!,
                y: Int(String(components[1]))!,
                z: Int(String(components[2]))!
            )
        )
    }

    print(part1(lavaPositions: lavaPositions))
    print(part2(lavaPositions: lavaPositions))
}

// MARK: - Part 1

func part1(lavaPositions: LavaPositions) -> Int {
    let allPoints = Set(lavaPositions)
    var exposedSideCount = 0

    for point in lavaPositions {
        let adjacentCount = point.adjacentPoints.filter { allPoints.contains($0) }.count
        exposedSideCount += 6 - adjacentCount
    }

    return exposedSideCount
}

extension Point3D {
    var adjacentPoints: [Point3D] {
        return [
            Point3D(x: x + 1, y: y, z: z),
            Point3D(x: x - 1, y: y, z: z),
            Point3D(x: x, y: y + 1, z: z),
            Point3D(x: x, y: y - 1, z: z),
            Point3D(x: x, y: y, z: z + 1),
            Point3D(x: x, y: y, z: z - 1)
        ]
    }
}

// MARK: - Part 2

func part2(lavaPositions: LavaPositions) -> Int {
    let minX = lavaPositions.map(\.x).min()! - 1
    let maxX = lavaPositions.map(\.x).max()! + 1
    let minY = lavaPositions.map(\.y).min()! - 1
    let maxY = lavaPositions.map(\.y).max()! + 1
    let minZ = lavaPositions.map(\.z).min()! - 1
    let maxZ = lavaPositions.map(\.z).max()! + 1

    func isInLimit(_ point: Point3D) -> Bool {
        return minX...maxX ~= point.x && minY...maxY ~= point.y && minZ...maxZ ~= point.z
    }

    let allLavaPoints = Set(lavaPositions)

    var airPositionsObsidianExpositionCount: [Point3D: Int] = [:]
    var unprocessedAirPositions: Set<Point3D> = []

    unprocessedAirPositions.insert(Point3D(x: minX, y: minY, z: minZ))

    while let position = unprocessedAirPositions.first {
        unprocessedAirPositions.remove(position)

        let adjacents = position.adjacentPoints.filter { isInLimit($0) }
        adjacents
            .filter { !allLavaPoints.contains($0) }
            .filter { !airPositionsObsidianExpositionCount.keys.contains($0) }
            .forEach { unprocessedAirPositions.insert($0) }

        airPositionsObsidianExpositionCount[position] = adjacents
            .filter { allLavaPoints.contains($0) }
            .count
    }

    return airPositionsObsidianExpositionCount.values.reduce(0, +)
}

main()
