import Foundation

struct Point: Hashable {
    let x: Int
    let y: Int
}

extension Array where Element == [Int] {
    subscript(_ point: Point) -> Int {
        self[point.y][point.x]
    }

    var allPoints: [Point] {
        return (0..<self.count).flatMap { y in
            (0..<self[y].count).map { x in
                Point(x: x, y: y)
            }
        }
    }
}

func adjacentPoints(to point: Point, in grid: [[Int]]) -> [Point] {
    return [
        Point(x: point.x - 1, y: point.y),
        Point(x: point.x + 1, y: point.y),
        Point(x: point.x, y: point.y - 1),
        Point(x: point.x, y: point.y + 1)
    ].filter { $0.x >= 0 && $0.x < grid[0].count && $0.y >= 0 && $0.y < grid.count }
}

// MARK: - Main

func main() {

    var grid: [[Int]] = []

    while let line = readLine() {
        grid.append(line.map({ Int(String($0))! }))
    }

    print(part1(grid: grid))
    print(part2(grid: grid))
}

// MARK: - Part 1

func part1(grid: [[Int]]) -> Int {

//    grid.forEach { print($0.map(String.init).joined()) }

    let (_, totalCost) = getShortestPathPrecedentAndTotalCost(
        grid: grid,
        start: Point(x: 0, y: 0)
    )

    return totalCost[Point(x: grid[0].count - 1, y: grid.count - 1), default:  -1]
}

func getShortestPathPrecedentAndTotalCost(grid: [[Int]], start: Point) -> ([Point: Point], [Point: Int]) {
    var remainingPoints: Set<Point> = Set(grid.allPoints)
    var result: [Point: Point] = [:]

    var totalCost: [Point: Int] = [:]
    var totalCostPrecedent: [Point: Point] = [:]

    var nearGraphedPoints: Set<Point> = []

    remainingPoints.remove(start)
//    result[start] = start
    totalCost[start] = 0

    adjacentPoints(to: start, in: grid).forEach {
        nearGraphedPoints.insert($0)
        totalCost[$0] = totalCost[start]! + grid[$0]
        totalCostPrecedent[$0] = start
    }

    while !remainingPoints.isEmpty {
        let (closestPoint, _) = nearGraphedPoints
            .map { ($0, totalCost[$0, default: Int.max]) }
            .min { $0.1 < $1.1 }!
        result[closestPoint] = totalCostPrecedent[closestPoint]!
        remainingPoints.remove(closestPoint)
        nearGraphedPoints.remove(closestPoint)

        adjacentPoints(to: closestPoint, in: grid)
            .filter { remainingPoints.contains($0) }
            .forEach {
                nearGraphedPoints.insert($0)
                let newTotalCost = totalCost[closestPoint]! + grid[$0]
                if newTotalCost < totalCost[$0, default: Int.max] {
                    totalCost[$0] = newTotalCost
                    totalCostPrecedent[$0] = closestPoint
                }
            }
    }

    return (result, totalCost)
}

// MARK: - Part 2

func part2(grid: [[Int]]) -> Int {

//    completeGrid(from: grid).forEach { print($0.map(String.init).joined())
//    }

    let completeGrid = completeGrid(from: grid)

    let (_, totalCost) = getShortestPathPrecedentAndTotalCost(
        grid: completeGrid,
        start: Point(x: 0, y: 0)
    )

    return totalCost[Point(x: completeGrid[0].count - 1, y: completeGrid.count - 1), default:  -1]
}

func completeGrid(from grid: [[Int]]) -> [[Int]] {
    let partialGrid = grid.map { line in
        (0..<5).flatMap { increase(line: line, by: $0) }
    }

    return (0..<5).map {
        increase(grid: partialGrid, by: $0)
    }
    .reduce([], +)
}

func increase(line: [Int], by amount: Int) -> [Int] {
    line.map {
        var increasedValue = $0 + amount
        while increasedValue >= 10 { increasedValue -= 9 }
        return increasedValue
    }
}

func increase(grid: [[Int]], by amount: Int) -> [[Int]] {
    return grid.map { increase(line: $0, by: amount) }
}

main()
