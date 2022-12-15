import Foundation

struct Coordinate: Hashable {
    let x: Int
    let y: Int
}

typealias Sensor = Coordinate
typealias Beacon = Coordinate

typealias InputType = [(sensor: Sensor, closestBeacon: Beacon)]

func main() {
    var input: InputType = []

    while let line = readLine() {

        let components = line.split(separator: "=")
        let sensor = Sensor(
            x: Int(String(components[1].split(separator: ",")[0]))!,
            y: Int(String(components[2].split(separator: ":")[0]))!
        )

        let closestSensor = Beacon(
            x: Int(String(components[3].split(separator: ",")[0]))!,
            y: Int(String(components[4]))!
        )

        input.append((sensor: sensor, closestBeacon: closestSensor))
    }

//    print(part1(inputParameter: input, yLine: 10)) // sample
    print(part1(inputParameter: input, yLine: 2000000)) // input.txt
//    print(part2(inputParameter: input, maxXY: 20)) // sample
    print(part2(inputParameter: input, maxXY: 4000000)) // input.txt
}

// MARK: - Part 1

func part1(inputParameter: InputType, yLine: Int) -> Int {
    let sensorsZones = inputParameter
        .map { Circle(center: $0.sensor, radius: $0.sensor.distance(to: $0.closestBeacon)) }
    let allBeacons = inputParameter.map { $0.closestBeacon }

    let zoneOnYLine = coveredZones(onYLine: yLine, sensorsZones: sensorsZones)
        .ranges
        .map { $0.upperBound - $0.lowerBound + 1 }
        .reduce(0, +)

    let beaconOnYLine = Set(allBeacons.filter { $0.y == yLine })

    return zoneOnYLine - beaconOnYLine.count
}

func coveredZones(onYLine yLine: Int, sensorsZones: [Circle]) -> RangeGroup {
    var rangeGroup = RangeGroup()
    sensorsZones
        .compactMap { $0.intersection(withY: yLine) }
        .forEach { rangeGroup.addRange($0) }
    return rangeGroup
}

struct Circle {
    let center: Coordinate
    let radius: Int
}

extension Coordinate {
    func distance(to other: Coordinate) -> Int {
        return abs(x - other.x) + abs(y - other.y)
    }
}

extension Circle {
    func intersection(withY y: Int) -> ClosedRange<Int>? {
        let yDistance = abs(y - center.y)
        guard yDistance <= radius else { return nil }
        let intersectionRadius = radius - yDistance
        return (center.x - intersectionRadius)...(center.x + intersectionRadius)
    }
}

// MARK: - Part 2

func part2(inputParameter: InputType, maxXY: Int) -> Int {
    let sensorsZones = inputParameter
        .map { Circle(center: $0.sensor, radius: $0.sensor.distance(to: $0.closestBeacon)) }

    var xSpot: Int?
    var ySpot: Int?

    let lookingRange = 0...maxXY
    for y in 0...maxXY {
        let range = coveredZones(onYLine: y, sensorsZones: sensorsZones)
        if range != range.addingRange(lookingRange) {
            ySpot = y
            xSpot = (range.ranges.first?.upperBound).map { $0 + 1 }
        }
    }

    guard let x = xSpot, let y = ySpot else {
        fatalError("Beacon location not found")
    }

    return x * 4000000 + y
}

main()
