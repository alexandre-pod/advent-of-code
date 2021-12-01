import Foundation

func part1() {
    var validCountPart1 = 0
    var validCountPart2 = 0
    while let line = readLine() {
        let splitted = line.split(separator: " ")
        let rangeNumber = splitted[0].split(separator: "-")
        let letter = splitted[1].first!
        let password = String(splitted[2])

        if isPasswordValidPartOne(
            range: ClosedRange<Int>(
                uncheckedBounds: (lower: Int(rangeNumber[0])!, upper: Int(rangeNumber[1])!)
            ),
            letter: letter,
            password: password
        ) {
            validCountPart1 += 1
        }
        if isPasswordValidPartTwo(
            range: ClosedRange<Int>(
                uncheckedBounds: (lower: Int(rangeNumber[0])!, upper: Int(rangeNumber[1])!)
            ),
            letter: letter,
            password: password
        ) {
            validCountPart2 += 1
        }
        
    }
    print("validCountPart1: \(validCountPart1)")
    print("validCountPart2: \(validCountPart2)")
}


func isPasswordValidPartOne(range: ClosedRange<Int>, letter: Character, password: String) -> Bool {
    return range.contains(password.filter { $0 == letter }.count)
}

func isPasswordValidPartTwo(range: ClosedRange<Int>, letter: Character, password: String) -> Bool {
    let firstOK = password.hasCharacter(letter, at: range.lowerBound - 1) // NO 0-indexed
    let secondOK = password.hasCharacter(letter, at: range.upperBound - 1) // NO 0-indexed
    let xoredOK = (firstOK && !secondOK) || (!firstOK && secondOK)
    return xoredOK// && range.contains(password.filter { $0 == letter }.count)
}

extension StringProtocol {
    func hasCharacter(_ character: Character, at index: Int) -> Bool {
        guard self.count > index else { return false }
        return self[index] == character
    }
}

extension StringProtocol {
    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
    subscript(range: Range<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: ClosedRange<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: PartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
    subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[...index(startIndex, offsetBy: range.upperBound)] }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[..<index(startIndex, offsetBy: range.upperBound)] }
}

part1()
