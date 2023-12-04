import Foundation

typealias Cards = [Card]

struct Card {
    let number: Int
    let winningNumbers: [Int]
    let numbers: [Int]
}

func main() {
    var cards: Cards = []

    while let line = readLine() {
        cards.append(parseCard(line: line))
    }

    print(part1(cards: cards))
    print(part2(cards: cards))
}

func parseCard(line: String) -> Card {

    let parts = line.split(separator: ":")
    let number = Int(parts[0].split(separator: " ")[1])!
    let numbersParts = parts[1].split(separator: "|")
    let winningNumbers = numbersParts[0]
        .trimmingCharacters(in: .whitespaces)
        .split(separator: " ")
        .filter { !$0.isEmpty }
        .map { Int($0)! }
    let numbers = numbersParts[1]
        .trimmingCharacters(in: .whitespaces)
        .split(separator: " ")
        .filter { !$0.isEmpty }
        .map { Int($0)! }

    return Card(number: number, winningNumbers: winningNumbers, numbers: numbers)
}

// MARK: - Part 1

func part1(cards: Cards) -> Int {
    return cards.map(\.points).reduce(0, +)
}

extension Card {
    var points: Int {
        let matching = Set(winningNumbers).intersection(Set(numbers)).count
        guard matching > 0 else { return 0 }
        return 1 << (matching - 1)
    }
}

// MARK: - Part 2

func part2(cards: Cards) -> Int {
    let cardMatchingNumbers: [Int] = cards.map(\.matchingNumbers)
    var cardAmount = Array(repeating: 1, count: cards.count)

    for cardNumber in cardMatchingNumbers.indices {
        let points = cardMatchingNumbers[cardNumber]
        let amount = cardAmount[cardNumber]
        guard points > 0 else { continue }
        for offset in 1...points {
            cardAmount[cardNumber + offset] += amount
        }
    }

    return cardAmount.reduce(0, +)
}

extension Card {
    var matchingNumbers: Int {
        Set(winningNumbers).intersection(Set(numbers)).count
    }
}

main()
