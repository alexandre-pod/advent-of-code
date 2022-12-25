import Foundation

typealias InputType = [String]

func main() {
    var input: InputType = []

    while let line = readLine() {
        input.append(line)
    }

    print(part1(inputParameter: input))
}

// MARK: - Part 1

func part1(inputParameter: InputType) -> String {
    let value = inputParameter
        .map { snafuToDecimal($0) }
        .reduce(0, +)

    return decimalToSNAFU(value)
}

let snafuToDecimalMapping: [Character: Int] = [
    "0": 0,
    "1": 1,
    "2": 2,
    "-": -1,
    "=": -2
]

let decimalToSNAFUMapping: [Int: Character] = [
    0: "0",
    1: "1",
    2: "2",
    -1: "-",
    -2: "="
]

func snafuToDecimal(_ snafu: String) -> Int {
    guard !snafu.isEmpty else { return 0 }

    var snafuRemaining = snafu

    let lastValue = snafuToDecimalMapping[snafuRemaining.popLast()!]!

    return lastValue + 5 * snafuToDecimal(snafuRemaining)
}

func decimalToSNAFU(_ value: Int) -> String {

    let base5 = decimalToBase5(value)

    var snafuComponents = Array(base5.reversed())

    for index in 0..<(snafuComponents.count - 1) {
        var component = snafuComponents[index]
        while component >= 3 {
            component -= 5
            snafuComponents[index + 1] += 1
        }
        snafuComponents[index] = component
    }

    var lastComponent = snafuComponents[snafuComponents.endIndex - 1]
    var additionalComponent = 0
    while lastComponent >= 3 {
        lastComponent -= 5
        additionalComponent += 1
    }
    snafuComponents[snafuComponents.endIndex - 1] = lastComponent
    if additionalComponent != 0 {
        snafuComponents.append(additionalComponent)
    }

    print(snafuComponents.reversed())

    return snafuComponents
        .reversed()
        .reduce("") { $0.appending(String(decimalToSNAFUMapping[$1]!))}
}

func decimalToBase5(_ value: Int) -> [Int] {
    var result: [Int] = []
    var remainingValue = value
    while remainingValue > 0 {
        result.append(remainingValue % 5)
        remainingValue = remainingValue / 5
    }
    return result.reversed()
}

main()
