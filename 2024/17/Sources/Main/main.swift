import Foundation

typealias InputType = [String]

struct CPU {
    var registerA: Int
    var registerB: Int
    var registerC: Int
    var instructionPointer: Int

    let memory: [Int]
    var output: [Int]

    init(
        registerA: Int,
        registerB: Int,
        registerC: Int,
        instructionPointer: Int = 0,
        memory: [Int],
        output: [Int] = []
    ) {
        self.registerA = registerA
        self.registerB = registerB
        self.registerC = registerC
        self.instructionPointer = instructionPointer
        self.memory = memory
        self.output = output
    }
}


func main() {
    let registerA = Int(readLine()!.split(separator: " ").last!)!
    let registerB = Int(readLine()!.split(separator: " ").last!)!
    let registerC = Int(readLine()!.split(separator: " ").last!)!
    _ = readLine()
    let memory = readLine()!.split(separator: " ")[1].split(separator: ",").map { Int($0)! }
    var input = CPU(
        registerA: registerA,
        registerB: registerB,
        registerC: registerC,
        memory: memory
    )

    print(part1(cpu: input))
//    print(part2InterpreterBruteforce(cpu: input))
//    print(part2Hardcoded(cpu: input))
    print(part2ReverseSolver(cpu: input))
}


// MARK: - Part 1

func part1(cpu: CPU) -> String {
    var cpu = cpu
    print(cpu)

    cpu.start()

    print(cpu.output)

    return cpu.output.map { String($0) }.joined(separator: ",")
}

extension CPU {
    mutating func start() {
        while instructionPointer < memory.count {
            do {
                try executeInstruction()
            } catch {
                break
            }
        }
    }

    // MARK: - Private

    private mutating func executeInstruction() throws(CPUError) {
        let opCode = try consumeInstructionValue()
        switch opCode {
        case 0:
            let comboOperand = try consumeInstructionValue()
            let denominator = NSDecimalNumber(decimal: pow(2, comboOperandValue(for: comboOperand))).intValue
            registerA = registerA / denominator
        case 1:
            let operand = try consumeInstructionValue()
            registerB = registerB ^ operand
        case 2:
            registerB = comboOperandValue(for: try consumeInstructionValue()) % 8
        case 3:
            if registerA != 0 {
                instructionPointer = try consumeInstructionValue()
            }
        case 4:
            _ = try consumeInstructionValue() // ignored
            registerB = registerB ^ registerC
        case 5:
            let comboValue = comboOperandValue(for: try consumeInstructionValue())
            output.append(comboValue % 8)
        case 6:
            let comboOperand = try consumeInstructionValue()
            let denominator = NSDecimalNumber(decimal: pow(2, comboOperandValue(for: comboOperand))).intValue
            registerB = registerA / denominator
        case 7:
            let comboOperand = try consumeInstructionValue()
            let denominator = NSDecimalNumber(decimal: pow(2, comboOperandValue(for: comboOperand))).intValue
            registerC = registerA / denominator
        default:
            fatalError()
        }
    }

    private func comboOperandValue(for comboOperand: Int) -> Int {
        switch comboOperand {
        case 0, 1, 2, 3:
            return comboOperand
        case 4:
            return registerA
        case 5:
            return registerB
        case 6:
            return registerC
        case 7:
            fatalError("Reserved combo operand")
        default:
            fatalError()
        }
    }

    private mutating func consumeInstructionValue() throws(CPUError) -> Int {
        guard memory.indices.contains(instructionPointer) else {
            throw CPUError.halt
        }
        defer { instructionPointer += 1 }
        return memory[instructionPointer]
    }

    enum CPUError: Error {
        case halt
    }
}

private func testCPU() {
    var testCPU = CPU(registerA: 0, registerB: 0, registerC: 9, memory: [2, 6])
    print("======")
    print(testCPU)
    testCPU.start()
    print(testCPU)

    testCPU = CPU(registerA: 10, registerB: 0, registerC: 9, memory: [5, 0, 5, 1, 5, 4])
    print("======")
    print(testCPU)
    testCPU.start()
    print(testCPU)

    testCPU = CPU(registerA: 2024, registerB: 0, registerC: 9, memory: [0, 1, 5, 4, 3, 0])
    print("======")
    print(testCPU)
    testCPU.start()
    print(testCPU)

    testCPU = CPU(registerA: 0, registerB: 29, registerC: 9, memory: [1, 7])
    print("======")
    print(testCPU)
    testCPU.start()
    print(testCPU)

    testCPU = CPU(registerA: 0, registerB: 2024, registerC: 43690, memory: [4, 0])
    print("======")
    print(testCPU)
    testCPU.start()
    print(testCPU)
}


// MARK: - Part 2

func part2ReverseSolver(cpu: CPU) -> Int {
    return findInputAValue(toOutput: cpu.memory, upperA: 0)!
}

func findInputAValue(toOutput output: [Int], upperA aValue: Int = 0) -> Int? {

    guard let lastValue = output.last else { return aValue }

    let expectedRoundOutput = output.last!

    for triNumber in 0...7 {
        var aCandidate = aValue << 3 + triNumber

        var b = (aCandidate % 8) ^ 1
        var c = aCandidate >> b
        b = b ^ c ^ 4
        if b % 8 == expectedRoundOutput {
            print(triNumber, "[\(output.count)]")

            if let answer = findInputAValue(toOutput: output.dropLast(), upperA: aCandidate) {
                return answer
            }
        }
    }

    if output.count == 1 {

    }
    return nil
}

// MARK: - Part 2 - Bruteforce attempts

func part2InterpreterBruteforce(cpu: CPU) -> Int {

    var fixingValue = 0
    repeat {
        if fixingValue % 1000000 == 0 {
            print("processing", fixingValue)
        }
        var fixedCPU = cpu
        fixedCPU.registerA = fixingValue
//        fixedCPU.start()
        fixedCPU.start(forOutputMatching: cpu.memory)
        if fixedCPU.output == cpu.memory {
            return fixingValue
        }
        fixingValue += 1
    } while true
}

extension CPU {
    mutating func start(forOutputMatching expectedOutput: [Int]) {
        let startA = registerA
        while instructionPointer < memory.count, Array(expectedOutput.prefix(output.count)) == output {
            do {
                try executeInstruction()
            } catch {
                break
            }
        }
//        if output.count > 7 {
//            print(startA, "[\(output.count)]")
//        }
    }
}

func part2Hardcoded(cpu: CPU) -> Int {
    var fixingValue = 0
    repeat {
        if fixingValue % 100_000_000 == 0 {
            print("processing", fixingValue)
        }
        if hardcodedCPU(for: fixingValue, produces: cpu.memory) {
            print("qsdlkjqs")
            return fixingValue
        }
        fixingValue += 1
    } while true
}

func hardcodedCPU(for a: Int, produces expectedOutput: [Int]) -> Bool {
    var a = a
    var b = 0
    var c = 0
    var outputIndex = 0

    repeat {
        b = (a % 8) ^ 1
        c = a >> b
        b = b ^ c ^ 4
        a = a >> 3
        let output = b % 8
        if outputIndex < expectedOutput.count,
           expectedOutput[outputIndex] != output {
            return false
        }
        outputIndex += 1
    } while a != 0

    return outputIndex == expectedOutput.count
}

main()
