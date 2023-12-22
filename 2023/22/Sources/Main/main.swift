import Foundation

typealias Cubes = [Rect3D]

struct Point3D {
    let x: Int
    let y: Int
    let z: Int
}

struct Rect3D {
    let point1: Point3D
    let point2: Point3D

    var minX: Int { min(point1.x, point2.x) }
    var maxX: Int { max(point1.x, point2.x) }
    var minY: Int { min(point1.y, point2.y) }
    var maxY: Int { max(point1.y, point2.y) }
    var minZ: Int { min(point1.z, point2.z) }
    var maxZ: Int { max(point1.z, point2.z) }
}

func main() {
    var input: Cubes = []

    while let line = readLine() {
        input.append(parseRect3D(from: line))
    }

    print(part1(cubes: input))
    print(part2(cubes: input))
}

func parseRect3D(from line: String) -> Rect3D {
    let parts = line.split(separator: "~")
    return Rect3D(
        point1: parsePoint3D(from: String(parts[0])),
        point2: parsePoint3D(from: String(parts[1]))
    )
}

func parsePoint3D(from string: String) -> Point3D {
    let parts = string.split(separator: ",").map { Int(String($0))! }
    return Point3D(x: parts[0], y: parts[1], z: parts[2])
}

// MARK: - Part 1

func part1(cubes: Cubes) -> Int {
//    cubes.forEach {
//        print($0)
//    }
//
//    print()

    let settledCubes = settleCubes(cubes)

//    print("Settled")
//    settledCubes.forEach {
//        print($0)
//    }

//    print("supportingCubes")
//    print(supportingCubes)
//
//    print("supportedByCubes")
//    print(supportedByCubes)

    let cubeRelations = cubeRelations(from: settledCubes)

    func canBeRemoved(_ cubeIndex: Int) -> Bool {
        let supporting = cubeRelations.supportingCubes[cubeIndex] ?? []
        guard !supporting.isEmpty else { return true }

        return supporting.allSatisfy { otherIndex in
            var supportedBySet = cubeRelations.supportedByCubes[otherIndex] ?? []
            supportedBySet.remove(cubeIndex)
            return !supportedBySet.isEmpty
        }
    }

//    print("removable", settledCubes.indices.filter { canBeRemoved($0) })
    return settledCubes.indices.filter { canBeRemoved($0) }.count
}

func settleCubes(_ cubes: Cubes) -> Cubes {
    var settledCubes: Cubes = []
    for cube in cubes.sorted(by: { $0.minZ < $1.minZ }) {
        let maxCubeZ = settledCubes.filter { cube.isOver($0) }.map(\.maxZ).max() ?? 0
        if cube.minZ > maxCubeZ + 1 {
            settledCubes.append(cube.moveDown(by: cube.minZ - (maxCubeZ + 1)))
        } else {
            settledCubes.append(cube)
        }
    }

    return settledCubes
}

struct CubeRelations {
    let supportingCubes: [Int: Set<Int>]
    let supportedByCubes: [Int: Set<Int>]
}

func cubeRelations(from settledCubes: Cubes) -> CubeRelations {

    var supportingCubes: [Int: Set<Int>] = [:]
    var supportedByCubes: [Int: Set<Int>] = [:]

    settledCubes.indices.forEach {
        supportingCubes[$0] = []
        supportedByCubes[$0] = []
    }

    for cube1Index in 0..<(settledCubes.count - 1) {
        let cube1 = settledCubes[cube1Index]
        for cube2Index in cube1Index..<settledCubes.count {
            let cube2 = settledCubes[cube2Index]
            if cube1.supportedZone.intersects(with: cube2) {
                supportingCubes[cube1Index, default: []].insert(cube2Index)
                supportedByCubes[cube2Index, default: []].insert(cube1Index)
            }
        }
    }

    return CubeRelations(supportingCubes: supportingCubes, supportedByCubes: supportedByCubes)
}

extension Rect3D {

    var supportedZone: Rect3D {
        Rect3D(
            point1: Point3D(x: minX, y: minY, z: maxZ + 1),
            point2: Point3D(x: maxX, y: maxY, z: maxZ + 1)
        )
    }

    func moveDown(by amount: Int) -> Rect3D {
        Rect3D(point1: point1.moveDown(by: amount), point2: point2.moveDown(by: amount))
    }

    func isOver(_ other: Rect3D) -> Bool {
        assert(!self.intersects(with: other))
        let overZone = Rect3D(
            point1: Point3D(x: other.minX, y: other.minY, z: other.maxZ + 1),
            point2: Point3D(x: other.maxX, y: other.maxY, z: .max)
        )

        return overZone.intersects(with: self)
    }

    func intersects(with other: Rect3D) -> Bool {
        return other.minX <= self.maxX && other.maxX >= self.minX
            && other.minY <= self.maxY && other.maxY >= self.minY
            && other.minZ <= self.maxZ && other.maxZ >= self.minZ
    }
}

extension Point3D {
    func moveDown(by amount: Int) -> Point3D {
        Point3D(x: x, y: y, z: z - amount)
    }
}

// MARK: - Part 2

func part2(cubes: Cubes) -> Int {
    let settledCubes = settleCubes(cubes)
    let cubeRelations = cubeRelations(from: settledCubes)

    var fallingValues = settledCubes.indices.map { index in
        countFallingWhenRemovingCube(at: index, in: settledCubes, relations: cubeRelations)
    }

    return fallingValues.reduce(0, +)
}

func countFallingWhenRemovingCube(
    at index: Int,
    in settledCubes: Cubes,
    relations: CubeRelations
) -> Int {

    var removed: Set<Int> = [index]
    var fallingCandidates = Array(relations.supportingCubes[index] ?? [])

    while !fallingCandidates.isEmpty {
        let candidate = fallingCandidates.removeFirst()
        let supports = relations.supportedByCubes[candidate] ?? []
        if removed.union(supports) == removed {
            removed.insert(candidate)
            fallingCandidates.append(contentsOf: relations.supportingCubes[candidate] ?? [])
        }
    }

    return removed.count - 1
}

// MARK: - Visualisation

extension Point3D: CustomStringConvertible {
    var description: String {
        "\(x),\(y),\(z)"
    }
}

extension Rect3D: CustomStringConvertible {
    var description: String {
        "\(Point3D(x: minX, y: minY, z: minZ))~\(Point3D(x: maxX, y: maxY, z: maxZ))"
    }
}

main()
