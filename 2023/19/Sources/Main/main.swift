import Foundation

struct InputType {
    let workflows: [Workflow]
    let initialStates: [State]
}

struct State {
    var x: Int
    var m: Int
    var a: Int
    var s: Int
}

struct Workflow {
    let name: String
    let instructions: [Instruction]
}

enum Instruction {
    case lessThan(variable: Variable, value: Int, jump: String)
    case greaterThan(variable: Variable, value: Int, jump: String)
    case jump(String)
}

enum Variable: Character {
    case x = "x"
    case m = "m"
    case a = "a"
    case s = "s"
}

func main() {
    var workflows: [Workflow] = []

    while let line = readLine(), !line.isEmpty {
        workflows.append(parseWorkflow(from: line))
    }

    var initialStates: [State] = []

    while let line = readLine() {
        initialStates.append(parseState(from: line))
    }

    let input = InputType(workflows: workflows, initialStates: initialStates)

    print(part1(inputParameter: input))
    print(part2(inputParameter: input))
}

func parseWorkflow(from line: String) -> Workflow {

    let parts = line.split(separator: "{")
    let instructionStrings = parts[1].dropLast().split(separator: ",")

    return Workflow(
        name: String(parts[0]),
        instructions: instructionStrings.map { parseInstruction(from: String($0)) }
    )
}

func parseInstruction(from instruction: String) -> Instruction {
    if instruction.contains("<") {
        let parts = instruction.split(separator: "<")
        let parts2 = parts[1].split(separator: ":")
        return .lessThan(
            variable: parseVariable(from: String(parts[0])),
            value: Int(String(parts2[0]))!,
            jump: String(parts2[1])
        )
    } else if instruction.contains(">") {
        let parts = instruction.split(separator: ">")
        let parts2 = parts[1].split(separator: ":")
        return .greaterThan(
            variable: parseVariable(from: String(parts[0])),
            value: Int(String(parts2[0]))!,
            jump: String(parts2[1])
        )
    } else {
        return .jump(instruction)
    }
}

func parseVariable(from string: String) -> Variable {
    return switch string {
    case "x": .x
    case "m": .m
    case "a": .a
    case "s": .s
    default:
        fatalError("Invalid input")
    }
}

func parseState(from line: String) -> State {
    var state = State(x: .min, m: .min, a: .min, s: .min)
    line.dropFirst().dropLast().split(separator: ",").forEach {
        let parts = $0.split(separator: "=")
        let value = Int(String(parts[1]))!
        let variable = parseVariable(from: String(parts[0]))
        state[variable] = value
    }

    return state
}

extension State {
    subscript(_ variable: Variable) -> Int {
        get { self[keyPath: keyPath(for: variable)] }
        set { self[keyPath: keyPath(for: variable)] = newValue }
    }

    private func keyPath(for variable: Variable) -> WritableKeyPath<Self, Int> {
        return switch variable {
        case .x: \.x
        case .m: \.m
        case .a: \.a
        case .s: \.s
        }
    }
}

// MARK: - Part 1

func part1(inputParameter: InputType) -> Int {
    return inputParameter.initialStates
        .filter { executeProgram(inputParameter.workflows, state: $0) }
        .map { $0.x + $0.m + $0.a + $0.s }
        .reduce(0, +)
}

func executeProgram(_ workflows: [Workflow], state: State) -> Bool {

    var currentWorkflowName = "in"

    while currentWorkflowName != "R" && currentWorkflowName != "A" {
        let workflow = workflows.first { $0.name == currentWorkflowName }!
        currentWorkflowName = executeWorkflow(workflow, state: state)
    }

    return currentWorkflowName == "A"
}

func executeWorkflow(_ workflow: Workflow, state: State) -> String {
    for instruction in workflow.instructions {
        switch instruction {
        case .lessThan(let variable, let value, let jump):
            if state[variable] < value {
                return jump
            }
        case .greaterThan(let variable, let value, let jump):
            if state[variable] > value {
                return jump
            }
        case .jump(let name):
            return name
        }
    }
    fatalError("Failed workflow")
}

// MARK: - Part 2

func part2(inputParameter: InputType) -> Int {

    return validStateCombinations(for: inputParameter.workflows)
        .map(\.combination)
        .reduce(0, +)
}

struct StateCombinations {
    var x = 1..<4001
    var m = 1..<4001
    var a = 1..<4001
    var s = 1..<4001
}

extension StateCombinations {

    subscript(_ variable: Variable) -> Range<Int> {
        get { self[keyPath: keyPath(for: variable)] }
        set { self[keyPath: keyPath(for: variable)] = newValue }
    }

    var combination: Int {
        return x.count * m.count * a.count * s.count
    }

    var isEmpty: Bool {
        return combination == 0
    }

    static let empty = StateCombinations(x: 1..<1, m: 1..<1, a: 1..<1, s: 1..<1)

    // MARK: - Private

    private func keyPath(for variable: Variable) -> WritableKeyPath<Self, Range<Int>> {
        return switch variable {
        case .x: \.x
        case .m: \.m
        case .a: \.a
        case .s: \.s
        }
    }
}

func validStateCombinations(for workflows: [Workflow]) -> [StateCombinations] {

    var validStates: [StateCombinations] = []
    var invalidStates: [StateCombinations] = []

    var pendingStates: [(StateCombinations, String)] = [(StateCombinations(), "in")]

    while !pendingStates.isEmpty {
        let (states, workflowName) = pendingStates.removeLast()
        let workflow = workflows.first { $0.name == workflowName }!
        let results = resultingStates(running: workflow, states: states)

        for result in results {
            switch result.1 {
            case "A":
                validStates.append(result.0)
            case "R":
                invalidStates.append(result.0)
            default:
                pendingStates.append(result)
            }
        }
    }

    let validCombinations = validStates.map(\.combination).reduce(0, +)
    let invalidCombinations = invalidStates.map(\.combination).reduce(0, +)

//    print("Valid states", validCombinations, separator: "\n")
//    print("Invalid states", invalidCombinations, separator: "\n")
//
//    print("States sum", validCombinations + invalidCombinations, separator: "\n")
//    print("States possible combinations", validCombinations + invalidCombinations, separator: "\n")

    return validStates
}

func resultingStates(running workflow: Workflow, states: StateCombinations) -> [(StateCombinations, String)] {

    var remainingStates = states
    var results: [(StateCombinations, String)] = []

    for instruction in workflow.instructions {
        guard !remainingStates.isEmpty else { break }
        switch instruction {
        case .lessThan(let variable, let value, let jump):
            let range = remainingStates[variable]
            if range.contains(value) {
                let lowRange = range.lowerBound..<value
                let upRange = value..<range.upperBound

                var lowCombinations = remainingStates
                lowCombinations[variable] = lowRange

                results.append((lowCombinations, jump))

                remainingStates[variable] = upRange
            }
        case .greaterThan(let variable, let value, let jump):
            let range = remainingStates[variable]
            if range.contains(value) {
                let lowRange = range.lowerBound..<value + 1
                let upRange = (value+1)..<range.upperBound

                var upCombinations = remainingStates
                upCombinations[variable] = upRange

                results.append((upCombinations, jump))

                remainingStates[variable] = lowRange
            }
        case .jump(let name):
            results.append((remainingStates, name))
            remainingStates = .empty
        }
    }
    return results
}

main()
