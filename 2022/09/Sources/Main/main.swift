import Foundation

struct Move {
    let direction: Direction
    let amount: Int
}

enum Direction: String {
    case up = "U"
    case left = "L"
    case right = "R"
    case down = "D"
}

func main() {
    var moves: [Move] = []

    while let line = readLine() {
        let components = line.split(separator: " ").map { String($0) }
        let move = Move(
            direction: Direction(rawValue: components[0])!,
            amount: Int(components[1])!
        )
        moves.append(move)
    }

    print(part1(moves: moves))
    print(part2(moves: moves))
}

// MARK: - Part 1

struct Coordinate: Hashable {
    var x: Int
    var y: Int
}

func part1(moves: [Move]) -> Int {
    var head = Coordinate(x: 0, y: 0)
    var tail = Coordinate(x: 0, y: 0)

    var tailSeenPositions: Set<Coordinate> = [tail]

    for move in moves {
        head.moveHead(with: move, tail: &tail, tailSeenPositions: &tailSeenPositions)
    }

    return tailSeenPositions.count
}

extension Coordinate {
    func distance(to other: Coordinate) -> Int {
        return abs(x - other.x) + abs(y - other.y)
    }

    mutating func moveHead(with move: Move, tail: inout Coordinate, tailSeenPositions: inout Set<Coordinate>) {
        for _ in 1...move.amount {
            self = self.move(along: move.direction)
            tail = tail.moveTail(following: self)
            tailSeenPositions.insert(tail)
        }
    }

    func moveTail(following head: Coordinate) -> Coordinate {
        var tail = self

        let headTailDistance = tail.distance(to: head)
        assert(headTailDistance <= 4, "Invalid state")
        guard headTailDistance > 1 else { return self }

        if headTailDistance == 2, head.x != tail.x, head.y != tail.y {
            return self
        }

        if head.x == tail.x {
            if tail.y > head.y {
                return tail.move(along: .up)
            } else {
                return tail.move(along: .down)
            }
        } else if head.y == tail.y {
            if tail.x > head.x {
                return tail.move(along: .left)
            } else {
                return tail.move(along: .right)
            }
        }

        return tail.diagonalMoves.map { ($0, $0.distance(to: head)) }.min { $0.1 < $1.1 }!.0
    }

    func move(along direction: Direction) -> Coordinate {
        switch direction {
        case .up:
            return Coordinate(x: x, y: y - 1)
        case .left:
            return Coordinate(x: x - 1, y: y)
        case .right:
            return Coordinate(x: x + 1, y: y)
        case .down:
            return Coordinate(x: x, y: y + 1)
        }
    }

    var diagonalMoves: [Coordinate] {
        return [
            Coordinate(x: x + 1, y: y + 1),
            Coordinate(x: x + 1, y: y - 1),
            Coordinate(x: x - 1, y: y + 1),
            Coordinate(x: x - 1, y: y - 1)
        ]
    }
}

// MARK: - Part 2

typealias Rope = [Coordinate]

extension Rope {
    mutating func moveHead(with move: Move, tailSeenPositions: inout Set<Coordinate>) {
        guard !isEmpty else { fatalError("Invalid state") }
        for _ in 1...move.amount {
            self[0] = self[0].move(along: move.direction)
            for (tailIndex, headIndex) in zip(indices.dropFirst(), indices) {
                self[tailIndex] = self[tailIndex].moveTail(following: self[headIndex])
            }
            tailSeenPositions.insert(self.last!)
        }
    }
}

func part2(moves: [Move]) -> Int {
    var rope = Array(repeating: Coordinate(x: 0, y: 0), count: 10)
    var tailSeenPositions: Set<Coordinate> = [Coordinate(x: 0, y: 0)]

    for move in moves {
        rope.moveHead(with: move, tailSeenPositions: &tailSeenPositions)
//        print("=========================")
//        print(move)
//        rope.debugPrint(minX: -11, minY: -15, width: 21, height: 21)
    }

    return tailSeenPositions.count
}


extension Rope {
    func debugPrint(minX: Int, minY: Int, width: Int, height: Int) {
        var symbolsMap: [Coordinate: String] = [:]
        symbolsMap[Coordinate(x: 0, y: 0)] = "s"
        enumerated().reversed().forEach { symbolsMap[$0.element] = String($0.offset) }
        symbolsMap[self[0]] = "H"

        for y in (minY..<(minY + height)) {
            for x in minX..<(minX + width) {
                print(symbolsMap[Coordinate(x: x, y: y), default: "."], separator: "", terminator: "")
            }
            print("")
        }
    }
}

main()
