import Foundation

func main() {
    var values: [Int] = []
    while let line = readLine() {
        values.append(Int(line)!)
    }
    part1(values: values)
    part2(values: values)
}

func part1(values: [Int]) {
    let sortedValues = values.sorted()
    let withEndDevices = [0] + sortedValues + [sortedValues.last! + 3]
    let differences = zip(withEndDevices, withEndDevices[1...]).map { $0.1 - $0.0 }

    let oneDifferencesCount = differences.filter { $0 == 1 }.count
    let threeDifferencesCount = differences.filter { $0 == 3 }.count

    let answer = oneDifferencesCount * threeDifferencesCount

    print("answer: \(answer)")
}

func part2(values: [Int]) {
    let sortedValues = values.sorted()
    let withEndDevices = [0] + sortedValues + [sortedValues.last! + 3]

    let indicies = withEndDevices.indices.map { $0 }
    let graph = destinationGraph(values: withEndDevices)
    var combinationFrom: [Int: Int] = [:]

    for index in indicies.reversed() {
        let nodeDest = graph[index]!
        assert(nodeDest.allSatisfy { $0 > index })
        if nodeDest.isEmpty { // end case
            combinationFrom[index] = 1
        } else {
            combinationFrom[index] = nodeDest.map { combinationFrom[$0]! }.reduce(0, (+))
        }
    }

    let answer = combinationFrom[0]!
    print("answer: \(answer)")
}

func destinationGraph(values: [Int]) -> [Int: [Int]] {
    var graph: [Int: [Int]] = [:]
    for (index, value) in values.enumerated() {
        var nextIndex = index + 1
        var destIndexes: [Int] = []
        while nextIndex < values.count, values[nextIndex] - value <= 3 {
            destIndexes.append(nextIndex)
            nextIndex += 1
        }
        graph[index] = destIndexes
    }
    return graph
}

main()
