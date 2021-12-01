import Foundation


enum Instruction {
    case rotation(Measurement<UnitAngle>)
    case forward(Int)
    case movement(north: Int, west: Int)
}

extension Measurement where UnitType == UnitAngle {
    static func degree(value: Double) -> Self {
        return .init(value: value, unit: .degrees)
    }

    static func radians(value: Double) -> Self {
        return .init(value: value, unit: .radians)
    }
}

extension Instruction {
    static func north(value: Int) -> Self {
        .movement(north: value, west: 0)
    }
    static func west(value: Int) -> Self {
        .movement(north: 0, west: value)
    }
    static func east(value: Int) -> Self {
        .movement(north: 0, west: -value)
    }
    static func south(value: Int) -> Self {
        .movement(north: -value, west: 0)
    }
    static func forward(value: Int) -> Self {
        .forward(value)
    }
    static func left(value: Int) -> Self {
        .rotation(.degree(value: Double(value)))
    }
    static func right(value: Int) -> Self {
        .rotation(.degree(value: Double(-value)))
    }
}

func main() {
    var instructions: [Instruction] = []
    while let line = readLine() {
        let value = Int(line[(line.index(line.startIndex, offsetBy: 1))...])!
        switch line.first! {
        case "N":
            instructions.append(.north(value: value))
        case "S":
            instructions.append(.south(value: value))
        case "E":
            instructions.append(.east(value: value))
        case "W":
            instructions.append(.west(value: value))
        case "L":
            instructions.append(.left(value: value))
        case "R":
            instructions.append(.right(value: value))
        case "F":
            instructions.append(.forward(value: value))
        default:
            fatalError()
        }
    }
    part1(instructions: instructions)
    part2(instructions: instructions)
}

// MARK: - Part 1

func part1(instructions: [Instruction]) {
    let finalShip = instructions.reduce(Ship()) { ship, instruction in
//        print("from \(ship) x \(instruction)")
//        let movedShip = instruction.appliedTo(ship)
//        print("to \(movedShip)")
//        return movedShip
        instruction.appliedTo(ship)
    }
    let answer = abs(finalShip.position.x) + abs(finalShip.position.y)
    print("answer: \(Int(answer)) (\(answer))")
}

struct Ship {
    var direction: Measurement<UnitAngle> = .degree(value: 0)
    var position: Point = .zero
}

extension Instruction {
    func appliedTo(_ ship: Ship) -> Ship {
        var movedShip = ship
        switch self {
        case let .movement(north, west):
            movedShip.position = ship.position + Point(x: -west, y: -north)
        case let .rotation(angle):
            movedShip.direction = ship.direction + angle
        case let .forward(value):
            movedShip.position = ship.position + Point(angle: ship.direction, norm: Double(value))
        }
        return movedShip
    }
}

// MARK: - Part 2

func part2(instructions: [Instruction]) {
    let initialShip = Ship()
    let initialWaypoint = Waypoint(position: Point(x: 10, y: -1))

    let finalShip = instructions.reduce((initialShip, initialWaypoint)) {
        tuple, instruction -> (Ship, Waypoint) in
        let (ship, waypoint) = tuple
//        print("from \(ship) ; \(waypoint) x \(instruction)")
//        let result = instruction.appliedTo(ship: ship, waypoint: waypoint)
//        print("to \(result.0) ; \(result.1)")
//        return result
        return instruction.appliedTo(ship: ship, waypoint: waypoint)
    }.0
    let answer = abs(finalShip.position.x) + abs(finalShip.position.y)
    print("answer: \(Int(answer)) (\(answer))")
}

struct Waypoint {
    var position: Point
}

extension Instruction {
    func appliedTo(ship: Ship, waypoint: Waypoint) -> (Ship, Waypoint) {
        var movedShip = ship
        var movedWaypoint = waypoint
        switch self {
        case let .movement(north, west):
            movedWaypoint.position = waypoint.position + Point(x: -west, y: -north)
        case let .rotation(angle):
            movedWaypoint.position = waypoint.position.rotatedAroundZero(angle: angle)
        case let .forward(value):
            movedShip.position = ship.position + waypoint.position * Double(value)
        }
        return (movedShip, movedWaypoint)
    }
}

main()

