import Foundation

func main() {
    var numbers: [Int] = []

    while let line = readLine() {
        numbers.append(Int(line)!)
    }

    print(part1(numbers: numbers))
    print(part2(numbers: numbers))
}

func part1(numbers: [Int]) -> Int {
    return zip(numbers, numbers.dropFirst())
        .map { $1 - $0 }
        .reduce(0) { $0 + (($1 > 0) ? 1 : 0) }
}

func part2(numbers: [Int]) -> Int {
    let threeSlidingWindow = zip(numbers, zip(numbers.dropFirst(), numbers.dropFirst(2)))
        .map { $0 + $1.0 + $1.1 }
    return part1(numbers: threeSlidingWindow)
}

main()
