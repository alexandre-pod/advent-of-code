import Foundation

typealias Instructions = [Instruction]

struct Instruction {
    let length: Int
    let direction: Direction
    let color: String
}

func main() {
    var input: Instructions = []

    while let line = readLine() {
        input.append(parseInstruction(from: line))
    }

    print(part1(instructions: input))
    print(part2(instructions: input))
}

func parseInstruction(from line: String) -> Instruction {
    let parts = line.split(separator: " ")

    let color = parts[2].dropFirst().dropFirst().dropLast()

    return Instruction(
        length: Int(String(parts[1]))!,
        direction: direction(for: String(parts[0]))!,
        color: String(color)
    )
}

func direction(for string: String) -> Direction? {
    return switch string {
    case "U": .up
    case "D": .down
    case "L": .left
    case "R": .right
    default: nil
    }
}

// MARK: - Part 1

func part1(instructions: Instructions) -> Int {

    var sides: Set<Coordinates> = []
    var position = Coordinates(x: 0, y: 0)
    sides.insert(position)

    for instruction in instructions {
        for _ in 0..<instruction.length {
            position = position.apply(direction: instruction.direction)
            sides.insert(position)
        }
    }

    return computeArea(of: sides)
}

func computeArea(of sides: Set<Coordinates>) -> Int {

    let startInteriorPoint = Coordinates(x: 1, y: 1)

    var interior: Set<Coordinates> = []
    var processing: Set<Coordinates> = [startInteriorPoint]

    while !processing.isEmpty {
        let point = processing.removeFirst()
        interior.insert(point)
        point.neighbors
            .filter { !interior.contains($0) }
            .filter { !sides.contains($0) }
            .forEach {
                processing.insert($0)
            }
    }

    return interior.count + sides.count
}

extension Coordinates {
    var neighbors: [Coordinates] {
        Direction.allCases.map {
            self.apply(direction: $0)
        }
    }
}

// MARK: - Part 2

func part2(instructions: Instructions) -> Int {

    let instructions = instructions.map { decodeRealInstruction(from: $0.color) }

    var segments: [Segment] = []
    var position = Coordinates(x: 0, y: 0)

    for instruction in instructions {
        let end = position.applying(instruction.direction, length: instruction.length)
        segments.append(Segment(position, end))
        position = end
    }

    return polygonArea(segments)
}

struct RealInstruction {
    let length: Int
    let direction: Direction
}

func decodeRealInstruction(from color: String) -> RealInstruction {
    return RealInstruction(
        length: Int(color.dropLast(), radix: 16)!,
        direction: direction(from: Int(String(color.last!))!)!
    )
}

func direction(from colorNumber: Int) -> Direction? {
    return switch colorNumber {
    case 0: .right
    case 1: .down
    case 2: .left
    case 3: .up
    default: nil
    }
}

// MARK: - Visualisation

extension Segment: CustomStringConvertible {
//    var description: String { "(\(minPoint.x),\(minPoint.y))-(\(maxPoint.x),\(maxPoint.y))" }
    var description: String {
        if isHorizontal {
            "- x(\(minX),\(maxX))"
        } else {
            "| y(\(minY),\(maxY)) x(\(minX))"
        }
    }
}

extension LocatedIntersection: CustomStringConvertible {
    var description: String {
        return "\(x) \(type)"
    }
}

main()
