import Foundation

typealias Hands = [Hand]

struct Hand {
    let cards: [Card]
    let bid: Int
}

enum Card: Character, Hashable {
    case ace = "A"
    case king = "K"
    case queen = "Q"
    case joker = "J"
    case ten = "T"
    case nine = "9"
    case eight = "8"
    case seven = "7"
    case six = "6"
    case five = "5"
    case four = "4"
    case three = "3"
    case two = "2"
}

enum HandType {
    case five(Card)
    case four(Card)
    case fullHouse(three: Card, two: Card)
    case three(Card)
    case twoPairs(Card, Card)
    case pair(Card)
    case high
}

func main() {
    var input: Hands = []

    while let line = readLine() {
        input.append(parseHand(from: line))
    }

    print(part1(hands: input))
    print(part2(hands: input))
}

func parseHand(from line: String) -> Hand {
    let parts = line.split(separator: " ")
    return Hand(
        cards: parts[0].map { Card(rawValue: $0)! },
        bid: Int(String(parts[1]))!
    )
}

// MARK: - Part 1

func part1(hands: Hands) -> Int {
    return hands
        .map { Part1Hand(hand: $0) }
        .sorted { $1.part1IsBetterThan($0) }
        .enumerated()
        .map { ($0.offset + 1) * $0.element.bid }
        .reduce(0, +)
}

struct Part1Hand {
    let cards: [Card]
    let bid: Int
    let type: HandType?

    init(hand: Hand) {
        self.cards = hand.cards
        self.bid = hand.bid
        self.type = cards.part1HandType
    }
}

extension [Card] {
    var part1HandType: HandType? {
        assert(count == 5)

        let cardsMap = reduce(into: [Card: Int]()) { map, card in
            map[card, default: 0] += 1
        }

        guard cardsMap.count > 1 else {
            return .five(cardsMap.keys.first!)
        }

        guard cardsMap.count > 2 else {
            let allCards = Array(cardsMap.keys)
            let card1 = allCards[0]
            let card2 = allCards[1]

            if cardsMap[card1] == 4 {
                return .four(card1)
            }
            if cardsMap[card2] == 4 {
                return .four(card2)
            }

            if cardsMap[card1] == 3 {
                return .fullHouse(three: card1, two: card2)
            } else {
                return .fullHouse(three: card2, two: card1)
            }
        }

        if let three = cardsMap.first(where: { $0.value == 3 })?.key {
            return .three(three)
        }

        let pairs = cardsMap.filter { $0.value == 2 }.map(\.key)
        if pairs.count == 2 {
            return .twoPairs(pairs[0], pairs[1])
        } else if pairs.count == 1 {
            return .pair(pairs[0])
        }

        if cardsMap.keys.count == 5 {
            return .high
        }

        return .none
    }
}

extension Part1Hand {

    func part1IsBetterThan(_ other: Self) -> Bool {
        if type.strength > other.type.strength {
            return true
        } else if type.strength < other.type.strength {
            return false
        }
        for (selfCard, otherCard) in zip(cards, other.cards) where selfCard != otherCard {
            return selfCard.part1Strength > otherCard.part1Strength
        }
        return false
    }
}

extension HandType? {
    var strength: Int {
        return switch self {
        case .five: 6
        case .four: 5
        case .fullHouse: 4
        case .three: 3
        case .twoPairs: 2
        case .pair: 1
        case .high: 0
        case .none: -1
        }
    }
}

extension Card {
    var part1Strength: Int {
        return switch self {
        case .ace: 12
        case .king: 11
        case .queen: 10
        case .joker: 9
        case .ten: 8
        case .nine: 7
        case .eight: 6
        case .seven: 5
        case .six: 4
        case .five: 3
        case .four: 2
        case .three: 1
        case .two: 0
        }
    }
}

// MARK: - Part 2

func part2(hands: Hands) -> Int {
    return hands
        .map { Part2Hand(hand: $0) }
        .sorted { $1.part2IsBetterThan($0) }
        .enumerated()
        .map { ($0.offset + 1) * $0.element.bid }
        .reduce(0, +)
}

struct Part2Hand {
    let cards: [Card]
    let bid: Int
    let type: HandType?

    init(hand: Hand) {
        self.cards = hand.cards
        self.bid = hand.bid
        self.type = cards.part2HandType
    }
}

extension [Card] {
    var part2HandType: HandType? {
        assert(count == 5)

        let cardsMap = reduce(into: [Card: Int]()) { map, card in
            map[card, default: 0] += 1
        }

        let jokerCount = cardsMap[.joker] ?? 0

        guard jokerCount != 0 else {
            return self.part1HandType
        }

        let nonJokerCardsMap = cardsMap.filter { $0.key != .joker }

        let singles = nonJokerCardsMap.filter { $0.value == 1 }.map(\.key)
        let pairs = nonJokerCardsMap.filter { $0.value == 2 }.map(\.key)
        let triples = nonJokerCardsMap.filter { $0.value == 3 }.map(\.key)
        let quadruples = nonJokerCardsMap.filter { $0.value == 4 }.map(\.key)

        switch jokerCount {
        case 5:
            return .five(.joker)
        case 4:
            return .five(singles[0])
        case 3:
            if let pair = pairs.first {
                return .five(pair)
            }
            return .four(singles[0])
        case 2:
            if let triple = triples.first {
                return .five(triple)
            }
            if let pair = pairs.first {
                return .four(pair)
            }
            return .three(singles[0])
        case 1:
            if let quadruple = quadruples.first {
                return .five(quadruple)
            }
            if let triple = triples.first {
                return .four(triple)
            }
            if pairs.count == 2 {
                return .fullHouse(three: pairs[0], two: pairs[1])
            } else if let pair = pairs.first {
                return .three(pair)
            }
            return .pair(singles[0])
        default:
            fatalError("Impossible case")
        }
    }
}

extension Part2Hand {

    func part2IsBetterThan(_ other: Self) -> Bool {
        guard type.strength == other.type.strength else {
            return type.strength > other.type.strength
        }
        for (selfCard, otherCard) in zip(cards, other.cards) where selfCard != otherCard {
            return selfCard.part2Strength > otherCard.part2Strength
        }
        return false
    }
}

extension Card {
    var part2Strength: Int {
        return switch self {
        case .ace: 12
        case .king: 11
        case .queen: 10
        case .ten: 8
        case .nine: 7
        case .eight: 6
        case .seven: 5
        case .six: 4
        case .five: 3
        case .four: 2
        case .three: 1
        case .two: 0
        case .joker: -1
        }
    }
}

// MARK: - Debug

extension Part2Hand: CustomStringConvertible {
    var description: String {
        return "\(cards.customDescription) - \(bid) - \(String(describing: type))"
    }
}

extension [Card] {
    var customDescription: String {
        String(map(\.rawValue))
    }
}

main()
