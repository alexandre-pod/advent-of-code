import Foundation

struct Coordinate: Hashable {
    var x: Int
    var y: Int
    var z: Int
}

struct Scanner: Equatable {
    let id: Int
    var relativeCoordinate: Coordinate = .zero
    var beacons: [Coordinate]
}

extension Coordinate: AdditiveArithmetic, Equatable {

    static let zero = Coordinate(x: 0, y: 0, z: 0)

    static func + (lhs: Coordinate, rhs: Coordinate) -> Coordinate {
        return Coordinate(
            x: lhs.x + rhs.x,
            y: lhs.y + rhs.y,
            z: lhs.z + rhs.z
        )
    }

    static func - (lhs: Coordinate, rhs: Coordinate) -> Coordinate {
        return Coordinate(
            x: lhs.x - rhs.x,
            y: lhs.y - rhs.y,
            z: lhs.z - rhs.z
        )
    }
}

// MARK: - Main

func main() {

    var scanners: [Scanner] = []

    while
        let line = readLine(),
        line.starts(with: "---"),
        let scannerID = Int(line.split(separator: " ")[2])
    {
        var beacons: [Coordinate] = []
        while let line = readLine(), !line.isEmpty {
            let coordinates = line.split(separator: ",").map { Int($0)! }
            beacons.append(Coordinate(x: coordinates[0], y: coordinates[1], z: coordinates[2]))
        }
        scanners.append(Scanner(id: scannerID, beacons: beacons))
    }

    let orientedScanners = orientAllScanners(scanners: scanners, threshold: 12)

    print(part1(orientedScanners: orientedScanners))
    print(part2(orientedScanners: orientedScanners))
}

// MARK: - Part 1

func part1(orientedScanners: [Scanner]) -> Int {

    let beaconPositions = Set(orientedScanners.flatMap { scanner in
        scanner.beacons.map { scanner.relativeCoordinate + $0 }
    })

    return beaconPositions.count
}

// MARK: - Part 2

func part2(orientedScanners: [Scanner]) -> Int {

    let scannerPositions = orientedScanners.map(\.relativeCoordinate)

    let maxDistance = scannerPositions.lazy.flatMap { scannerA in
        scannerPositions.filter { $0 != scannerA }.map { scannerB in
            scannerA.manhattanDistance(to: scannerB)
        }
    }.max() ?? -1

    return maxDistance
}

extension Coordinate {
    func manhattanDistance(to coordinate: Coordinate) -> Int {
        return abs(x - coordinate.x) + abs(y - coordinate.y) + abs(z - coordinate.z)
    }
}

// MARK: - Common

func orientAllScanners(scanners: [Scanner], threshold: Int) -> [Scanner] {
    var remainingScanners = Array(scanners[1...])
    let referenceScanner = scanners[0]
    var orientedScanners: [Scanner] = [referenceScanner]

    var stopScanningScannerIDs: Set<Int> = []

    while !remainingScanners.isEmpty {
        for orientedScanner in orientedScanners where !stopScanningScannerIDs.contains(orientedScanner.id) {
            var found = false

            if let overlappingScanner = findOverlappingScanner(
                withScanner: orientedScanner,
                in: remainingScanners,
                threshold: threshold
            ) {
                found = true
                remainingScanners.removeAll { $0.id == overlappingScanner.id }
                orientedScanners.append(Scanner(
                    id: overlappingScanner.id,
                    relativeCoordinate: orientedScanner.relativeCoordinate + overlappingScanner.relativeCoordinate,
                    beacons: overlappingScanner.beacons
                ))
            }

            if !found {
                stopScanningScannerIDs.insert(orientedScanner.id)
            }
        }
    }

    return orientedScanners
}

