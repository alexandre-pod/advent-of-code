import Foundation

struct Mask {
    var value: String

    init(value: String) {
        precondition(value.count == 36)
        self.value = value
    }

    mutating func apply(mask: Mask) {
        value = zip(value, mask.value)
            .map { oldValue, newValue in
                return String(newValue == "X" ? oldValue : newValue)
            }
            .joined()
    }
}

enum Instruction {
    case maskUpdate(Mask)
    case writeMemory(addr: Int, value: Int)
}

func main() {
    var instructions: [Instruction] = []
    while let line = readLine() {
        switch line[0..<3] {
        case "mem":
            let addrBegin = line.index(line.firstIndex(of: "[")!, offsetBy: 1)
            let addrEnd = line.index(line.firstIndex(of: "]")!, offsetBy: -1)
            let valueBegin = line.index(line.firstIndex(of: "]")!, offsetBy: 4)
            instructions.append(
                .writeMemory(
                    addr: Int(line[addrBegin...addrEnd])!,
                    value: Int(line[valueBegin...])!
                )
            )
            break
        case "mas":
            instructions.append(.maskUpdate(Mask(value: String(line[7...]))))
        default:
            fatalError()
        }
    }
    part1(instructions: instructions)
    part2(instructions: instructions)
}

extension String {
    subscript(_ range: Range<Int>) -> String.SubSequence {
        let lowerIndex = index(startIndex, offsetBy: range.lowerBound)
        let upperIndex = index(startIndex, offsetBy: range.upperBound)
        return self[lowerIndex..<upperIndex]
    }

    subscript(_ partialRange: PartialRangeFrom<Int>) -> String.SubSequence {
        let lowerIndex = index(startIndex, offsetBy: partialRange.lowerBound)
        return self[lowerIndex...]
    }
}

// MARK: - Part 1

func part1(instructions: [Instruction]) {
    var mask = Mask(value: Array(repeating: "X", count: 36).joined())
    var memory: [Int: Int] = [:]
    for instruction in instructions {
        switch instruction {
        case let .maskUpdate(newMask):
            mask.apply(mask: newMask)
        case let .writeMemory(addr: addr, value: value):
            memory[addr] = value.masked(mask)
        }
    }

    let answer = memory.values.reduce(0, (+))
    print(answer)
}

extension Int {
    func masked(_ mask: Mask) -> Int {
        var newValue = self
        mask.value.reversed().enumerated().forEach { index, value in
            switch value {
            case "0":
                newValue &= ~(1 << index)
            case "1":
                newValue |= 1 << index
            default:
                break
            }
        }
        return newValue
    }
}

// MARK: - Part 2

func part2(instructions: [Instruction]) {
    var mask = Mask(value: Array(repeating: "0", count: 36).joined())
    var memory: [Int: Int] = [:]
    for instruction in instructions {
        switch instruction {
        case let .maskUpdate(newMask):
            mask = newMask
        case let .writeMemory(addr: addr, value: value):
            addr.allAddressesFromMask(mask).forEach {
                memory[$0] = value
            }
        }
    }
    let answer = memory.values.reduce(0, (+))
    print(answer)
}

extension Mask {
    func getAllPossibleMasks() -> [Int] {
        func allCombination(fromReversed reversedMaskValue: String) -> [Int] {
            if reversedMaskValue.isEmpty { return [0] }
            let allDoubledCombination = allCombination(fromReversed: String(reversedMaskValue[1...])).map { $0 * 2 }
            switch reversedMaskValue.first! {
            case "0":
                return allDoubledCombination
            case "1":
                return allDoubledCombination.map { $0 + 1 }
            case "X":
                return allDoubledCombination + allDoubledCombination.map { $0 + 1 }
            default:
                fatalError()
            }
        }
        return allCombination(fromReversed: String(value.reversed()))
    }
}

extension Int {

    func allAddressesFromMask(_ mask: Mask) -> [Int] {
        let resultMask = Mask(value: mask.value.reversed().enumerated().map { index, value in
            let bit = (self >> index) & 1
            switch value {
            case "0":
                return String(bit)
            case "1":
                return "1"
            case "X":
                return "X"
            default:
                fatalError()
            }
        }.reversed().joined())
        return resultMask.getAllPossibleMasks()
    }
}

main()
