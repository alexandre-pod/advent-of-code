import Foundation

enum Command {
    case forward(Int)
    case down(Int)
    case up(Int)
}

func main() {

    var commands: [Command] = []

    while let line = readLine() {
        let components = line.split(separator: " ")
        switch components[0] {
        case "forward":
            commands.append(.forward(Int(components[1])!))
        case "down":
            commands.append(.down(Int(components[1])!))
        case "up":
            commands.append(.up(Int(components[1])!))
        default:
            fatalError("Invalid command")
        }
    }

    print(part1(commands: commands))
    print(part2(commands: commands))
}

struct Position {
    var depth: Int = 0
    var horizontal: Int = 0
}

func part1(commands: [Command]) -> Int {

    let finalPosition = commands.reduce(into: Position()) { partialResult, command in
        switch command {
        case .forward(let value):
            partialResult.horizontal += value
        case .down(let value):
            partialResult.depth += value
        case .up(let value):
            partialResult.depth -= value
        }
    }

    return finalPosition.depth * finalPosition.horizontal
}

struct SubmarineState {
    var aim: Int = 0
    var depth: Int = 0
    var horizontal: Int = 0
}

func part2(commands: [Command]) -> Int {
    let finalState = commands.reduce(into: SubmarineState()) { partialResult, command in
        switch command {
        case .forward(let value):
            partialResult.horizontal += value
            partialResult.depth += value * partialResult.aim
        case .down(let value):
            partialResult.aim += value
        case .up(let value):
            partialResult.aim -= value
        }
    }

    return finalState.depth * finalState.horizontal
}

main()
