import Foundation

typealias Stack = [Character]

struct Instruction {
    let amount: Int
    let fromIndex: Int
    let toIndex: Int
}

func main() {
    let stacks = parseState()
    let instructions = parseInstructions()
    
    print(part1(stacks: stacks, instructions: instructions))
    print(part2(stacks: stacks, instructions: instructions))
}

func parseState() -> [Stack] {
    var lines: [String] = []
    while let line = readLine(), !line.isEmpty {
        lines.append(line)
    }
    let lastLine = lines.popLast()!
    
    var stacks: [Stack] = Array(repeating: [], count: (lastLine.count + 1) / 4)
    
    for line in lines.reversed() {
        line.enumerated()
            .filter { (index, element) in
                (index - 1) % 4 == 0
            }
            .map { $0.element }
            .enumerated()
            .filter { $0.element != " " }
            .forEach { (index, element) in
                stacks[index].append(element)
            }
    }
    return stacks
}

func parseInstructions() -> [Instruction] {
    var instructions: [Instruction] = []
    
    while let line = readLine() {
        let components = line.split(separator: " ")
        instructions.append(Instruction(
            amount: Int(components[1])!,
            fromIndex: Int(components[3])! - 1,
            toIndex: Int(components[5])! - 1
        ))
    }
    
    return instructions
}

// MARK: - Part 1

func part1(stacks: [Stack], instructions: [Instruction]) -> String {
    var stacks = stacks
    for instruction in instructions {
        for _ in 1...instruction.amount {
            let moved = stacks[instruction.fromIndex].popLast()!
            stacks[instruction.toIndex].append(moved)
        }
    }
    return String(stacks.map { $0.last! })
}

// MARK: - Part 2

func part2(stacks: [Stack], instructions: [Instruction]) -> String {
    var stacks = stacks
    for instruction in instructions {
        let moved = stacks[instruction.fromIndex].suffix(instruction.amount)
        for _ in 1...instruction.amount {
            stacks[instruction.fromIndex].popLast()
        }
        stacks[instruction.toIndex].append(contentsOf: moved)
    }
    return String(stacks.map { $0.last! })
}

main()
