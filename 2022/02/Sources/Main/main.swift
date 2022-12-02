import Foundation

enum OpponentMove: String {
    case rock = "A"
    case paper = "B"
    case scissors = "C"
}

enum InstructionMove: String {
    case x = "X"
    case y = "Y"
    case z = "Z"
}

func main() {
    var lines: [(OpponentMove, InstructionMove)] = []

    while let line = readLine() {
        let components = line.split(separator: " ").map { String($0) }

        lines.append((
            OpponentMove(rawValue: components[0])!,
            InstructionMove(rawValue: components[1])!
        ))
    }

    print(part1(lines: lines))
    print(part2(lines: lines))
}

// MARK: - Part 1

func part1(lines: [(OpponentMove, InstructionMove)]) -> Int {
    return score(for: lines.map { ($0.0, SelfMove(from: $0.1)) })
}

enum SelfMove: String {
    case rock
    case paper
    case scissors

    init(from instruction: InstructionMove) {
        switch instruction {
        case .x:
            self = .rock
        case .y:
            self = .paper
        case .z:
            self = .scissors
        }
    }

    var scoreValue: Int {
        switch self {
        case .rock:
            return 1
        case .paper:
            return 2
        case .scissors:
            return 3
        }
    }
}

func score(for match: [(OpponentMove, SelfMove)]) -> Int {
    match.reduce(0) { partialResult, round in
        partialResult + roundScore(opponent: round.0, self: round.1)
    }
}

func roundScore(opponent: OpponentMove, self: SelfMove) -> Int {
    let winValue: Int
    switch (opponent, self) {
    case (.scissors, .rock),
        (.rock, .paper),
        (.paper, .scissors):
        winValue = 6
    case (.rock, .rock),
        (.paper, .paper),
        (.scissors, .scissors):
        winValue = 3
    case (.rock, .scissors),
        (.paper, .rock),
        (.scissors, .paper):
        winValue = 0
    }

    return self.scoreValue + winValue
}

// MARK: - Part 2

func part2(lines: [(OpponentMove, InstructionMove)]) -> Int {
    let transcodedLines = lines.map { line in
        let endState = GameFinishState(from: line.1)
        return (line.0, endState.selfMove(forOpponentMove: line.0))

    }
    return score(for: transcodedLines)
}


enum GameFinishState {
    case lose
    case draw
    case win

    init(from instruction: InstructionMove) {
        switch instruction {
        case .x:
            self = .lose
        case .y:
            self = .draw
        case .z:
            self = .win
        }
    }

    func selfMove(forOpponentMove opponentMove: OpponentMove) -> SelfMove {
        switch self {
        case .lose:
            return opponentMove.losingMove
        case .draw:
            return opponentMove.drawMove
        case .win:
            return opponentMove.winingMove
        }
    }
}

extension OpponentMove {
    var losingMove: SelfMove {
        switch self {
        case .rock:
            return .scissors
        case .paper:
            return .rock
        case .scissors:
            return .paper
        }
    }

    var drawMove: SelfMove {
        switch self {
        case .rock:
            return .rock
        case .paper:
            return .paper
        case .scissors:
            return .scissors
        }
    }

    var winingMove: SelfMove {
        switch self {
        case .rock:
            return .paper
        case .paper:
            return .scissors
        case .scissors:
            return .rock
        }
    }
}

main()
