import Foundation

typealias ModuleMap = [String: Module]

enum Module {
    case broadcast([String])
    case flipFlop(on: Bool, connections: [String])
    case conjunction(lastSignals: [String: Signal], connections: [String])
}

extension Module {
    var isFlipFlop: Bool {
        guard case .flipFlop = self else { return false }
        return true
    }

    var isConjunction: Bool {
        guard case .conjunction = self else { return false }
        return true
    }
}

func main() {
    var input: [String: Module] = [:]

    while let line = readLine() {
        let (name, module) = parseModule(from: line)
        input[name] = module
    }

    input = initialiseConjunctionModuleState(in: input)

    print(part1(moduleMap: input))
    print(part2(moduleMap: input))
}

func parseModule(from line: String) -> (name: String, module: Module) {
    let parts = line.split(separator: " ")

    let connections = parts[2...].map { String($0.filter { $0 != "," }) }

    switch parts[0].first! {
    case "%":
        let name = String(parts[0].dropFirst())
        return (name, .flipFlop(on: false, connections: connections))
    case "&":
        let name = String(parts[0].dropFirst())
        return (name, .conjunction(lastSignals: [:], connections: connections))
    case "b":
        assert(parts[0] == "broadcaster")
        return ("broadcaster", .broadcast(connections))
    default:
        fatalError()
    }
}

func initialiseConjunctionModuleState(in moduleMap: [String: Module]) -> [String: Module] {
    var updatedMap = moduleMap

    let inputConnections = moduleInputs(in: moduleMap)

    for (name, module) in moduleMap {
        guard case let .conjunction(_, connections) = module else { continue }

        var lastSignals: [String: Signal] = [:]
        inputConnections[name]!.forEach {
            lastSignals[$0] = .low
        }

        updatedMap[name] = .conjunction(
            lastSignals: lastSignals,
            connections: connections
        )
    }

    return updatedMap
}

func moduleInputs(in moduleMap: [String: Module]) -> [String: Set<String>] {
    var inputConnections: [String: Set<String>] = [:]
    for (name, module) in moduleMap {
        module.connections.forEach {
            inputConnections[$0, default: []].insert(name)
        }
    }
    return inputConnections
}

extension Module {
    var connections: [String] {
        switch self {
        case .broadcast(let connections), .flipFlop(_, let connections), .conjunction(_, let connections):
            return connections
        }
    }
}

enum Signal: Equatable {
    case low
    case high
}

// MARK: - Part 1

func part1(moduleMap: ModuleMap) -> Int {
//    moduleMap.forEach {
//        print($0)
//    }

    var moduleMap = moduleMap

    var totalHigh = 0
    var totalLow = 0

    for _ in 0..<1000 {
        let result = pressButton(on: moduleMap)
        moduleMap = result.updatedModules

        totalHigh += result.highCount
        totalLow += result.lowCount
    }

    return totalLow * totalHigh
}

func pressButton(on moduleMap: ModuleMap) -> (updatedModules: ModuleMap, highCount: Int, lowCount: Int) {

    var highCount = 0
    var lowCount = 0

    var moduleMap = moduleMap

    var pendingSignals: [(target: String, signal: Signal, from: String)] = [
        ("broadcaster", .low, "button")
    ]

    while !pendingSignals.isEmpty {
        let (name, signal, source) = pendingSignals.removeFirst()
//        print("\(source) -\(signal)> \(name)")
        switch signal {
        case .low:
            lowCount += 1
        case .high:
            highCount += 1
        }
        guard moduleMap.keys.contains(name) else { continue }

        guard let nextSignal = moduleMap[name]!.processSignal(signal, from: source) else { continue }

        moduleMap[name]!.connections.forEach {
            pendingSignals.append((target: $0, signal: nextSignal, from: name))
        }
    }

    return (moduleMap, highCount, lowCount)
}

extension Module {
    mutating func processSignal(_ signal: Signal, from moduleName: String) -> Signal? {
        switch self {
        case .broadcast(let array):
            return signal
        case .flipFlop(let on, let connections):
            guard signal == .low else { return nil }
            self = .flipFlop(on: !on, connections: connections)
            return on ? .low : .high
        case .conjunction(var lastSignal, let connections):
            lastSignal[moduleName]! = signal
            self = .conjunction(lastSignals: lastSignal, connections: connections)
            return lastSignal.allHigh ? .low : .high
        }
    }
}

extension [String: Signal] {
    var allHigh: Bool {
        return values.allSatisfy { $0 == .high }
    }

    var allLow: Bool {
        return values.allSatisfy { $0 == .low }
    }
}

