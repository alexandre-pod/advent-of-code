import Foundation

struct Program {
    let instructions: [Instruction]
    var accumulatorValue: Int = 0
    var currentInstruction: Int = 0
    
    var programFinished = false
    
    enum Instruction {
        case nop(value: Int)
        case acc(amount: Int)
        case jmp(distance: Int)
    }
}

extension Program {
    mutating func executeInstruction() {
        guard !programFinished else { return }
        switch instructions[currentInstruction] {
        case let .acc(amount):
            accumulatorValue += amount
            currentInstruction += 1
        case let .jmp(distance):
            currentInstruction += distance
        case .nop:
            currentInstruction += 1
        }
        if currentInstruction >= instructions.count {
            programFinished = true
        }
    }
}

func main() {
    var instructions: [Program.Instruction] = []
    while let line = readLine() {
        let split = line.split(separator: " ")
        let instruction: Program.Instruction
        let number = Int(split[1])!
        switch split[0] {
        case "nop":
            instruction = .nop(value: number)
        case "acc":
            instruction = .acc(amount: number)
        case "jmp":
            instruction = .jmp(distance: number)
        default:
            fatalError()
        }
        instructions.append(instruction)
    }
    
    part1(instructions: instructions)
    part2(instructions: instructions)
}

// MARK: - Part 1

func part1(instructions: [Program.Instruction]) {
    var program = Program(instructions: instructions)
    var executedInstructions: Set<Int> = []

    while !executedInstructions.contains(program.currentInstruction) {
        executedInstructions.insert(program.currentInstruction)
        program.executeInstruction()
    }
    
    print("Accumulator value: \(program.accumulatorValue)")
}

// MARK: - Part 2

func part2(instructions: [Program.Instruction]) {
    
    
    let toTestSwapIndices = instructions.indices
        .filter { instructions[$0].isJmpOrNop }
    
    toTestSwapIndices.forEach {
        var program = Program(instructions: instructions.swapInstruction(at: $0))
        guard executeWithLoopPrevention(&program) else { return }
        print("Instruction swap at index: \($0)")
        print("Program ended with accumulator value: \(program.accumulatorValue)")
    }
    
}

/// returns true if the program finished correctly, an infinite loop will return false
func executeWithLoopPrevention(_ program: inout Program) -> Bool {
    var executedInstructions: Set<Int> = []

    while
        !program.programFinished,
        !executedInstructions.contains(program.currentInstruction)
    {
        executedInstructions.insert(program.currentInstruction)
        program.executeInstruction()
    }
    
    return program.programFinished
}

extension Program.Instruction {
    var isJmpOrNop: Bool {
        switch self {
        case .acc: return false
        case .jmp, .nop: return true
        }
    }
    
    func swapJmpNop() -> Self {
        switch self {
        case .acc: fatalError()
        case let .jmp(distance): return .nop(value: distance)
        case let .nop(value): return .jmp(distance: value)
        }
    }
}

extension Array where Element == Program.Instruction {
    func swapInstruction(at index: Int) -> Self {
        var copy = self
        copy[index] = copy[index].swapJmpNop()
        return copy
    }
}

main()
