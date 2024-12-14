import Foundation

struct MapState {
    let mapWidth: Int
    let mapHeight: Int
    var robots: [Robot]
}

struct Robot {
    let position: SIMD2<Int>
    let velocity: SIMD2<Int>
}

func main() {
    var robots: [Robot] = []

    while let line = readLine() {
        let parts = line.split(separator: " ")
        let position = parts[0].split(separator: "=")[1].split(separator: ",").map { Int($0)! }
        let velocity = parts[1].split(separator: "=")[1].split(separator: ",").map { Int($0)! }
        robots.append(
            Robot(
                position: SIMD2(x: position[0], y: position[1]),
                velocity: SIMD2(x: velocity[0], y: velocity[1])
            )
        )
    }
    let isSampleInput = robots.count == 12
    let input = MapState(
        mapWidth: isSampleInput ? 11 : 101,
        mapHeight: isSampleInput ? 7 : 103,
        robots: robots
    )
    print(part1(mapState: input))
    print(part2(mapState: input))
}

// MARK: - Part 1

func part1(mapState: MapState) -> Int {
//    mapState.printMap()

    let updated = mapState.updated(afterSeconds: 100)

//    updated.printMap()

    return updated.safetyFactor
}

extension MapState {
    func robot(atIndex index: Int, afterSeconds time: Int) -> Robot {
        let robot = robots[index]

        let deplacement = robot.velocity &* time
        var projectedPosition = robot.position &+ deplacement

        if projectedPosition.x < 0 {
            let offset = (-projectedPosition.x) / mapWidth
            projectedPosition.x += (offset + 1) * mapWidth
        }

        if projectedPosition.y < 0 {
            let offset = (-projectedPosition.y) / mapHeight
            projectedPosition.y += (offset + 1) * mapHeight
        }

        return Robot(
            position: projectedPosition % SIMD2(x: mapWidth, y: mapHeight),
            velocity: robot.velocity
        )
    }

    func updated(afterSeconds time: Int) -> MapState {
        var copy = self
        copy.robots = robots.indices.map { robot(atIndex: $0, afterSeconds: time) }
        return copy
    }

    var safetyFactor: Int {

        let midX = mapWidth / 2
        let midY = mapHeight / 2

        var topLeft = 0
        var topRight = 0
        var bottomLeft = 0
        var bottomRight = 0

        for robot in robots {
            let isLeft: Bool
            let isTop: Bool
            if robot.position.x == midX || robot.position.y == midY {
                continue
            }
            switch (robot.position.x < midX, robot.position.y < midY) {
            case (true, true):
                topLeft += 1
            case (true, false):
                bottomLeft += 1
            case (false, true):
                topRight += 1
            case (false, false):
                bottomRight += 1
            }
        }

//        print("topLeft", topLeft)
//        print("topRight", topRight)
//        print("bottomLeft", bottomLeft)
//        print("bottomRight", bottomRight)

        return topLeft * topRight * bottomLeft * bottomRight
    }
}

// MARK: - Part 2

func part2(mapState: MapState) -> Int {

    var text = mapState
    var currentTime = 0

//        repeat {
//            text.printMap()
//            print("^^^^^ \(currentTime)")
//            text = text.updated(afterSeconds: 1)
//            currentTime += 1
//    //        Thread.sleep(forTimeInterval: 1 / 20)
//    //        Task.sleep(for: .milliseconds(16))
//        } while(text.containsPicture)

    while !text.containsPicture {
        text = text.updated(afterSeconds: 1)
        currentTime += 1
    }

    text.printMap()
    print("^^^^^ \(currentTime)")

    return currentTime
}

main()

// MARK: - Debug print

extension MapState {

    var containsPicture: Bool {
//        return try! #/1111111111111/#.firstMatch(in: mapRepresentation) != nil
        let lineLengthSearch = 6

        let robotsMap = Dictionary(grouping: robots, by: \.position)
        for robot in self.robots {
            let xLine: Bool = (1...lineLengthSearch)
                .map { robot.position &+ SIMD2(x: $0, y: 0) }
                .map { robotsMap[$0, default: []].count }
                .allSatisfy { $0 == 1 }
            let yLine: Bool = (1...lineLengthSearch)
                .map { robot.position &+ SIMD2(x: 0, y: $0) }
                .map { robotsMap[$0, default: []].count }
                .allSatisfy { $0 == 1 }
            if xLine && yLine {
                return true
            }
        }
        return false
    }

    var mapRepresentation: String {
        let robotsMap = Dictionary(grouping: robots, by: \.position)
        return (0..<mapHeight).map { y in
            (0..<mapWidth).map { x in
                let count = robotsMap[SIMD2(x: x, y: y), default: []].count
                return count > 0 ? "\(count)" : " "
            }.joined()
        }.joined(separator: "\n")
    }

    func printMap() {
        print(mapRepresentation)
    }
}
