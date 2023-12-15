import Foundation

typealias Steps = [String]

func main() {
    let steps: Steps = readLine()!.split(separator: ",").map { String($0) }

    print(part1(steps: steps))
    print(part2(steps: steps))
}

// MARK: - Part 1

func part1(steps: Steps) -> Int {
    return steps.map { hash($0) }.reduce(0, +)
}

func hash(_ text: String) -> Int {
    text.map { Int($0.asciiValue!) }.reduce(0) { currentValue, asciiValue in
        return ((currentValue + asciiValue) * 17) % 256
    }
}

// MARK: - Part 2

enum Operation {
    case minus
    case equal(Int)
}

struct LabelledLens {
    let label: String
    let focalLength: Int
}

func part2(steps: Steps) -> Int {

    var hashmap: [[LabelledLens]] = Array(repeating: [], count: 256)

    for (label, operation) in steps.map({ parseStep($0) }) {
        let box = hash(label)
        switch operation {
        case .minus:
            hashmap[box].removeAll { $0.label == label }
        case .equal(let int):
            if let labeledLensIndex = hashmap[box].firstIndex(where: { $0.label == label }) {
                hashmap[box][labeledLensIndex] = LabelledLens(label: label, focalLength: int)
            } else {
                hashmap[box].append(LabelledLens(label: label, focalLength: int))
            }
        }

//        print("\(label) \(operation)")
//        hashmap.debugPrint()
    }

//    hashmap.debugPrint()

    return hashmap.focusingPower
}

func parseStep(_ step: String) -> (label: String, operation: Operation) {
    let equalSplit = step.split(separator: "=")
    if equalSplit.count > 1 {
        return (String(equalSplit[0]), .equal(Int(equalSplit[1])!))
    }
    if step.last == "-" {
        return (String(step.dropLast(1)), .minus)
    }
    fatalError("Invalid step: \(step)")
}

extension [[LabelledLens]] {
    var focusingPower: Int {
        enumerated().map { ($0.offset + 1) * $0.element.focusingPower }.reduce(0, +)
    }
}

extension [LabelledLens] {
    var focusingPower: Int {
        enumerated().map { ($0.offset + 1) * $0.element.focalLength }.reduce(0, +)
    }
}

// MARK: - Visualisation

extension [[LabelledLens]] {
    func debugPrint() {
        for index in indices where !self[index].isEmpty {
            print("Box \(index): ", self[index].map(\.description).joined(separator: " "))
        }
    }
}

extension LabelledLens: CustomStringConvertible {
    var description: String {
        return "[\(label) \(focalLength)]"
    }
}

main()
