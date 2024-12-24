import Foundation

struct Circuit {
    var wireStates: [String: Bool]
    var logicGates: [LogicGate]
}

struct LogicGate {
    let input1: String
    let input2: String
    var output: String
    let operation: Operation
}

extension LogicGate {
    enum Operation: String {
        case and = "AND"
        case xor = "XOR"
        case or = "OR"
    }
}

func main() {

    var wireStates: [String: Bool] = [:]

    while let line = readLine(), !line.isEmpty {
        let components = line.split(separator: ":")
        let name = String(components[0])
        let value = components[1].trimmingCharacters(in: .whitespaces) == "1"
        wireStates[name] = value
    }

    var logicGates: [LogicGate] = []

    while let line = readLine(), !line.isEmpty {
        let components = line.split(separator: " ")
        let logicGate = LogicGate(
            input1: String(components[0]),
            input2: String(components[2]),
            output: String(components[4]),
            operation: LogicGate.Operation(rawValue: String(components[1]))!
        )
        logicGates.append(logicGate)
    }

    var input = Circuit(wireStates: wireStates, logicGates: logicGates)

    print(part1(circuit: input))
    print(part2(circuit: input))
}

// MARK: - Part 1

func part1(circuit: Circuit) -> Int {
    let signals = propagateSignals(in: circuit)

    let zSignals = signals
        .filter { $0.key.hasPrefix("z") }
        .sorted { $0.key < $1.key }

    let finalNumber = zSignals.reversed().map(\.value).reduce(0) { $0 << 1 + ($1 ? 1 : 0) }

    return finalNumber
}

func propagateSignals(in circuit: Circuit) -> [String: Bool] {

    var signals: [String: Bool] = circuit.wireStates
    var remainingLogicGates: [LogicGate] = circuit.logicGates

    while let gateIndex = remainingLogicGates.firstIndex(where: {
        signals.keys.contains($0.input1) && signals.keys.contains($0.input2)
    }) {
        let logicGate = remainingLogicGates[gateIndex]
        remainingLogicGates.remove(at: gateIndex)

        let output = logicGate.execute(with: signals)
        signals[logicGate.output] = output
    }

    return signals
}

extension LogicGate {
    func execute(with signals: [String: Bool]) -> Bool {
        let input1 = signals[input1]!
        let input2 = signals[input2]!
        switch operation {
        case .and:
            return input1 && input2
        case .or:
            return input1 || input2
        case .xor:
            return input1 != input2
        }
    }
}

// MARK: - Part 2

func part2(circuit: Circuit) -> String {

//    print("digraph G {")
//    for gate in circuit.logicGates {
//        print(gate.input1, "->", gate.output)
//        print(gate.input2, "->", gate.output)
//        print(gate.output, "[label = \"\(gate.output).\(gate.operation.rawValue)\"]")
//    }
//    print("}")


//    print("0, 0", circuit.execute(x: 0, y: 0))
//
//    fatalError()


    for i in 0...44 {
        let computedZ = circuit.execute(x: 1 << i, y: 1 << i)
        let expectedZ = 1 << (i + 1)
        if expectedZ != computedZ {
            print("i:", i)
            print(computedZ, "valid?", expectedZ == computedZ)
        }
    }

    // Manual patching
    var circuit = circuit
    circuit.exchangeOutput("z11", "wpd")
    circuit.exchangeOutput("jqf", "skh")
    circuit.exchangeOutput("mdd", "z19")
    circuit.exchangeOutput("z37", "wts")


    let patched = [
        "z11", "wpd",
        "jqf", "skh",
        "mdd", "z19",
        "z37", "wts"
    ]

    var maxValidIndex = 0
    while maxValidIndex < 44 {
        let x = 1 << maxValidIndex
        let y = 1 << maxValidIndex
        let add00 = circuit.execute(x: 0, y: 0)
        let add01 = circuit.execute(x: 0, y: y)
        let add11 = circuit.execute(x: x, y: y)
        let add10 = circuit.execute(x: x, y: 0)
        guard add00 == 0, add01 == y, add10 == x, add11 == x+y
        else {
            print("valid until", maxValidIndex)
            print("add00", add00, "expected:", 0 + 0)
            print("add01", add01, "expected:", 0 + y)
            print("add11", add11, "expected:", x + y)
            print("add10", add10, "expected:", x + 0)
            fatalError()
        }
        maxValidIndex += 1
    }
    return patched.sorted().joined(separator: ",")


    // Bruteforce attempt

//        let xInputs = circuit.wireStates.filter { $0.key.hasPrefix("x") }
//        let yInputs = circuit.wireStates.filter { $0.key.hasPrefix("y") }
//
//        let x = xInputs.sorted { $0.key < $1.key }.reversed().map(\.value).reduce(0) { $0 << 1 + ($1 ? 1 : 0) }
//        let y = yInputs.sorted { $0.key < $1.key }.reversed().map(\.value).reduce(0) { $0 << 1 + ($1 ? 1 : 0) }
//
//        let expectedZ = x + y
//        let logicGates = circuit.logicGates
//
//        // sample3
//    //    let swaps = getSwappedOutputs(fromIndex: 0, in: circuit, forResult: x & y, swapRemaining: 2, swappedPositions: [])
//
//        // input
//        let swaps = getSwappedOutputs(fromIndex: 0, in: circuit, forResult: x + y, swapRemaining: 4, swappedPositions: [])
//
//
//        return swaps!.flatMap { $0.map { logicGates[$0].output } }.sorted().joined(separator: ",")
}

