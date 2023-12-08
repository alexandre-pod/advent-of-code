import Foundation

struct Map {
    let instructions: [Direction]
    let nodes: [Node]
}

struct Node {
    let name: String
    let left: String
    let right: String
}

enum Direction: Character {
    case left = "L"
    case right = "R"
}

func main() {
    let map = parseMap()

    print(part1(map: map))
    print(part2(map: map))
}

func parseMap() -> Map {
    let instructions = readLine()!.map { Direction(rawValue: $0)! }
    _ = readLine()
    var nodes: [Node] = []
    while let line = readLine() {
       let parts = line
            .split(separator: "=")
            .map { $0.trimmingCharacters(in: .whitespaces) }
        let destinations = parts[1]
            .filter { $0 != "(" && $0 != ")" && $0 != " " }
            .split(separator: ",")
        nodes.append(
            Node(
                name: parts[0],
                left: String(destinations[0]),
                right: String(destinations[1])
            )
        )
    }
    return Map(instructions: instructions, nodes: nodes)
}

// MARK: - Part 1

func part1(map: Map) -> Int {
    return map.distance(from: "AAA", to: "ZZZ")
}

extension Map {
    func distance(from startPosition: String, to endPosition: String) -> Int {
        var distance = 0
        var position = startPosition

        let nodesMap: [String: Node] = nodes.reduce(into: [:]) { $0[$1.name] = $1 }

        var directions = sequence(state: (0, instructions)) { state in
            defer {
                state.0 = (state.0 + 1) % state.1.count
            }
            return state.1[state.0]
        }

        while position != endPosition {
            distance += 1
            position = nodesMap[position]!.destination(for: directions.next()!)
        }

        return distance
    }
}

extension Node {
    func destination(for direction: Direction) -> String {
        switch direction {
        case .left:
            return self.left
        case .right:
            return self.right
        }
    }
}

// MARK: - Part 2

func part2(map: Map) -> Int {
    let startNodes = map.nodes.filter { $0.name.hasSuffix("A") }.map(\.name)
    let loopLengths = startNodes.map { map.distanceToNearestEnd(from: $0) }

    return leastCommonMultiple(from: loopLengths)
//    return slowLeastCommonMultiple(from: loopLengths)
}

func slowLeastCommonMultiple(from numbers: [Int]) -> Int {
    let smallest = numbers.min()!
    var leastCommonMultiple = smallest
    while !numbers.allSatisfy({ leastCommonMultiple % $0 == 0 }) {
        leastCommonMultiple += smallest
    }
    return leastCommonMultiple
}

extension Map {
    func parallelDistance(from startPositions: [String]) -> Int {
        var distance = 0
        var positions = startPositions

        let nodesMap: [String: Node] = nodes.reduce(into: [:]) { $0[$1.name] = $1 }

        var directions = sequence(state: (0, instructions)) { state in
            defer {
                state.0 = (state.0 + 1) % state.1.count
            }
            return state.1[state.0]
        }

        while !positions.allSatisfy({ $0.hasSuffix("Z") }) {
            distance += 1
            let nextDirection = directions.next()!
            positions = positions.map {
                nodesMap[$0]!.destination(for: nextDirection)
            }
        }

        return distance
    }

    func distanceToNearestEnd(from startPosition: String, 
                              instructionOffset: Int = 0,
                              checkLoop: Bool = true) -> Int {
        var distance = 0
        var position = startPosition
        var instructionOffset = instructionOffset

        let nodesMap: [String: Node] = nodes.reduce(into: [:]) { $0[$1.name] = $1 }

        while !position.hasSuffix("Z") {
            distance += 1
            let direction = instructions[instructionOffset]
            instructionOffset = (instructionOffset + 1) % instructions.count
            position = nodesMap[position]!.destination(for: direction)
        }

        #if DEBUG
        let nextDirection = instructions[instructionOffset]
        let nextPosition = nodesMap[position]!.destination(for: nextDirection)

        print("\(startPosition) -> \(position) : \(distance)")
        print("next direction: \(nextDirection)")
        print("next position: \(nextPosition)")

        if checkLoop {
            print("Looping?")
            _ = self.distanceToNearestEnd(
                from: nextPosition,
                instructionOffset: instructionOffset + 1,
                checkLoop: false
            )

        }
        #endif

        return distance
    }
}

func leastCommonMultiple(from numbers: [Int]) -> Int {
    var leastCommonMultipleFactors: [Int: Int] = [:]

    for number in numbers {
        number.primeFactors
            .reduce(into: [Int: Int]()) { primeFactors, factor in
                primeFactors[factor, default: 0] += 1
            }
            .forEach { (key: Int, value: Int) in
                leastCommonMultipleFactors[key] = max(leastCommonMultipleFactors[key] ?? 0, value)
            }
    }

    return leastCommonMultipleFactors
        .map { Int(pow(Double($0.key), Double($0.value))) }
        .reduce(1, *)
}

extension Int {
    var primeFactors: [Int] {
        let primes = primeNumbers(below: self)

        var remaining = self
        var factors: [Int] = []

        for prime in primes {
            while remaining.isMultiple(of: prime) {
                factors.append(prime)
                remaining = remaining / prime
            }
        }
        assert(remaining == 1)
        return factors
    }
}

/// if below is prime it will be returned
func primeNumbers(below maxValue: Int) -> some Sequence<Int> {
    var primeCandidates: Set<Int> = [2]
    primeCandidates.formUnion((3...maxValue).filter { $0 % 2 != 0 })

    var current = 3
    while current <= maxValue {
        defer { current += 1 }
        guard primeCandidates.contains(current) else { continue }
        var factor = 2
        while current * factor <= maxValue {
            primeCandidates.remove(current * factor)
            factor += 1
        }
    }


    return primeCandidates
}

main()
