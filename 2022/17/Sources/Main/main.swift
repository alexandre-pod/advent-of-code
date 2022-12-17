import Foundation

typealias InputType = [GameInput]

func main() {
    var input: InputType = []

    input = readLine()!.map { GameInput(rawValue: $0)! }

    print(part1(inputParameter: input))
    print(part2(inputParameter: input))
}

// MARK: - Part 1

func part1(inputParameter: InputType) -> Int {
    var game = Game()

    var inputIndex = 0

//    game.display()

    var settledShapes = 0

    while settledShapes < 2022 {
        let input = inputParameter[inputIndex]
        inputIndex = (inputIndex + 1) % inputParameter.count
        game.handleInput(input)
//        print(input)
//        game.display()
//        print("Gravity")
        if game.handleGameTick() != nil {
            settledShapes += 1
//            game.display()
        }
    }

    return game.highestPoint + 1
}

struct Point: Hashable {
    let x: Int
    let y: Int
}

enum GameInput: Character {
    case left = "<"
    case right = ">"
}

struct Game {
    private let mapWidth = 7
    private(set) var highestPoint = 0
    private(set) var currentShape = 0
    private var currentShapePosition = Point(x: 2, y: 3)
    private var occupiedPoints: Set<Point> = []

    mutating func handleInput(_ input: GameInput) {
        let nextPosition = nextShapePosition(with: input)
        if isShapeColliding(at: nextPosition) {
            return
        } else {
            currentShapePosition = nextPosition
        }
    }

    /// Returns the coordinates of the settled piece when settled, and nil if the shape can continue to fall
    @discardableResult
    mutating func handleGameTick() -> [Point]? {
        let nextPosition = currentShapePosition - Point(x: 0, y: 1)
        if isShapeColliding(at: nextPosition) {
            return settleCurrentShape()
        } else {
            currentShapePosition = nextPosition
            return nil
        }
    }

    func display() {
        let maxY = max(highestPoint, currentShapePosition.y + shapes[currentShape].height)
        let currentPiecePositions: Set<Point> = Set(shapes[currentShape].filledCoordinates.map { $0 + currentShapePosition })
        print()
        for y in (0..<maxY).reversed() {
            let gridContent = (0..<mapWidth).map { x in
                let point = Point(x: x, y: y)
                if currentPiecePositions.contains(point) {
                    return "@"
                } else if occupiedPoints.contains(point) {
                    return "#"
                } else {
                    return "."
                }
            }.joined()
            print("|" + gridContent + "|")
        }
        print("+" + (0..<mapWidth).map { _ in "-" }.joined() + "+")
    }

    // MARK: - Private

    mutating func settleCurrentShape() -> [Point] {
        let points = shapes[currentShape]
            .filledCoordinates
            .map { currentShapePosition + $0 }
        points.forEach {
            highestPoint = max(highestPoint, $0.y)
            occupiedPoints.insert($0)
        }
        currentShape = (currentShape + 1) % shapes.count
        currentShapePosition = Point(x: 2, y: highestPoint + 4)
        return points
    }

    private func isShapeColliding(at point: Point) -> Bool {
        let shape = shapes[currentShape]
        guard point.y >= 0,
              point.x >= 0,
              point.x + shape.width <= mapWidth
        else { return true }
        return shape.filledCoordinates
            .map { point + $0 }
            .contains { occupiedPoints.contains($0) }
    }

    private func nextShapePosition(with input: GameInput) -> Point {
        switch input {
        case .left:
            return currentShapePosition - Point(x: 1, y: 0)
        case .right:
            return currentShapePosition + Point(x: 1, y: 0)
        }
    }

}

extension Shape {

    var height: Int {
        return count
    }

    var width: Int {
        return first?.count ?? 0
    }

    var filledCoordinates: [Point] {
        return (0..<height).flatMap { y in
            return (0..<width).compactMap { x in
                if self[height - 1 - y][x] == "#" {
                    return Point(x: x, y: y)
                } else {
                    return nil
                }
            }
        }
    }
}

extension Point: AdditiveArithmetic {
    static func - (lhs: Point, rhs: Point) -> Point {
        Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func + (lhs: Point, rhs: Point) -> Point {
        Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static var zero: Point {
        Point(x: 0, y: 0)
    }
}

// MARK: - Part 2

func part2(inputParameter: InputType) -> Int {
    var inputIndex = 0

    var game = Game()

    struct CacheKey: Hashable {
        let currentShape: Int
        let inputCountSinceLastSettled: Int
    }

    struct CacheValue {
        let shapeCount: Int
    }

    var cache: [CacheKey: CacheValue] = [:]
    var heightAfterShape: [Int: Int] = [:]

    var settledShapes = 0
    var inputCountSinceLastSettled = 0
    while settledShapes < 1_000_000_000_000 {
        if inputIndex == 0 {
            let key = CacheKey(currentShape: game.currentShape, inputCountSinceLastSettled: inputCountSinceLastSettled)
            if let cachedValue = cache[key] {

                let cycleLength = settledShapes - cachedValue.shapeCount
                let heightPerCycle = heightAfterShape[settledShapes]! - heightAfterShape[cachedValue.shapeCount]!

                let shapeCountBeforeCycle = cachedValue.shapeCount
                let heightBeforeFirstCycle = heightAfterShape[shapeCountBeforeCycle]!

                let remainingShapesToSimulate = 1_000_000_000_000 - shapeCountBeforeCycle

                let totalCycleCount = remainingShapesToSimulate / cycleLength
                let missingCycleCount = remainingShapesToSimulate % cycleLength

                let finalHeight = heightBeforeFirstCycle
                    + totalCycleCount * heightPerCycle
                    + heightAfterShape[cachedValue.shapeCount + missingCycleCount]! - heightAfterShape[cachedValue.shapeCount]!

                return finalHeight
            } else {
                cache[key] = CacheValue(shapeCount: settledShapes)
            }
        }
        let input = inputParameter[inputIndex]
        inputIndex = (inputIndex + 1) % inputParameter.count
        game.handleInput(input)
        inputCountSinceLastSettled += 1
        if game.handleGameTick() != nil {
            settledShapes += 1
            inputCountSinceLastSettled = 0
            heightAfterShape[settledShapes] = game.highestPoint + 1
        }
    }

    return game.highestPoint + 1
}

main()
