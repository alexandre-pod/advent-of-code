import Foundation

// MARK: - Main

func main() {

    let player1Start = Int((readLine()?.split(separator: ":")[1].trimmingCharacters(in: .whitespaces))!)!
    let player2Start = Int((readLine()?.split(separator: ":")[1].trimmingCharacters(in: .whitespaces))!)!

    print(part1(player1Start: player1Start, player2Start: player2Start))
    print(part2(player1Start: player1Start, player2Start: player2Start))
}

// MARK: - Part 1

func part1(player1Start: Int, player2Start: Int) -> Int {

    var game = Game(
        playerOnePosition: player1Start,
        playerTwoPosition: player2Start,
        dice: DeterministicDice(),
        winningScore: 1000
    )

    while !game.isFinished {
        game.playTurn()
    }

    return min(game.playerOneScore, game.playerTwoScore) * game.dice.rollCounts
}

struct DeterministicDice {
    private(set) var rollCounts = 0
    private var nextValue = 0

    mutating func roll() -> Int {
        defer { nextValue = (nextValue + 1) % 100 }
        rollCounts += 1
        return nextValue + 1
    }

    mutating func threeRollSum() -> Int {
        return roll() + roll() + roll()
    }
}

struct Game {
    var playerOneTurn = true
    var playerOneScore = 0
    var playerTwoScore = 0
    var playerOnePosition: Int
    var playerTwoPosition: Int
    var dice: DeterministicDice
    let winningScore: Int

    init(playerOnePosition: Int,
         playerTwoPosition: Int,
         dice: DeterministicDice,
         winningScore: Int) {
        self.playerOnePosition = playerOnePosition
        self.playerTwoPosition = playerTwoPosition
        self.dice = dice
        self.winningScore = winningScore
    }

    mutating func playTurn() {
        let position: WritableKeyPath<Self, Int>
        let score: WritableKeyPath<Self, Int>
        if playerOneTurn {
            position = \.playerOnePosition
            score = \.playerOneScore
        } else {
            position = \.playerTwoPosition
            score = \.playerTwoScore
        }

        let movement = dice.threeRollSum()

        let nextPosition = ((self[keyPath: position] + movement - 1) % 10) + 1
        self[keyPath: position] = nextPosition
        self[keyPath: score] += nextPosition

        playerOneTurn = !playerOneTurn
    }

    var isFinished: Bool {
        playerOneWon || playerTwoWon
    }

    var playerOneWon: Bool {
        playerOneScore >= winningScore
    }

    var playerTwoWon: Bool {
        playerTwoScore >= winningScore
    }
}

// MARK: - Part 2

func part2(player1Start: Int, player2Start: Int) -> Int {


    let winCount = winCountInGame(state: GameState(
        playerOneTurn: true,
        playerOnePosition: player1Start,
        playerTwoPosition: player2Start,
        playerOneScore: 0,
        playerTwoScore: 0,
        winningScore: 21
    ))


    return max(winCount.0, winCount.1)
}

struct GameState: Hashable {
    let playerOneTurn: Bool
    let playerOnePosition: Int
    let playerTwoPosition: Int
    let playerOneScore: Int
    let playerTwoScore: Int
    let winningScore: Int
}

var cache: [GameState: (Int, Int)] = [:]

func winCountInGame(state: GameState) -> (Int, Int) {
    if let result = cache[state] {
        return result
    }

    if state.playerOneScore >= state.winningScore {
        return (1, 0)
    }
    if state.playerTwoScore >= state.winningScore {
        return (0, 1)
    }

    let winCount: [(Int, Int)]

    if state.playerOneTurn {
        winCount = diracDiceValues
            .map { diceValue -> (Int, Int) in
                let nextPosition = ((state.playerOnePosition - 1 + diceValue) % 10) + 1
                return winCountInGame(state: GameState(
                    playerOneTurn: false,
                    playerOnePosition: nextPosition,
                    playerTwoPosition: state.playerTwoPosition,
                    playerOneScore: state.playerOneScore + nextPosition,
                    playerTwoScore: state.playerTwoScore,
                    winningScore: state.winningScore
                ))
            }
    } else {
        winCount = diracDiceValues
            .map { diceValue -> (Int, Int) in
                let nextPosition = ((state.playerTwoPosition - 1 + diceValue) % 10) + 1
                return winCountInGame(state: GameState(
                    playerOneTurn: true,
                    playerOnePosition: state.playerOnePosition,
                    playerTwoPosition: nextPosition,
                    playerOneScore: state.playerOneScore,
                    playerTwoScore: state.playerTwoScore + nextPosition,
                    winningScore: state.winningScore
                ))
            }
    }

    let result = winCount.reduce((0, 0)) { partialResult, value in
        (partialResult.0 + value.0, partialResult.1 + value.1)
    }
    cache[state] = result
    return result
}

let diracDiceValues: [Int] = {
    return (1...3) .flatMap { d1 in
        (1...3).flatMap { d2 in
            return (1...3).map { d3 in d2 + d3 }
        }.map { $0 + d1 }

    }
}()

main()
