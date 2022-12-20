import Foundation

typealias InputType = [Int]

func main() {
    var input: InputType = []

    while let line = readLine() {
        input.append(Int(line)!)
    }

    print(part1(values: input))
    print(part2(values: input))
}

// MARK: - Part 1

class Node: CustomStringConvertible {
    let value: Int
    
    init(value: Int) {
        self.value = value
    }

    var description: String { "\(value)" }
}

func part1(values: InputType) -> Int {
    let nodes = values.map { Node(value: $0) }
    var orderedNodes = nodes

    for node in nodes {
        let startIndex = orderedNodes.firstIndex { $0 === node }!
        var endIndex = startIndex + node.value
        while endIndex <= 0 {
            endIndex += nodes.count - 1
        }
        while endIndex >= nodes.count {
            endIndex -= nodes.count - 1
        }

        orderedNodes.remove(at: startIndex)
        orderedNodes.insert(node, at: endIndex)
    }

    let zeroIndex = orderedNodes.firstIndex { $0.value == 0 }!

    let points = [
        orderedNodes[(zeroIndex + 1000) % orderedNodes.count],
        orderedNodes[(zeroIndex + 2000) % orderedNodes.count],
        orderedNodes[(zeroIndex + 3000) % orderedNodes.count]
    ]

    return points.map(\.value).reduce(0, +)
}

// MARK: - Part 2

func part2(values: InputType) -> Int {
    let decryptionKey = 811589153
    let nodes = values.map { Node(value: $0 * decryptionKey) }
    var orderedNodes = nodes

    for _ in 0..<10 {
        for node in nodes {
            let startIndex = orderedNodes.firstIndex { $0 === node }!

            orderedNodes.remove(at: startIndex)
            var endIndex = startIndex + node.value

            endIndex = endIndex % (nodes.count - 1)
            endIndex = (endIndex + (nodes.count - 1)) % (nodes.count - 1)

            orderedNodes.insert(node, at: endIndex)
        }
    }

    let zeroIndex = orderedNodes.firstIndex { $0.value == 0 }!

    let points = [
        orderedNodes[(zeroIndex + 1000) % orderedNodes.count],
        orderedNodes[(zeroIndex + 2000) % orderedNodes.count],
        orderedNodes[(zeroIndex + 3000) % orderedNodes.count]
    ]

    return points.map(\.value).reduce(0, +)
}

main()
