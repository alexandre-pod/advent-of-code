import Foundation

struct CPU {
    var x: Int
}

struct Instruction: CustomStringConvertible {

    let description: String
    let cycleDuration: Int
    let operation: (inout CPU) -> Void

    static let noop = Instruction(description: "noop", cycleDuration: 1) { _ in }
    static func addx(_ value: Int) -> Instruction {
        Instruction(description: "addx \(value)", cycleDuration: 2) {
            $0.x += value
        }
    }
}

typealias Program = [Instruction]

func main() {
    var program: Program = []

    while let line = readLine() {
        let components = line.split(separator: " ")
        switch String(components[0]) {
        case "noop":
            program.append(.noop)
        case "addx":
            program.append(.addx(Int(String(components[1]))!))
        default:
            fatalError("Invalid instruction: \(components[0])")
        }
    }

    print(part1(program: program))
    part2(program: program)
}

// MARK: - Part 1

func part1(program: Program) -> Int {
    var cpu = CPU(x: 1)
    var cycle = 1
    var resultValue = 0
    var nextImportantCycle = 20

    for instruction in program {
        cycle += instruction.cycleDuration
        if cycle > nextImportantCycle {
            resultValue += nextImportantCycle * cpu.x
            nextImportantCycle += 40
        }
        instruction.operation(&cpu)

    }

    return resultValue
}

// MARK: - Part 2

struct CRTScreen {
    let width = 40
    let height = 6

    private(set) var pixels: [[String]] = []

    mutating func addPixelsLine(_ line: [String]) {
        assert(line.count == width)
        pixels.append(line)
    }

    func printDisplay() {
        for line in pixels {
            print(line.joined())
        }
    }
}

func part2(program: Program) {

    var cpu = CPU(x: 1)
    var cycle = 1

    var crtScreen = CRTScreen()
    var currentPixelsLine: [String] = []

    for instruction in program {
        for _ in 0..<instruction.cycleDuration {
            if currentPixelsLine.count == crtScreen.width {
                crtScreen.addPixelsLine(currentPixelsLine)
                currentPixelsLine = []
            }
            let currentLineIndex = (cycle - 1) % crtScreen.width
            currentPixelsLine.append(abs(currentLineIndex - cpu.x) <= 1 ? "#" : " ")
            cycle += 1
        }
        instruction.operation(&cpu)

    }
    crtScreen.addPixelsLine(currentPixelsLine)

    crtScreen.printDisplay()
}

main()
