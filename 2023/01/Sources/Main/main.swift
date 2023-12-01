import Foundation

typealias InputType = [String]

func main() {
    var input: InputType = []

    while let line = readLine() {
        input.append(line)
    }

    print(part1(lines: input))
    print(part2(lines: input))
}

// MARK: - Part 1

func part1(lines: InputType) -> Int {
    return lines.map { firstAndLastDigit(in: $0) }.reduce(0, +)
}

func firstAndLastDigit(in line: String) -> Int {
    let numbers = line.filter { $0.isNumber }.compactMap { Int(String($0)) }
    assert(!numbers.isEmpty)
    return numbers.first! * 10 + numbers.last!
}

// MARK: - Part 2

func part2(lines: InputType) -> Int {
    return lines.map { firstAndLastDigitWithText(in: $0) }.reduce(0, +)
}

func firstAndLastDigitWithText(in line: String) -> Int {
    let first = firstDigit(in: line)
    let last = lastDigit(in: line)
    return first * 10 + last
}

func firstDigit(in line: String) -> Int {
    let firstNumberCharacter = line.firstIndex(where: \.isNumber)

    let firstSpelledNumber = SpelledNumber.allCases
        .compactMap { spellNumber -> (String.Index, SpelledNumber)? in
            guard let range = line.firstRange(of: spellNumber.rawValue) else { return nil }
            return (range.lowerBound, spellNumber)
        }
        .min { $0.0 < $1.0 }

    guard let firstNumberCharacter else {
        return firstSpelledNumber!.1.digitValue
    }

    guard let firstSpelledNumber else {
        return Int(String(line[firstNumberCharacter]))!
    }

    if firstNumberCharacter < firstSpelledNumber.0 {
        return Int(String(line[firstNumberCharacter]))!
    } else {
        return firstSpelledNumber.1.digitValue
    }
}

func lastDigit(in line: String) -> Int {
    let firstNumberCharacter = line.lastIndex(where: \.isNumber)

    let reversedLine = line.reversed()
    let lastSpelledNumber = SpelledNumber.allCases
        .compactMap { spellNumber -> (String.Index, SpelledNumber)? in
            guard let range = reversedLine.firstRange(of: spellNumber.rawValue.reversed()) else { return nil }
            let distance = reversedLine.distance(from: reversedLine.startIndex, to: range.upperBound)
            return (line.index(line.endIndex, offsetBy: -distance), spellNumber)
        }
        .max { $0.0 < $1.0 }

    guard let firstNumberCharacter else {
        return lastSpelledNumber!.1.digitValue
    }

    guard let lastSpelledNumber else {
        return Int(String(line[firstNumberCharacter]))!
    }

    if firstNumberCharacter > lastSpelledNumber.0 {
        return Int(String(line[firstNumberCharacter]))!
    } else {
        return lastSpelledNumber.1.digitValue
    }
}

struct SpelledNumber: CaseIterable {
    let rawValue: String
    let digitValue: Int

    private init(rawValue: String, digitValue: Int) {
        self.rawValue = rawValue
        self.digitValue = digitValue
    }

    static let one = SpelledNumber(rawValue: "one", digitValue: 1)
    static let two = SpelledNumber(rawValue: "two", digitValue: 2)
    static let three = SpelledNumber(rawValue: "three", digitValue: 3)
    static let four = SpelledNumber(rawValue: "four", digitValue: 4)
    static let five = SpelledNumber(rawValue: "five", digitValue: 5)
    static let six = SpelledNumber(rawValue: "six", digitValue: 6)
    static let seven = SpelledNumber(rawValue: "seven", digitValue: 7)
    static let eight = SpelledNumber(rawValue: "eight", digitValue: 8)
    static let nine = SpelledNumber(rawValue: "nine", digitValue: 9)

    static var allCases: [SpelledNumber] = [one, two, three, four, five, six, seven, eight, nine]
}

main()