// MARK: - Part 2

func part2(moduleMap: ModuleMap) -> Int {
    let startZone = moduleMap["broadcaster"]!.connections
    let loopSizes = startZone.map { findLoopSize(from: $0, in: moduleMap) }
    return leastCommonMultiple(from: loopSizes)
}

func findLoopSize(from moduleName: String, in moduleMap: ModuleMap) -> Int {
    let chain = findFlipFlopChain(from: moduleName, in: moduleMap)
    return chain
        .map {
            moduleMap[$0]!.connections.contains(where: { moduleMap[$0]!.isConjunction }) ? 1 : 0
        }
        .reversed()
        .reduce(0) {
            $0 << 1 + $1
        }
}

func findFlipFlopChain(from moduleName: String, in moduleMap: ModuleMap) -> [String] {
    let module = moduleMap[moduleName]!
    assert(module.prefix == "%")

    let connectedFlipFlops = module.connections
        .map { (name: $0, module: moduleMap[$0]!) }
        .filter { $0.module.isFlipFlop }

    assert(connectedFlipFlops.count <= 1)

    if connectedFlipFlops.isEmpty {
        return [moduleName]
    } else {
        return [moduleName] + findFlipFlopChain(from: connectedFlipFlops[0].name, in: moduleMap)
    }
}

// MARK: - PArt 2 failed - bruteforce too long

func partBruteForce(moduleMap: ModuleMap) -> Int {

    guard moduleMap.values.contains(where: { $0.connections.contains("rx") }) else {
        fatalError("No connection to rx - part2 cannot be computed")
    }

//    let inputs = moduleInputs(in: moduleMap)
//    let rxInputs = inputs["rx"]!.map { moduleMap[$0]! }
//
//    print("rx inputs")
//    rxInputs.forEach {
//        print($0)
//    }
//
//    let jqInputs = inputs["jq"]!.map { moduleMap[$0]! }
//
//    print("jqInputs")
//    jqInputs.forEach { print($0) }
//
//
//    let subMap = moduleMap.subMapLimitedToInputs(of: "vr")
//
//    subMap.printMermaidGraph()
//
//    return -1

    var moduleMap = moduleMap
    var pressCount = 0

    while true {
        pressCount += 1
        if pressCount % 10000 == 0 {
            print("Trying \(pressCount)")
        }
        let result = pressButton(on: moduleMap, cycle: pressCount)
        guard !result.triggeredRXLow else {
            return pressCount
        }
        moduleMap = result.updatedModules
    }
}

extension ModuleMap {
    func subMapLimitedToInputs(of moduleName: String) -> ModuleMap {
        let inputs = moduleInputs(in: self)

        var finalMap: ModuleMap = [:]

        var pendingModules = [moduleName]

        while !pendingModules.isEmpty {
            let name = pendingModules.removeLast()
            finalMap[name] = self[name]
            (inputs[name] ?? [])
                .filter { !finalMap.keys.contains($0) }
                .forEach {
                    pendingModules.append($0)
                }
        }

        return finalMap
    }
}

func pressButton(on moduleMap: ModuleMap, cycle: Int) -> (updatedModules: ModuleMap, triggeredRXLow: Bool) {

    var moduleMap = moduleMap
    var triggeredRXLow = false

    var pendingSignals: [(target: String, signal: Signal, from: String)] = [
        ("broadcaster", .low, "button")
    ]

    while !pendingSignals.isEmpty {
        let (name, signal, source) = pendingSignals.removeFirst()
        print("\(source) -\(signal)> \(name) [\(cycle)]")
        if name == "output" { continue }
        if name == "rx" {
            if signal == .low {
                triggeredRXLow = true
            }
            continue
        }

        guard let nextSignal = moduleMap[name]!.processSignal(signal, from: source) else { continue }

        moduleMap[name]!.connections.forEach {
            pendingSignals.append((target: $0, signal: nextSignal, from: name))
        }
    }

    return (moduleMap, triggeredRXLow)
}


// MARK: - Visualisation

extension ModuleMap {
    func printMermaidGraph() {
        print("stateDiagram-v2")
        self.forEach { (key: String, value: Module) in
            print("    \(key): \(value.prefix)\(key)")
            for nodeName in value.connections {
                print("    \(key) --> \(nodeName)")
            }
        }
    }
}

extension Module {
    var prefix: String {
        switch self {
        case .broadcast(let array):
            return ""
        case .flipFlop(let on, let connections):
            return "%"
        case .conjunction(let lastSignals, let connections):
            return "&"
        }
    }
}

main()
