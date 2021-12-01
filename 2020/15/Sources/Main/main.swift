import Foundation

func main() {
    let input = readLine()!.split(separator: ",").map { Int($0)! }
    part1(input: input)
    part2(input: input)
}

func part1(input: [Int]) {
    print(getLastSpokenNumber(input: input, atTurn: 2020))
}

func part2(input: [Int]) {
    print(getLastSpokenNumber(input: input, atTurn: 30000000))
}

func getLastSpokenNumber(input: [Int], atTurn lastTurn: Int) -> Int {
    var lastAppearanceTurn: [Int: Int] = [:]
    var previousLastAppearanceTurn: Int?
    var turn = 0
    input.forEach { number in
        previousLastAppearanceTurn = lastAppearanceTurn[number]
        lastAppearanceTurn[number] = turn
        turn += 1
    }

    var lastSpokenNumber = input.last!

    while turn < lastTurn {
        let spokenNumber: Int
        if let previousTurn = previousLastAppearanceTurn {
            spokenNumber = (turn - 1) - previousTurn
        } else {
            spokenNumber = 0
        }

        previousLastAppearanceTurn = lastAppearanceTurn[spokenNumber]
        lastAppearanceTurn[spokenNumber] = turn
        lastSpokenNumber = spokenNumber
        turn += 1
    }

    return lastSpokenNumber
}

main()
