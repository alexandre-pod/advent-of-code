import Foundation

struct SignalPattern: OptionSet, Hashable {
    let rawValue: Int

    static let a = SignalPattern(rawValue: 1<<0)
    static let b = SignalPattern(rawValue: 1<<1)
    static let c = SignalPattern(rawValue: 1<<2)
    static let d = SignalPattern(rawValue: 1<<3)
    static let e = SignalPattern(rawValue: 1<<4)
    static let f = SignalPattern(rawValue: 1<<5)
    static let g = SignalPattern(rawValue: 1<<6)

    static let all: SignalPattern = [.a, .b, .c, .d, .e, .f, .g]

    static let segments: [SignalPattern] = [.a, .b, .c, .d, .e, .f, .g]

    var count: Int {
        return SignalPattern.segments.reduce(0) { partialResult, segment in
            partialResult + (self.contains(segment) ? 1 : 0)
        }
    }
}

extension SignalPattern {
    init?<S: StringProtocol>(fromString string: S) {
        var individualPatterns: [SignalPattern] = []
        for character in string {
            guard let individualPattern = SignalPattern(from: character) else { return nil }
            individualPatterns.append(individualPattern)
        }
        self = individualPatterns.reduce(SignalPattern()) { [$0, $1] }
    }

    init?(from character: Character) {
        switch character {
        case "a":
            self = .a
        case "b":
            self = .b
        case "c":
            self = .c
        case "d":
            self = .d
        case "e":
            self = .e
        case "f":
            self = .f
        case "g":
            self = .g
        default:
            return nil
        }
    }
}

// MARK: - Main

struct InputLine {
    let signalPatterns: [SignalPattern]
    let digitOutput: [SignalPattern]
}

func main() {

    var lines: [InputLine] = []

    while let line = readLine() {
        let components = line.split(separator: "|").map { $0.trimmingCharacters(in: .whitespaces).split(separator: " ") }
        let signalPatterns = components[0].map { SignalPattern(fromString: $0)! }
        let digitOutput = components[1].map { SignalPattern(fromString: $0)! }
        lines.append(InputLine(signalPatterns: signalPatterns, digitOutput: digitOutput))
    }

    print(part1(lines: lines))
    print(part2(lines: lines))
}

// MARK: - Part 1

func part1(lines: [InputLine]) -> Int {
    var result = 0

    for line in lines {
        let (mapping, _) = findEasyMapping(from: line)
        result += line.digitOutput.compactMap { mapping[$0] }.count
    }

    return result
}

typealias PatternMapping = [SignalPattern: Int]
typealias ReversePatternMapping = [Int: SignalPattern]

func findEasyMapping(from inputLine: InputLine) -> (PatternMapping, ReversePatternMapping) {
    var easyMapping: PatternMapping = [:]
    var reverseEasyMapping: ReversePatternMapping = [:]
    inputLine.signalPatterns.forEach {
        switch $0.count {
        case 2:
            easyMapping[$0] = 1
            reverseEasyMapping[1] = $0
        case 3:
            easyMapping[$0] = 7
            reverseEasyMapping[7] = $0
        case 4:
            easyMapping[$0] = 4
            reverseEasyMapping[4] = $0
        case 7:
            easyMapping[$0] = 8
            reverseEasyMapping[8] = $0
        default:
            break
        }
    }
    return (easyMapping, reverseEasyMapping)
}

// MARK: - Part 2

func part2(lines: [InputLine]) -> Int {
    var result = 0

    for line in lines {
        let mapping = findCompleteMapping(from: line)
        result += line.digitOutput.map { mapping[$0]! }.reduce(0) { $0 * 10 + $1 }
    }

    return result
}

func findCompleteMapping(from inputLine: InputLine) -> PatternMapping {
    var (mapping, reverseMapping) = findEasyMapping(from: inputLine)

    // Mapping contains 1, 4, 7, 8

    let sixLongDigits = inputLine.signalPatterns.filter { $0.count == 6 }
    let fiveLongDigits = inputLine.signalPatterns.filter { $0.count == 5 }

    let oneDigits = reverseMapping[1]!
    let realABFG: SignalPattern = sixLongDigits.reduce(.all) { $0.intersection($1) }

    // detect 5

    let fivePattern = fiveLongDigits.first { $0.isSuperset(of: realABFG) }!
    mapping[fivePattern] = 5
    reverseMapping[5] = fivePattern

    // detect 2 / 3

    let threePattern = fiveLongDigits.first { $0.isSuperset(of: oneDigits) }!
    mapping[threePattern] = 3
    reverseMapping[3] = threePattern

    let twoPattern = fiveLongDigits.first { $0 != threePattern && $0 != fivePattern }!
    mapping[twoPattern] = 2
    reverseMapping[2] = twoPattern

    // detect 6

    let sixPattern = sixLongDigits.first { !$0.isSuperset(of: oneDigits) }!
    mapping[sixPattern] = 6
    reverseMapping[6] = sixPattern


    // detect 0 / 9

    let realADG: SignalPattern = [fivePattern, twoPattern].reduce(.all) { $0.intersection($1) }

    let zeroPattern = sixLongDigits.first { !$0.isSuperset(of: realADG) }!
    mapping[zeroPattern] = 0
    reverseMapping[0] = zeroPattern

    let ninePattern = sixLongDigits.first { $0 != zeroPattern && $0 != sixPattern }!
    mapping[ninePattern] = 9
    reverseMapping[9] = ninePattern

    return mapping
}

main()

// MARK: - Debug

extension SignalPattern: CustomStringConvertible {
    var description: String {
        var result = ""
        if self.contains(.a) {
            result.append("a")
        }
        if self.contains(.b) {
            result.append("b")
        }
        if self.contains(.c) {
            result.append("c")
        }
        if self.contains(.d) {
            result.append("d")
        }
        if self.contains(.e) {
            result.append("e")
        }
        if self.contains(.f) {
            result.append("f")
        }
        if self.contains(.g) {
            result.append("g")
        }
        if result.isEmpty {
            return "[]"
        }
        return result

    }
}

/*
0:      1:      2:      3:      4:
 aaaa    ....    aaaa    aaaa    ....
b    c  .    c  .    c  .    c  b    c
b    c  .    c  .    c  .    c  b    c
 ....    ....    dddd    dddd    dddd
e    f  .    f  e    .  .    f  .    f
e    f  .    f  e    .  .    f  .    f
 gggg    ....    gggg    gggg    ....

5:      6:      7:      8:      9:
 aaaa    aaaa    aaaa    aaaa    aaaa
b    .  b    .  .    c  b    c  b    c
b    .  b    .  .    c  b    c  b    c
 dddd    dddd    ....    dddd    dddd
.    f  e    f  .    f  e    f  .    f
.    f  e    f  .    f  e    f  .    f
 gggg    gggg    ....    gggg    gggg

======== 5 segments

2:      3:      5:
 aaaa    aaaa    aaaa
.    c  .    c  b    .
.    c  .    c  b    .
 dddd    dddd    dddd
e    .  .    f  .    f
e    .  .    f  .    f
 gggg    gggg    gggg

====== 6 segments

0:      6:      9:
 aaaa    aaaa    aaaa
b    c  b    .  b    c
b    c  b    .  b    c
 ....    dddd    dddd
e    f  e    f  .    f
e    f  e    f  .    f
 gggg    gggg    gggg

*/
