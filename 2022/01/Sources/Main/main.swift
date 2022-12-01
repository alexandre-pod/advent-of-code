import Foundation

func main() {
    var elves: [[Int]] = []

    var currentElve: [Int] = []
    while let line = readLine() {
        if line.isEmpty {
            elves.append(currentElve)
            currentElve = []
        } else {
            currentElve.append(Int(line)!)
        }
    }
    elves.append(currentElve)

        print(part1(elves: elves))
    print(part2(elves: elves))
}

func part1(elves: [[Int]]) -> Int {
    return elves.map { $0.reduce(0, +) }.max()!
}

func part2(elves: [[Int]]) -> Int {
    let totalCalories = elves.map { $0.reduce(0, +) }.sorted(by: >)
    let threeBiggest = totalCalories.prefix(3)
    return threeBiggest.reduce(0, +)
}

main()
