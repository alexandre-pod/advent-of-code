import Foundation

typealias Map = [[Character]]

struct Position {
    let line: Int
    let column: Int
}

extension Map {
    subscript(_ position: Position) -> Element.Element {
        self[position.line][position.column]
    }
}

func main() {
    var input: Map = []

    while let line = readLine() {
        input.append(line.map { $0 })
    }

    print(part1(map: input))
    print(part2(map: input))
}

// MARK: - Part 1

func part1(map: Map) -> Int {

    var validNumbers: [Int] = []

    for y in 0..<map.count {
        let numbers = findAllNumbers(in: map[y])
        
        numbers
            .filter { (number, xRange) in
                allAdjacentPositionAround(line: y, xRange: xRange, in: map)
                    .contains { isSymbol(map[$0]) }
            }.forEach { (number, xRange) in
                validNumbers.append(number)
            }
    }

    return validNumbers.reduce(0, +)
}

func findAllNumbers(in line: [Character]) -> [(Int, ClosedRange<Int>)] {
    var allNumbers: [(Int, ClosedRange<Int>)] = []

    var currentNumber = 0
    var currentNumberStart = 0

    var currentIndex = 0
    var previousIndexWasNumber = false

    while currentIndex < line.count {
        let currentCharacter = line[currentIndex]

        if currentCharacter.isNumber {
            if !previousIndexWasNumber {
                currentNumberStart = currentIndex
            }
            let digit = Int(String(currentCharacter))!
            currentNumber = 10 * currentNumber + digit
        } else {
            if previousIndexWasNumber {
                allNumbers.append((currentNumber, currentNumberStart...(currentIndex - 1)))
                currentNumber = 0
                previousIndexWasNumber = false
            }
        }
        previousIndexWasNumber = currentCharacter.isNumber
        currentIndex += 1
    }

    if previousIndexWasNumber {
        allNumbers.append((currentNumber, currentNumberStart...(currentIndex - 1)))
    }

    return allNumbers
}

func allAdjacentPositionAround(line: Int, xRange: ClosedRange<Int>, in map: Map) -> [Position] {
    var positions: [Position] = []

    let minX = max(0, xRange.lowerBound - 1)
    let maxX = min(map[0].count - 1, xRange.upperBound + 1)
    let minY = max(0, line - 1)
    let maxY = min(map.count - 1, line + 1)

    for y in minY...maxY {
        for x in minX...maxX {
            if y == line, xRange.contains(x) { continue }
            positions.append(Position(line: y, column: x))
        }
    }

    return positions
}

func allAdjacentPositionAround(line: Int, column: Int, in map: Map) -> [Position] {
    return allAdjacentPositionAround(line: line, xRange: column...column, in: map)
}

func isSymbol(_ character: Character) -> Bool {
    return character != "." && !character.isNumber
}


// MARK: - Part 2

struct FoundNumber: Hashable {
    let value: Int
    let line: Int
    let columnRange: ClosedRange<Int>
}

func part2(map: Map) -> Int {

    var numbersPerLine: [Int: [FoundNumber]] = [:]
    var gears: [Position] = []
    for y in 0..<map.count {
        numbersPerLine[y] = findAllNumbers(in: map[y])
            .map { FoundNumber(value: $0.0, line: y, columnRange: $0.1) }
        let gearsPosition = map[y].enumerated()
            .filter { $0.element == "*" }
            .map { Position(line: y, column: $0.offset) }
        gears.append(contentsOf: gearsPosition)
    }

    var allGearRatios: [Int] = []

    for gear in gears {
        let adjacentPositions = allAdjacentPositionAround(line: gear.line, column: gear.column, in: map)
        var adjacentNumbers: Set<FoundNumber> = []
        for position in adjacentPositions {
            numbersPerLine[position.line]?
                .filter { number in
                    number.columnRange.contains(position.column)
                }
                .forEach {
                    adjacentNumbers.insert($0)
                }
        }
        if adjacentNumbers.count == 2 {
            allGearRatios.append(adjacentNumbers.map(\.value).reduce(1, *))
        }
    }

    return allGearRatios.reduce(0, +)
}

main()
