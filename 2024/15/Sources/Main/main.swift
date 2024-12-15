import Foundation

struct WarehouseState<Content> {
    var map: Grid2D<Content>
    let moves: [Direction]
    let robotPosition: Coordinate2D
}

extension WarehouseState<Cell> {
    init?(map: Grid2D<Cell>, moves: [Direction]) {
        guard let robotPosition = map.allCoordinates.first(where: { map[$0] == .robot }) else { return nil }
        self.map = map
        self.moves = moves
        self.robotPosition = robotPosition

        self.map[robotPosition] = .empty
    }
}

extension WarehouseState<WideCell> {
    init?(map: Grid2D<WideCell>, moves: [Direction]) {
        guard let robotPosition = map.allCoordinates.first(where: { map[$0] == .robot }) else { return nil }
        self.map = map
        self.moves = moves
        self.robotPosition = robotPosition

        self.map[robotPosition] = .empty
    }
}

func main() {
    let input = WarehouseState(
        map: parseMap(),
        moves: parseMoves()
    )!

    print(part1(warehouseState: input))
    print(part2(warehouseState: input))
}

enum Cell: Character {
    case empty = "."
    case box = "O"
    case wall = "#"
    case robot = "@"
}

func parseMap() -> Grid2D<Cell> {
    var rows: [[Cell]] = []

    while let line = readLine(), !line.isEmpty {
        rows.append(line.map { Cell(rawValue: $0)! })
    }

    return Grid2D(cells: rows)
}

func parseMoves() -> [Direction] {
    var moves: [Direction] = []

    while let line = readLine() {
        moves.append(contentsOf: line.map { Direction(symbol: $0)! })
    }

    return moves
}

extension Direction {
    init?(symbol: Character) {
        switch symbol {
        case "^": self = .up
        case "v": self = .down
        case "<": self = .left
        case ">": self = .right
        default: return nil
        }
    }

    var symbol: Character {
        return switch self {
        case .up: "^"
        case .down: "v"
        case .left: "<"
        case .right: ">"
        default: "?"
        }
    }
}

// MARK: - Part 1

func part1(warehouseState: WarehouseState<Cell>) -> Int {

//    warehouseState.map.printDebug(celltoCharacter: \.rawValue)
//    print(warehouseState.moves.map { String($0.symbol) }.joined())

//    var state = warehouseState
    var map = warehouseState.map
    var robotPosition = warehouseState.robotPosition

    for move in warehouseState.moves {
        map.moveRobot(from: &robotPosition, along: move)
//        print(move.symbol)
//        map.with(cell: .robot, at: robotPosition).printDebug(celltoCharacter: \.rawValue)
    }

    map.with(cell: .robot, at: robotPosition).printDebug(celltoCharacter: \.rawValue)

    return map.boxGPSCoordinates.reduce(0, +)
}

extension Grid2D {
    func with(cell: Cell, at: Coordinate2D) -> Self {
        var copy = self
        copy[at] = cell
        return copy
    }
}

extension Grid2D<Cell> {
    mutating func moveRobot(from position: inout Coordinate2D, along direction: Direction) {
        let targetPosition = position.moved(by: direction)
        switch self[targetPosition] {
        case .empty:
            position = targetPosition
        case .wall:
            break
        case .box:
            if moveBox(from: targetPosition, along: direction) {
                position = targetPosition
            }
        case .robot:
            fatalError("Robot should not be a state in the map")
        }
    }

    mutating func moveBox(from position: Coordinate2D, along direction: Direction) -> Bool {
        assert(self[position] == .box)
        let cellContent = self[position]
        let targetPosition = position.moved(by: direction)
        switch self[targetPosition] {
        case .empty:
            self[position] = .empty
            self[targetPosition] = cellContent
            return true
        case .wall:
            return false
        case .box:
            if moveBox(from: targetPosition, along: direction) {
                self[position] = .empty
                self[targetPosition] = .box
                return true
            }
            return false
        case .robot:
            fatalError("Robot should not be a state in the map")
        }
    }

    var boxGPSCoordinates: [Int] {
        return allCoordinates
            .filter { self[$0] == .box }
            .map { $0.y * 100 + $0.x }
    }
}

// MARK: - Part 2

func part2(warehouseState: WarehouseState<Cell>) -> Int {

    var map = warehouseState.map.convertToWide()
    var robotPosition = Coordinate2D(
        x: warehouseState.robotPosition.x * 2,
        y: warehouseState.robotPosition.y
    )

//    map.with(cell: .robot, at: robotPosition).printDebug(celltoCharacter: \.rawValue)

    for move in warehouseState.moves {
        map.moveRobot(from: &robotPosition, along: move)
//        print(move.symbol)
//        map.with(cell: .robot, at: robotPosition).printDebug(celltoCharacter: \.rawValue)
    }

    map.with(cell: .robot, at: robotPosition).printDebug(celltoCharacter: \.rawValue)

    return map.boxGPSCoordinates.reduce(0, +)
}

