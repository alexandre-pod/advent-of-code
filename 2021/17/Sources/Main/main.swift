import Foundation

struct Target {
    let xRange: ClosedRange<Int>
    let yRange: ClosedRange<Int>
}

struct Point {
    var x: Int
    var y: Int
}

struct Velocity {
    var x: Int
    var y: Int
}

// MARK: - Main

func main() {

    let line = readLine()!

    let ranges = line
        .split(separator: ":")[1]
        .trimmingCharacters(in: .whitespaces)
        .split(separator: ",")
        .map { $0.split(separator: "=")[1] }
        .map { $0.split(separator: ".") }
        .map { $0.map { Int(String($0))! } }

    let target = Target(
        xRange: ranges[0][0]...ranges[0][1],
        yRange: ranges[1][0]...ranges[1][1]
    )

    part1And2(target: target)
}

// MARK: - Part 1 and 2

func part1And2(target: Target) {

    var highestPoints: [Int] = []

    for vx in 0...100 {
        for vy in -500...500 {
            let velocity = Velocity(x: vx, y: vy)
            let (isReaching, highestPoint) = isReachingTarget(
                position: Point(x: 0, y: 0),
                velocity: velocity,
                target: target
            )
            if isReaching {
                highestPoints.append(highestPoint)
            }
        }
    }

    print(highestPoints.max()!)
    print(highestPoints.count)
}

func isReachingTarget(position: Point, velocity: Velocity, target: Target) -> (Bool, Int) {
//    print(position, velocity, target)
    guard
        velocity.x >= 0,
        position.x <= target.xRange.upperBound,
        position.y >= target.yRange.lowerBound
    else { return (false, Int.min) }

    if target.contains(position) { return (true, position.y) }

    let (isReaching, highestPoint) = isReachingTarget(position: position + velocity, velocity: velocity.applyingDrag, target: target)
    if isReaching {
        return (true, max(highestPoint, position.y))
    } else {
        return (false, highestPoint)
    }
}

extension Target {
    func contains(_ point: Point) -> Bool {
        xRange.contains(point.x) && yRange.contains(point.y)
    }
}

extension Point {
    static func +(lhs: Point, rhs: Velocity) -> Point {
        Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

extension Velocity {
    var applyingDrag: Velocity {
        Velocity(
            x: x > 0 ? x - 1 : 0,
            y: y - 1
        )
    }
}

main()