func findOverlappingScanner(
    withScanner scanner: Scanner,
    in scanners: [Scanner],
    threshold: Int
) -> Scanner? {
    for scannerCandidate in scanners {
        for rotation in RightAngleRotation.allRotations {
            let rotatedCandidate = scannerCandidate.rotated(by: rotation)
            if let (i1, i2) = findCommonBeacon(
                between: scanner,
                and: rotatedCandidate,
                threshold: threshold
            ) {
                let beaconInA = scanner.beacons[i1]
                let beaconInB = rotatedCandidate.beacons[i2]
                var orientedScanner = rotatedCandidate
                orientedScanner.relativeCoordinate = beaconInA - beaconInB
                return orientedScanner
            }
        }
    }
    return nil
}

struct BeaconNeighbors {
    let id: Int
    let scannerID: Int
    var beaconsRelative: Set<Coordinate>
}

func findCommonBeacon(
    between scannerA: Scanner,
    and scannerB: Scanner,
    threshold: Int
) -> (Int, Int)? {

    let beaconsAWithNeighbors = scannerA.beacons.enumerated().map { index, beacon in
        BeaconNeighbors(
            id: index,
            scannerID: scannerA.id,
            beaconsRelative: Set(scannerA.beacons.map { $0 - beacon })
        )
    }

    let beaconsBWithNeighbors = scannerB.beacons.enumerated().map { index, beacon in
        BeaconNeighbors(
            id: index,
            scannerID: scannerB.id,
            beaconsRelative: Set(scannerB.beacons.map { $0 - beacon })
        )
    }

    for beaconA in beaconsAWithNeighbors {
        for beaconB in beaconsBWithNeighbors {
            if beaconA.beaconsRelative.intersection(beaconB.beaconsRelative).count > threshold - 1 {
                return (beaconA.id, beaconB.id)
            }
        }
    }

    return nil
}

extension Scanner {
    func rotated(by rotations: [RightAngleRotation]) -> Scanner {
        Scanner(id: id, beacons: beacons.map { $0.applying(rotations: rotations) })
    }
}

extension Coordinate {

    func applying(rotation: RightAngleRotation) -> Coordinate {
        switch rotation {
        case .aroundX:
            return Coordinate(x: x, y: -z, z: y)
        case .aroundY:
            return Coordinate(x: z, y: y, z: -x)
        case .aroundZ:
            return Coordinate(x: -y, y: x, z: z)
        }
    }

    func applying(rotations: [RightAngleRotation]) -> Coordinate {
        return rotations.reduce(self) { $0.applying(rotation: $1) }
    }
}

indirect enum RightAngleRotation: Hashable {
    case aroundX
    case aroundY
    case aroundZ

    static let allRotations: [[RightAngleRotation]] = [
        [],
        [.aroundX],
        [.aroundX, .aroundX],
        [.aroundX, .aroundX, .aroundX],

        [.aroundZ],
        [.aroundZ, .aroundY],
        [.aroundZ, .aroundY, .aroundY],
        [.aroundZ, .aroundY, .aroundY, .aroundY],

        [.aroundZ, .aroundZ],
        [.aroundZ, .aroundZ, .aroundX],
        [.aroundZ, .aroundZ, .aroundX, .aroundX],
        [.aroundZ, .aroundZ, .aroundX, .aroundX, .aroundX],

        [.aroundZ, .aroundZ, .aroundZ],
        [.aroundZ, .aroundZ, .aroundZ, .aroundY],
        [.aroundZ, .aroundZ, .aroundZ, .aroundY, .aroundY],
        [.aroundZ, .aroundZ, .aroundZ, .aroundY, .aroundY, .aroundY],

        [.aroundY],
        [.aroundY, .aroundZ],
        [.aroundY, .aroundZ, .aroundZ],
        [.aroundY, .aroundZ, .aroundZ, .aroundZ],

        [.aroundY, .aroundY, .aroundY],
        [.aroundY, .aroundY, .aroundY, .aroundZ],
        [.aroundY, .aroundY, .aroundY, .aroundZ, .aroundZ],
        [.aroundY, .aroundY, .aroundY, .aroundZ, .aroundZ, .aroundZ],
    ]
}

// MARK: - Start

main()

// MARK: - Debug

extension Coordinate:CustomStringConvertible {
    var description: String {
        "(\(x),\(y),\(z))"
    }
}
