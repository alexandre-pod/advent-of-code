import Foundation

struct LabMap {
    var map: Grid2D<Bool>
    var guardPosition: Coordinate2D
}

func main() {
//    var input: LabMap = []
    var rawMap: [[Bool]] = []
    var guardPosition: Coordinate2D?

    while let line = readLine() {
        let rawLine = Array(line)
        if let guardX = rawLine.firstIndex(of: "^") {
            guardPosition = Coordinate2D(x: guardX, y: rawMap.count)
        }
        rawMap.append(rawLine.map { $0 == "#" })
    }

    let input = LabMap(
        map: Grid2D<Bool>(cells: rawMap),
        guardPosition: guardPosition!
    )

    print(part1(labMap: input))
    print(part2(labMap: input))
}

// MARK: - Part 1

extension Direction {
    static let up = Direction(deltaX: 0, deltaY: -1)
    static let down = Direction(deltaX: 0, deltaY: 1)
    static let left = Direction(deltaX: -1, deltaY: 0)
    static let right = Direction(deltaX: 1, deltaY: 0)

    func rotate90Degrees() -> Self {
        Direction(deltaX: -deltaY, deltaY: deltaX)
    }
}

func part1(labMap: LabMap) -> Int {

//    labMap.map.printDebug(celltoCharacter: { $0 ? "#" : "." })

    var currentDirection: Direction = .up
    var currentPosition = labMap.guardPosition
    var movementMap = Grid2D(defaultValue: Set<Direction>(), width: labMap.map.width, height: labMap.map.height)
    movementMap[currentPosition].insert(currentDirection)

    while attemptMove(from: &currentPosition, direction: &currentDirection, in: labMap.map) {
        if movementMap[currentPosition].contains(currentDirection) { break }
        movementMap[currentPosition].insert(currentDirection)
    }

//    movementMap.printDebug { direction in
//        return switch direction.first {
//        case .up: "^"
//        case .down: "v"
//        case .left: "<"
//        case .right: ">"
//        case .none: " "
//        default: "?"
//        }
//    }

    return movementMap.cells.flatMap { $0 }.filter { !$0.isEmpty }.count
}

func attemptMove(from position: inout Coordinate2D, direction: inout Direction, in map: Grid2D<Bool>) -> Bool {
    let nextPosition = position.moved(by: direction)
    guard map.contains(nextPosition) else { return false }
    if !map[nextPosition] {
        position = nextPosition
    } else {
        direction = direction.rotate90Degrees()
    }
    return true
}

// MARK: - Part 2

func part2(labMap: LabMap) -> Int {

    return labMap.map.allCoordinates
        .filter { !labMap.map[$0] && $0 != labMap.guardPosition }
        .filter {
            return causeCycleWithNexObstacle(at: $0, labMap: labMap)
        }
        .count
}

func causeCycleWithNexObstacle(at position: Coordinate2D, labMap: LabMap) -> Bool {
    assert(!labMap.map[position])
    var map = labMap.map
    map[position] = true

    var currentDirection: Direction = .up
    var currentPosition = labMap.guardPosition
    var movementMap = Grid2D(defaultValue: Set<Direction>(), width: map.width, height: map.height)
    movementMap[currentPosition].insert(currentDirection)

    while attemptMove(from: &currentPosition, direction: &currentDirection, in: map) {
        if movementMap[currentPosition].contains(currentDirection) {
            return true
        }
        movementMap[currentPosition].insert(currentDirection)
    }

    return false
}

main()
