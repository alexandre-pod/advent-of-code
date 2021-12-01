import Foundation

func main() {
    let input = readLine()!
    let cupsLabels = input.map { Int(String($0))! }

    part1(cupsLabels: cupsLabels)
    part2(cupsLabels: cupsLabels)
}

// MARK: - Part 1

func part1(cupsLabels: [Int]) {
    var crabCupsGame = CrabCupsGame(cupsLabels: cupsLabels)

//    for round in 1...10 {
//        print("======")
//        print("Round \(round): \(crabCupsGame)")
//        crabCupsGame.playRound()
//    }
//    print("======")
//    print("Final state: \(crabCupsGame)")

    let rounds = 100

    for _ in 1...rounds {
        crabCupsGame.playRound()
    }

    let finalCups = crabCupsGame.cupsLabels
    let oneIndex = finalCups.firstIndex(of: 1)!
    let answer = (1..<finalCups.count)
        .map { ($0 + oneIndex) % finalCups.count }
        .map { String(finalCups[$0]) }
        .joined()

    print("answer: \(answer)")
}

struct CrabCupsGame {

    typealias Cup = Int

    private (set) var currentCupIndex: Int = 0
    private (set) var cupsLabels: [Cup]

    init(cupsLabels: [Cup]) {
        precondition(cupsLabels.count >= 4)
        self.cupsLabels = cupsLabels
    }

    mutating func playRound() {
        let nextThreeCups = removeThreeCupsAfterCurrent()

        let currentCup = cupsLabels[currentCupIndex]
        let biggestLabel = cupsLabels.max()!

        let targetCupValue = currentCup - 1
        let destinationIndex = cupsLabels.enumerated()
            .map {
                (
                    offset: $0.offset,
                    distance: $0.element > targetCupValue
                        ? $0.element - biggestLabel
                        : $0.element
                )
            }
            .max { $0.distance < $1.distance }!
            .offset

        cupsLabels.insert(contentsOf: nextThreeCups, at: destinationIndex + 1)

        if destinationIndex < currentCupIndex {
            currentCupIndex = (currentCupIndex + 4) % cupsLabels.count
        } else {
            currentCupIndex = (currentCupIndex + 1) % cupsLabels.count
        }
    }

    private mutating func removeThreeCupsAfterCurrent() -> [Cup] {
        let startIndex = currentCupIndex + 1
        let endIndex = startIndex + 2

        let boundedIndicies = (startIndex...endIndex).map { $0 % cupsLabels.count }
        let values = boundedIndicies.map { cupsLabels[$0] }

        boundedIndicies.sorted(by: (>)).forEach { cupsLabels.remove(at: $0) }

        boundedIndicies
            .filter { $0 < currentCupIndex }
            .forEach { _ in currentCupIndex -= 1 }

        return values
    }

    private func threeCupsIndiciesAfterCurrent() -> [Int] {
        let startIndex = currentCupIndex + 1
        let endIndex = startIndex + 2

        return (startIndex...endIndex).map { $0 % cupsLabels.count }
    }

    private func threeCupsAfterCurrent() -> [Cup] {
        return threeCupsIndiciesAfterCurrent().map { cupsLabels[$0] }
    }
}

// MARK: - Part 2

func part2(cupsLabels: [Int]) {

    let maxLabel = cupsLabels.max()! + 1

    let completedCupsLabels = cupsLabels + Array(maxLabel..<(maxLabel + (1_000_000 - cupsLabels.count)))
    var crabCupsGame = CrabCupsGameOptimized(cupsLabels: completedCupsLabels)

    let rounds = 10_000_000
//    for round in 1...rounds {
//        if round % 100_000 == 0 {
//            print("\(round) / \(rounds)")
//        }
//        crabCupsGame.playRound()
//    }

    for _ in 1...rounds {
        crabCupsGame.playRound()
    }

    let firstNextToOne = crabCupsGame.getCupNextTo(1)
    let secondNextToOne = crabCupsGame.getCupNextTo(firstNextToOne)

    let answer = firstNextToOne * secondNextToOne

    print("answer: \(answer)")
}

struct CrabCupsGameOptimized {

    typealias Cup = Int

    private var cupChain: CyclicLinkedList<Cup>
    private var currentCup: Node<Cup>
    private var nodesMap: [Cup: Node<Cup>]

    private let maxCupValue: Cup

    init(cupsLabels: [Cup]) {
        precondition(cupsLabels.count >= 4)
        let cupChain = CyclicLinkedList(values: cupsLabels)
        let nodesMap = Dictionary(grouping: cupChain.nodes, by: { $0.value }).mapValues { $0.first! }

        self.maxCupValue = cupsLabels.max()!
        self.cupChain = cupChain
        self.nodesMap = nodesMap
        self.currentCup = nodesMap[cupsLabels[0]]!
    }

    mutating func playRound() {
        let nextThreeCups = cupChain.removeNodes(number: 3, after: currentCup)

        let destinationCup = getDestinationCup(excluding: nextThreeCups.map(\.value))

        cupChain.add(contentsOf: nextThreeCups, after: destinationCup)
        currentCup = currentCup.next!
    }

    func getCupNextTo(_ cup: Cup) -> Cup {
        return nodesMap[cup]!.next!.value
    }

    // MARK: - Private

    private func getDestinationCup(excluding excludedCups: [Cup]) -> Node<Cup> {
        var destinationValue = currentCup.value - 1

        while excludedCups.contains(destinationValue) || nodesMap[destinationValue] == nil {
            if destinationValue <= 0 {
                destinationValue = maxCupValue
            } else {
                destinationValue -= 1
            }
        }

        return nodesMap[destinationValue]!
    }
}

// MARK: - Debug

extension CrabCupsGame: CustomStringConvertible {
    var description: String {
        return cupsLabels.enumerated().map {
            $0.offset == currentCupIndex
                ? "(\($0.element))"
                : " \($0.element) "
        }.joined()
    }
}

main()
