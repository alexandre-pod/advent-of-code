import Foundation

struct InputType {
    let list1: [Int]
    let list2: [Int]
}

func main() {
    var list1: [Int] = []
    var list2: [Int] = []

    while let line = readLine() {
        let numbers = line.split(separator: " ").compactMap {  Int($0) }
        list1.append(numbers[0])
        list2.append(numbers[1])
    }

    let input = InputType(list1: list1, list2: list2)

    print(part1(inputParameter: input))
    print(part2(inputParameter: input))
}

// MARK: - Part 1

func part1(inputParameter: InputType) -> Int {
    let l1 = inputParameter.list1.sorted()
    let l2 = inputParameter.list2.sorted()

    return zip(l1, l2).reduce(0) { partialResult, pair in
        partialResult + abs(pair.0 - pair.1)
    }
}

// MARK: - Part 2

func part2(inputParameter: InputType) -> Int {
    var list2Count: [Int: Int] = [:]
    for number in inputParameter.list2 {
        list2Count[number, default: 0] += 1
    }
    return inputParameter.list1
        .map { $0 * list2Count[$0, default: 0] }
        .reduce(0, +)
}

main()