enum WideCell: Character {
    case empty = "."
    case boxL = "["
    case boxR = "]"
    case wall = "#"
    case robot = "@"
}

extension Grid2D<Cell> {
    func convertToWide() -> Grid2D<WideCell> {
        return Grid2D<WideCell>(
            cells: cells.map { line in
                line.flatMap { $0.toWide }
            }
        )
    }
}

extension Cell {
    var toWide: [WideCell] {
        switch self {
        case .empty:
            [.empty, .empty]
        case .box:
            [.boxL, .boxR]
        case .wall:
            [.wall, .wall]
        case .robot:
            [.robot, .empty]
        }
    }
}

extension Grid2D<WideCell> {
    mutating func moveRobot(from position: inout Coordinate2D, along direction: Direction) {
        let targetPosition = position.moved(by: direction)
        switch self[targetPosition] {
        case .empty:
            position = targetPosition
        case .wall:
            break
        case .boxL:
            guard canMoveBox(from: targetPosition, along: direction) else { return }
            moveBox(from: targetPosition, along: direction)
            position = targetPosition
        case .boxR:
            guard canMoveBox(from: targetPosition.moved(by: .left), along: direction) else { return }
            moveBox(from: targetPosition.moved(by: .left), along: direction)
            position = targetPosition
        case .robot:
            fatalError("Robot should not be a state in the map")
        }
    }

    func canMoveBox(from positionL: Coordinate2D, along direction: Direction) -> Bool {
        assert(self[positionL] == .boxL)
        let positionR = positionL.moved(by: .right)
        let cellContent = self[positionL]
        let targetPositionL = positionL.moved(by: direction)
        let targetPositionR = positionR.moved(by: direction)
        switch (self[targetPositionL], self[targetPositionR]) {
        case (.empty, .empty),
            (.boxR, .empty) where direction == .right,
            (.empty, .boxL) where direction == .left:
            return true
        case (.boxR, .boxL) where direction == .right:
            return canMoveBox(from: targetPositionR, along: direction)
        case (.boxR, .boxL) where direction == .left:
            return canMoveBox(from: targetPositionL.moved(by: .left), along: direction)
        case (.boxR, .empty) where direction == .up || direction == .down:
            return canMoveBox(from: targetPositionL.moved(by: .left), along: direction)
        case (.boxL, .boxR) where direction == .up || direction == .down:
            return canMoveBox(from: targetPositionL, along: direction)
        case (.empty, .boxL) where direction == .up || direction == .down:
            return canMoveBox(from: targetPositionR, along: direction)
        case (.boxR, .boxL) where direction == .up || direction == .down:
            return canMoveBox(from: targetPositionR, along: direction)
                && canMoveBox(from: targetPositionL.moved(by: .left), along: direction)
//        case (.wall, _), (_, .wall):
//            return false
        default:
            return false
        }
    }

    mutating func moveBox(from positionL: Coordinate2D, along direction: Direction) {
        assert(self[positionL] == .boxL)
        let positionR = positionL.moved(by: .right)
        let targetPositionL = positionL.moved(by: direction)
        let targetPositionR = positionR.moved(by: direction)
        switch direction {
        case .up, .down:
            switch (self[targetPositionL], self[targetPositionR]) {
            case (.boxR, .empty):
                moveBox(from: targetPositionL.moved(by: .left), along: direction)
            case (.boxL, .boxR):
                moveBox(from: targetPositionL, along: direction)
            case (.empty, .boxL):
                moveBox(from: targetPositionR, along: direction)
            case (.boxR, .boxL):
                moveBox(from: targetPositionL.moved(by: .left), along: direction)
                moveBox(from: targetPositionR, along: direction)
            case (.empty, .empty):
                break
            default:
                fatalError("unexpected state")
            }
            self[targetPositionL] = .boxL
            self[targetPositionR] = .boxR
            self[positionL] = .empty
            self[positionR] = .empty
        case .right:
            if self[targetPositionR] == .boxL {
                moveBox(from: targetPositionR, along: direction)
            }
            self[targetPositionL] = .boxL
            self[targetPositionR] = .boxR
            self[positionL] = .empty
        case .left:
            if self[targetPositionL] == .boxR {
                moveBox(from: targetPositionL.moved(by: .left), along: direction)
            }
            self[targetPositionL] = .boxL
            self[targetPositionR] = .boxR
            self[positionR] = .empty
            break
        default:
            fatalError()
        }
    }

    var boxGPSCoordinates: [Int] {
        return allCoordinates
            .filter { self[$0] == .boxL }
            .map { $0.y * 100 + $0.x }
    }
}


main()
