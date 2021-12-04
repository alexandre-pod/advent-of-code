import Foundation

struct Board {
    var lines: [[Int]]
}

func main() {

    let numbers = readLine()!.split(separator: ",").map { Int($0)! }
    var boards: [Board] = []

    while readLine() != nil {
        let boardLines: [[Int]] = (0..<5).map { _ in
            readLine()!.trimmingCharacters(in: .whitespaces)
                .split(separator: " ")
                .map { Int($0)! }
        }
        boards.append(Board(lines: boardLines))
    }

    print(part1(numbers: numbers, boards: boards))
    print(part2(numbers: numbers, boards: boards))
}

func part1(numbers: [Int], boards: [Board]) -> Int {

    let numberTurns: [Int: Int] = Dictionary(numbers.enumerated().map { ($0.element, $0.offset) }) { _, _ in
        fatalError("A same number cannot be appear twice")
    }

    let winningBoardWithTurn: (Board, Int) = boards
        .map { ($0, $0.winningTurn(fromNumberTurns: numberTurns)) }
        .min { $0.1 < $1.1 }!

    return score(for: winningBoardWithTurn.0, atWinningTurn: winningBoardWithTurn.1, numbers: numbers)
}

func part2(numbers: [Int], boards: [Board]) -> Int {

    let numberTurns: [Int: Int] = Dictionary(numbers.enumerated().map { ($0.element, $0.offset) }) { _, _ in
        fatalError("A same number cannot be appear twice")
    }

    let lastWinningBoardWithTurn: (Board, Int) = boards
        .map { ($0, $0.winningTurn(fromNumberTurns: numberTurns)) }
        .max { $0.1 < $1.1 }!

    return score(
        for: lastWinningBoardWithTurn.0,
        atWinningTurn: lastWinningBoardWithTurn.1,
        numbers: numbers
    )
}

extension Board {
    func winningTurn(fromNumberTurns numberTurns: [Int: Int]) -> Int {
        return (0..<5)
            .flatMap {
                [
                    winningTurn(forLine: $0, numberTurns: numberTurns),
                    winningTurn(forColumn: $0, numberTurns: numberTurns)
                ]
            }
            .min() ?? Int.max
    }

    func winningTurn(forLine line: Int, numberTurns: [Int: Int]) -> Int {
        assert(0..<5 ~= line)
        return lines[line]
            .compactMap { numberTurns[$0] }
            .max() ?? Int.max
    }

    func winningTurn(forColumn column: Int, numberTurns: [Int: Int]) -> Int {
        assert(0..<5 ~= column)
        return (0..<5)
            .map { lines[$0][column] }
            .compactMap { numberTurns[$0] }
            .max() ?? Int.max
    }
}

func score(for board: Board, atWinningTurn turn: Int, numbers: [Int]) -> Int {
    let winningBoardNumbers = Set(board.lines.flatMap { $0 })
    let appearedNumbers = Set(numbers[0...turn])
    let winningNumber = numbers[turn]

    return winningBoardNumbers.subtracting(appearedNumbers).reduce(0, +) * winningNumber
}

main()