extension Circuit {
    mutating func exchangeOutput(_ output1: String, _ output2: String) {
        let invalid1 = logicGates.firstIndex { $0.output == output1 }!
        let invalid2 = logicGates.firstIndex { $0.output == output2 }!
        logicGates[invalid1].output = output2
        logicGates[invalid2].output = output1
    }
}

extension Circuit {
    func execute(x: Int, y: Int) -> Int {
        var updatedCircuit = self
        for (name, state) in updatedCircuit.wireStates {
            if name.hasPrefix("x") {
                let bit = Int(String(name.dropFirst()))!
                updatedCircuit.wireStates[name] = (x >> bit) & 1 == 1
            }
            if name.hasPrefix("y") {
                let bit = Int(String(name.dropFirst()))!
                updatedCircuit.wireStates[name] = (y >> bit) & 1 == 1
            }
        }
        return getZOutput(for: updatedCircuit)
    }
}

var cache: [[[Int]]: [[Int]]?] = [:]

func getSwappedOutputs(
    fromIndex startSwapIndex: Int,
    in circuit: Circuit,
    forResult result: Int,
    swapRemaining: Int,
    swappedPositions: [[Int]]
) -> [[Int]]? {
    print(swappedPositions)
    if let value = cache[swappedPositions] {
        return value
    }
    guard swapRemaining > 0 else {
        if getZOutput(for: circuit) == result {
            cache[swappedPositions] = swappedPositions
            return swappedPositions
        } else {
            cache[swappedPositions] = [[Int]]?.none
            return nil
        }
    }

    let possibleSwapPositions = Set(startSwapIndex..<circuit.logicGates.count).subtracting(swappedPositions.flatMap { $0 })
    let possiblePositions = possibleSwapPositions.sorted()

    for pairStart in possiblePositions {
        for pairEnd in possiblePositions where pairEnd > pairStart {
            var updatedCircuit = circuit
            var swap = [pairStart, pairEnd]
            updatedCircuit.logicGates[pairEnd].output = circuit.logicGates[pairStart].output
            updatedCircuit.logicGates[pairStart].output = circuit.logicGates[pairEnd].output


            if let validSwap = getSwappedOutputs(
                fromIndex: pairStart,
                in: updatedCircuit,
                forResult: result,
                swapRemaining: swapRemaining - 1,
                swappedPositions: swappedPositions + [swap]
            ) {
                return validSwap
            }
        }
    }
    return nil
}

func getZOutput(for circuit: Circuit) -> Int {
    let signals = propagateSignals(in: circuit)
    let zSignals = signals.filter { $0.key.hasPrefix("z") }
    let finalNumber = zSignals.sorted { $0.key < $1.key }.reversed().map(\.value).reduce(0) { $0 << 1 + ($1 ? 1 : 0) }
    return finalNumber
}

main()
