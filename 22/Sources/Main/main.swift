import Foundation


struct Card: Hashable {
    let value: Int
}

struct Deck {
    var cards: [Card]

    var isEmpty: Bool { cards.isEmpty }

    mutating func getTopCard() -> Card {
        cards.removeFirst()
    }

    mutating func addToBottom(_ card: Card) {
        cards.append(card)
    }

    var score: Int {
        return cards.reversed().enumerated().reduce(0) { $0 + $1.element.value * ($1.offset + 1) }
    }

    func madeFromTop(nbCards: Int) -> Deck {
        return Deck(cards: Array(cards.prefix(nbCards)))
    }
}

func main() {
    let player1Deck = parsePlayerDeck()
    let player2Deck = parsePlayerDeck()

    part1(player1Deck: player1Deck, player2Deck: player2Deck)
    part2(player1Deck: player1Deck, player2Deck: player2Deck)
}

func parsePlayerDeck() -> Deck {
    _ = readLine() // Player X
    var cards: [Card] = []
    while let line = readLine(), !line.isEmpty {
        cards.append(Card(value: Int(line)!))
    }
    return Deck(cards: cards)
}

// MARK: - Part 1

func part1(player1Deck: Deck, player2Deck: Deck) {
    let winnerDeck = SpaceCardGame.winningDeckFromGame(player1Deck: player1Deck, player2Deck: player2Deck)
    let answer = winnerDeck.score
    print("answer: \(answer)")
}

enum SpaceCardGame {
    static func score(of deck: Deck) -> Int {
        return deck.cards.reversed().enumerated().reduce(0) { $0 + $1.element.value * ($1.offset + 1) }
    }

    static func winningDeckFromGame(player1Deck: Deck, player2Deck: Deck) -> Deck {
        var deck1 = player1Deck
        var deck2 = player2Deck

        while !deck1.isEmpty && !deck2.isEmpty {
            (deck1, deck2) = Self.playRound(player1Deck: deck1, player2Deck: deck2)
        }
        return deck1.isEmpty ? deck2 : deck1
    }

    static func playRound(player1Deck: Deck, player2Deck: Deck) -> (player1Deck: Deck, player2Deck: Deck) {
        var deck1 = player1Deck
        var deck2 = player2Deck
        let card1 = deck1.getTopCard()
        let card2 = deck2.getTopCard()

        if card1.value > card2.value {
            deck1.addToBottom(card1)
            deck1.addToBottom(card2)
        } else {
            deck2.addToBottom(card2)
            deck2.addToBottom(card1)
        }
        return (deck1, deck2)
    }
}

// MARK: - Part 2

func part2(player1Deck: Deck, player2Deck: Deck) {
    var game = RecursiveCombat(player1Deck: player1Deck, player2Deck: player2Deck)
    let winnerDeck = game.getWinnerDeck()
    let answer = winnerDeck.score
    print("answer: \(answer)")
}

//var recursionDepth = 0

struct RecursiveCombat {

    private enum State {
        case playing(player1Deck: Deck, player2Deck: Deck)
        case player1Win(player1Deck: Deck, player2Deck: Deck)
        case player2Win(player1Deck: Deck, player2Deck: Deck)

        var gameEnded: Bool {
            switch self {
            case .playing:
                return false
            case .player1Win, .player2Win:
                return true
            }
        }

        var player1Won: Bool {
            switch self {
            case .playing:
                fatalError()
            case .player1Win:
                return true
            case .player2Win:
                return false
            }
        }
    }

    private var state: State
    private var knownPlayer1Deck: Set<[Card]> = []
    private var knownPlayer2Deck: Set<[Card]> = []


    init(player1Deck: Deck, player2Deck: Deck) {
        state = .playing(player1Deck: player1Deck, player2Deck: player2Deck)
    }

    mutating func getWinnerDeck() -> Deck {
        playUntilGameEnd()
        switch state {
        case .playing:
            fatalError()
        case let .player1Win(player1Deck, _):
            return player1Deck
        case let .player2Win(_, player2Deck):
            return player2Deck
        }
    }

    private mutating func isPlayer1Winner() -> Bool {
        playUntilGameEnd()
        return state.player1Won
    }

    private mutating func playUntilGameEnd() {
        while !state.gameEnded {
            playRound()
        }
    }

    private mutating func playRound() {
        state = playRound(from: state)
    }

    private mutating func playRound(from state: State) -> State {
        guard case var .playing(player1Deck: deck1, player2Deck: deck2) = state else { return state }

        if knownPlayer1Deck.contains(deck1.cards) || knownPlayer2Deck.contains(deck2.cards) {
            return .player1Win(player1Deck: deck1, player2Deck: deck2)
        }
        knownPlayer1Deck.insert(deck1.cards)
        knownPlayer2Deck.insert(deck2.cards)

        let card1 = deck1.getTopCard()
        let card2 = deck2.getTopCard()

        let player1WinRound: Bool
        if deck1.cards.count >= card1.value && deck2.cards.count >= card2.value {
            var newGame = RecursiveCombat(
                player1Deck: deck1.madeFromTop(nbCards: card1.value),
                player2Deck: deck2.madeFromTop(nbCards: card2.value)
            )
            player1WinRound = newGame.isPlayer1Winner()
        } else {
            player1WinRound = card1.value > card2.value
        }

        if player1WinRound {
            deck1.addToBottom(card1)
            deck1.addToBottom(card2)
        } else {
            deck2.addToBottom(card2)
            deck2.addToBottom(card1)
        }

        if deck1.isEmpty {
            return .player2Win(player1Deck: deck1, player2Deck: deck2)
        } else if deck2.isEmpty {
            return .player1Win(player1Deck: deck1, player2Deck: deck2)
        } else {
            return .playing(player1Deck: deck1, player2Deck: deck2)
        }
    }
}

main()
