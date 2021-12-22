import Foundation

struct Coordinate: Hashable {
    let x: Int
    let y: Int
    let z: Int
}

struct Region3D: Equatable {
    let x: ClosedRange<Int>
    let y: ClosedRange<Int>
    let z: ClosedRange<Int>
}

struct Step {
    let switchOn: Bool
    let region: Region3D
}

// MARK: - Main

func main() {

    var steps: [Step] = []

    while let line = readLine() {
        let components = line.split(separator: " ")
        let isOn = components[0] == "on"
        let coordinates: [ClosedRange<Int>] = components[1]
            .split(separator: ",")
            .map {
                $0.split(separator: "=")[1]
            }
            .map {
                let rangeComponent = $0.split(separator: ".")
                return Int(rangeComponent[0])!...Int(rangeComponent[1])!
            }
        steps.append(Step(
            switchOn: isOn,
            region: Region3D(
                x: coordinates[0],
                y: coordinates[1],
                z: coordinates[2]
            )
        ))
    }

    print(part1(steps: steps))
    print(part2(steps: steps))
}

// MARK: - Part 1

func part1(steps: [Step]) -> Int {

    var onCoordinates: Set<Coordinate> = []

    for step in steps {

        if step.region.isOutOfPart1 { continue }

        if step.switchOn {
            step.region.allCoordinates.forEach {
                onCoordinates.insert($0)
            }
        } else {
            step.region.allCoordinates.forEach {
                onCoordinates.remove($0)
            }
        }
    }

    return onCoordinates.count
}

extension Region3D {
    var allCoordinates: [Coordinate] {
        return z.flatMap { z in
            y.flatMap { y in
                x.map { x in
                    Coordinate(x: x, y: y, z: z)
                }
            }
        }
    }

    var isOutOfPart1: Bool {
        x.upperBound < -50 || x.lowerBound > 50
        || y.upperBound < -50 || y.lowerBound > 50
        || z.upperBound < -50 || z.lowerBound > 50
    }
}

// MARK: - Part 2

func part2(steps: [Step]) -> Int {

    var onRegions: [Region3D] = []

    for step in steps {

        if step.switchOn {
            while let intersectingRegion = onRegions.first(where: { step.region.intersects(with: $0) }) {
                onRegions.removeAll { $0 == intersectingRegion }
                onRegions.append(contentsOf: intersectingRegion.removing(region: step.region))
            }
            onRegions.append(step.region)
        } else {
            while let intersectingRegion = onRegions.first(where: { step.region.intersects(with: $0) }) {
                onRegions.removeAll { $0 == intersectingRegion }
                onRegions.append(contentsOf: intersectingRegion.removing(region: step.region))
            }
        }
    }

    return onRegions.map(\.volume).reduce(0, +)
}

extension Region3D {

    func intersects(with regions: [Region3D]) -> Bool {
        return !regions.allSatisfy { !intersects(with: $0) }
    }

    func intersects(with region: Region3D) -> Bool {
        return intersection(with: region) != nil
    }

    func contains(region: Region3D) -> Bool {
        return x.contains(region.x.lowerBound) && x.contains(region.x.upperBound)
            && y.contains(region.y.lowerBound) && y.contains(region.y.upperBound)
            && z.contains(region.z.lowerBound) && z.contains(region.z.upperBound)
    }

    func contains(point: Coordinate) -> Bool {
        if
            point.x > x.upperBound || point.x < x.lowerBound
            || point.y > y.upperBound || point.y < y.lowerBound
            || point.z > z.upperBound || point.z < z.lowerBound
        {
            return false
        }
        return true
    }

    func intersection(with region: Region3D) -> Region3D? {
        let clampedX = x.clamped(to: region.x)
        let clampedY = y.clamped(to: region.y)
        let clampedZ = z.clamped(to: region.z)

        if
            (clampedX.count == 1 && !x.contains(clampedX.lowerBound))
            || (clampedY.count == 1 && !y.contains(clampedY.lowerBound))
            || (clampedZ.count == 1 && !z.contains(clampedZ.lowerBound))
        {
            return nil
        }

        return Region3D(x: clampedX, y: clampedY, z: clampedZ)
    }

    func removing(region: Region3D) -> [Region3D] {
        if region.contains(region: self) {
            return []
        }

        guard let intersection = self.intersection(with: region) else {
            return [self]
        }

        // X
        if intersection.x.upperBound + 1 <= x.upperBound {
            let freeRegion = Region3D(
                x: (intersection.x.upperBound + 1)...x.upperBound,
                y: y,
                z: z
            )
            let conflictRegion = Region3D(
                x: x.lowerBound...intersection.x.upperBound,
                y: y,
                z: z
            )
            return conflictRegion.removing(region: intersection) + [freeRegion]
        }

        if intersection.x.lowerBound - 1 >= x.lowerBound {
            let freeRegion = Region3D(
                x: x.lowerBound...(intersection.x.lowerBound - 1),
                y: y,
                z: z
            )
            let conflictRegion = Region3D(
                x: intersection.x.lowerBound...x.upperBound,
                y: y,
                z: z
            )
            return conflictRegion.removing(region: intersection) + [freeRegion]
        }

        // Y
        if intersection.y.upperBound + 1 <= y.upperBound {
            let freeRegion = Region3D(
                x: x,
                y: (intersection.y.upperBound + 1)...y.upperBound,
                z: z
            )
            let conflictRegion = Region3D(
                x: x,
                y: y.lowerBound...intersection.y.upperBound,
                z: z
            )
            return conflictRegion.removing(region: intersection) + [freeRegion]
        }

        if intersection.y.lowerBound - 1 >= y.lowerBound {
            let freeRegion = Region3D(
                x: x,
                y: y.lowerBound...(intersection.y.lowerBound - 1),
                z: z
            )
            let conflictRegion = Region3D(
                x: x,
                y: intersection.y.lowerBound...y.upperBound,
                z: z
            )
            return conflictRegion.removing(region: intersection) + [freeRegion]
        }

        // Z
        if intersection.z.upperBound + 1 <= z.upperBound {
            let freeRegion = Region3D(
                x: x,
                y: y,
                z: (intersection.z.upperBound + 1)...z.upperBound
            )
            let conflictRegion = Region3D(
                x: x,
                y: y,
                z: z.lowerBound...intersection.z.upperBound
            )
            return conflictRegion.removing(region: intersection) + [freeRegion]
        }

        if intersection.z.lowerBound - 1 >= z.lowerBound {
            let freeRegion = Region3D(
                x: x,
                y: y,
                z: z.lowerBound...(intersection.z.lowerBound - 1)
            )
            let conflictRegion = Region3D(
                x: x,
                y: y,
                z: intersection.z.lowerBound...z.upperBound
            )
            return conflictRegion.removing(region: intersection) + [freeRegion]
        }

        fatalError()
    }

    var volume: Int {
        x.count * y.count * z.count
    }
}

// MARK: - Start

main()
