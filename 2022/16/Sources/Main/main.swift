import Foundation

struct Valve {
    let id: String
    let flow: Int
    let connectedToValves: [String]
}

typealias InputType = [Valve]

func main() {
    var input: InputType = []

    while let line = readLine() {

        let components1 = line.split(separator: "=")
        let components11 = components1[0].split(separator: " ")
        let components12 = components1[1].split(separator: ";")
        let components13 = components1[1].split(separator: ",")

        let valveName = String(components11[1])
        let valveFlow = Int(String(components12[0]))!

        var valveAccess: [String] = []
        valveAccess.append(String(components13[0].split(separator: " ").last!))
        valveAccess += components13
            .dropFirst()
            .map { $0.trimmingCharacters(in: .whitespaces) }

        input.append(
            Valve(id: valveName, flow: valveFlow, connectedToValves: valveAccess)
        )
    }

    print(part1(inputParameter: input))
    print(part2(inputParameter: input))
}

// MARK: - Part 1

func part1(inputParameter: InputType) -> Int {

    let valvesMap = Dictionary.init(uniqueKeysWithValues: inputParameter.map { ($0.id, $0) })
    var distances: [String: [String: Int]] = [:]

    valvesMap.values.forEach {
        distances[$0.id] = getDistances(from: $0, in: valvesMap)
    }

    let bestPressureReleased = findBestPath(
        from: valvesMap["AA"]!,
        valves: valvesMap,
        distances: distances,
        openValves: Set(valvesMap.filter { $0.value.flow == 0 }.map { $0.key }),
        remainingTime: 30,
        pressureReleased: 0
    )

    return bestPressureReleased
}

func findBestPath(
    from valve: Valve,
    valves: [String: Valve],
    distances: [String: [String: Int]],
    openValves: Set<String>,
    remainingTime: Int,
    pressureReleased: Int
) -> Int {
    guard remainingTime > 0 else {
        return pressureReleased
    }
    var maxPressureReleased = pressureReleased
    for targetValve in valves.values {
        if openValves.contains(targetValve.id) { continue }
        let distance = distances[valve.id]?[targetValve.id] ?? 0
        if distance > remainingTime { continue }
        let timeAfterMove = remainingTime - distance
        let timeAfterOpen = timeAfterMove - 1

        let released = findBestPath(
            from: targetValve,
            valves: valves,
            distances: distances,
            openValves: openValves.union([targetValve.id]),
            remainingTime: timeAfterOpen,
            pressureReleased: pressureReleased + targetValve.flow * timeAfterOpen
        )
        maxPressureReleased = max(released, maxPressureReleased)
    }
    return maxPressureReleased
}

func getDistances(from valve: Valve, in valves: [String: Valve]) -> [String: Int] {

    var result: [String: Int] = [valve.id: 0]
    var addedValves: [String] = [valve.id]
    var fullyHandledValves: Set<String> = []

    while !addedValves.isEmpty {
        let currentValve = addedValves.removeFirst()
        fullyHandledValves.insert(currentValve)
        let distance = result[currentValve]!
        valves[currentValve]!.connectedToValves
            .filter { !fullyHandledValves.contains($0) && !addedValves.contains($0) }
            .forEach {
                result[$0] = distance + 1
                addedValves.append($0)
            }
    }

    result[valve.id] = nil

    return result
}

// MARK: - Part 2

func part2(inputParameter: InputType) -> Int {

    let valvesMap = Dictionary.init(uniqueKeysWithValues: inputParameter.map { ($0.id, $0) })
    var distances: [String: [String: Int]] = [:]

    valvesMap.values.forEach {
        distances[$0.id] = getDistances(from: $0, in: valvesMap)
    }

    let bestPressureReleased = findBestPathPart2(
        from: valvesMap["AA"]!,
        and: valvesMap["AA"]!,
        explorer1BusyFor: 0,
        explorer2BusyFor: 0,
        valves: valvesMap,
        distances: distances,
        openValves: Set(valvesMap.filter { $0.value.flow == 0 }.map { $0.key }),
        remainingTime: 26,
        pressureReleased: 0
    )

    return bestPressureReleased
}

func findBestPathPart2(
    from valve1: Valve,
    and valve2: Valve,
    explorer1BusyFor explorer1BusyTime: Int,
    explorer2BusyFor explorer2BusyTime: Int,
    valves: [String: Valve],
    distances: [String: [String: Int]],
    openValves: Set<String>,
    remainingTime: Int,
    pressureReleased: Int
) -> Int {

    guard remainingTime > 0 else {
        return pressureReleased
    }

    guard openValves.count < valves.count else {
        return pressureReleased
    }

    if explorer1BusyTime != 0 && explorer2BusyTime != 0 {
        let skipTime = min(explorer1BusyTime, explorer2BusyTime, remainingTime)
        return findBestPathPart2(
            from: valve1,
            and: valve2,
            explorer1BusyFor: explorer1BusyTime - skipTime,
            explorer2BusyFor: explorer2BusyTime - skipTime,
            valves: valves,
            distances: distances,
            openValves: openValves,
            remainingTime: remainingTime - skipTime,
            pressureReleased: pressureReleased
        )
    }

    if explorer1BusyTime == 0 {
        return valves.values
            .filter { !openValves.contains($0.id) }
            .filter { (distances[valve1.id]?[$0.id] ?? 0) < remainingTime }
            .map { targetValve1 in
                let distance1 = distances[valve1.id]?[targetValve1.id] ?? 0
                let timeAfterMove = remainingTime - distance1
                let timeAfterOpen = timeAfterMove - 1

                return findBestPathPart2(
                    from: targetValve1,
                    and: valve2,
                    explorer1BusyFor: distance1 + 1,
                    explorer2BusyFor: explorer2BusyTime,
                    valves: valves,
                    distances: distances,
                    openValves: openValves.union([targetValve1.id]),
                    remainingTime: remainingTime,
                    pressureReleased: pressureReleased + targetValve1.flow * timeAfterOpen
                )
            }
            .max() ?? pressureReleased
    } else if explorer2BusyTime == 0 {
        return valves.values
            .filter { !openValves.contains($0.id) }
            .filter { (distances[valve2.id]?[$0.id] ?? 0) < remainingTime }
            .map { targetValve2 in
                let distance2 = distances[valve2.id]?[targetValve2.id] ?? 0
                let timeAfterMove = remainingTime - distance2
                let timeAfterOpen = timeAfterMove - 1

                return findBestPathPart2(
                    from: valve1,
                    and: targetValve2,
                    explorer1BusyFor: explorer1BusyTime,
                    explorer2BusyFor: distance2 + 1,
                    valves: valves,
                    distances: distances,
                    openValves: openValves.union([targetValve2.id]),
                    remainingTime: remainingTime,
                    pressureReleased: pressureReleased + targetValve2.flow * timeAfterOpen
                )
            }
            .max() ?? pressureReleased
    } else {
        fatalError()
    }
}

main()
