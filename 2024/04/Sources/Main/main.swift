import Foundation

typealias InputType = [[Character]]

func main() {
    var input: InputType = []

    while let line = readLine() {
        input.append(Array(line))
    }

    print(part1(inputParameter: input))
    print(part2(inputParameter: input))
}

// MARK: - Part 1

func part1(inputParameter: InputType) -> Int {
    var xmasCount = 0

    for y in inputParameter.indices {
        for x in inputParameter[y].indices {
            guard inputParameter[y][x] == "X" else { continue }
            Direction.all.forEach {
                if find("XMAS", along: $0, in: inputParameter, fromX: x, y: y) {
                    xmasCount += 1
                }
            }
        }
    }

    return xmasCount
}

struct Direction: Hashable {
    let xOffset: Int
    let yOffset: Int

    static let n = Self(xOffset: 0, yOffset: 1)
    static let ne = Self(xOffset: 1, yOffset: 1)
    static let e = Self(xOffset: 1, yOffset: 0)
    static let se = Self(xOffset: 1, yOffset: -1)
    static let s = Self(xOffset: 0, yOffset: -1)
    static let sw = Self(xOffset: -1, yOffset: -1)
    static let w = Self(xOffset: -1, yOffset: 0)
    static let nw = Self(xOffset: -1, yOffset: 1)

    static let all: [Self] = [.n, .ne, .e, .se, .s, .sw, .w, .nw]
    static let diagonals: [Self] = [.ne, .se, .sw, .nw]
}

func find(_ text: String, along direction: Direction, in grid: InputType, fromX x: Int, y: Int) -> Bool {
//    assert(grid[y][x] == text.first)
    var x = x
    var y = y
    for char in text {
        guard grid.indices.contains(y),
              grid[y].indices.contains(x),
              grid[y][x] == char else {
            return false
        }
        x += direction.xOffset
        y += direction.yOffset
    }
    return true
}

// MARK: - Part 2

func part2(inputParameter: InputType) -> Int {
    var x_masCount = 0

    for y in inputParameter.indices.dropFirst().dropLast() {
        for x in inputParameter[y].indices.dropFirst().dropLast() {
            guard inputParameter[y][x] == "A" else { continue }
            if findX_MAS(in: inputParameter, fromAAtX: x, y: y) {
                x_masCount += 1
            }
        }
    }

    return x_masCount
}

func findX_MAS(in grid: InputType, fromAAtX x: Int, y: Int) -> Bool {
    let fromNW = find("MAS", along: .se, in: grid, fromX: x - 1, y: y + 1)
    let fromNE = find("MAS", along: .sw, in: grid, fromX: x + 1, y: y + 1)
    let fromSW = find("MAS", along: .ne, in: grid, fromX: x - 1, y: y - 1)
    let fromSE = find("MAS", along: .nw, in: grid, fromX: x + 1, y: y - 1)

    return [fromNW, fromNE, fromSW, fromSE].filter({ $0 }).count == 2
}

//func part2UsingMoreMemory(inputParameter: InputType) -> Int {
//    let height = inputParameter.count
//    let width = inputParameter[0].count
//
//    var x_masCount = 0
//
//    var masDirectionsGrid: [[Set<Direction>]] = Array(repeating: Array(repeating: [], count: width), count: height)
//
//    for y in inputParameter.indices {
//        for x in inputParameter[y].indices {
//            guard inputParameter[y][x] == "M" else { continue }
//            masDirectionsGrid[y][x] = Set(Direction.diagonals.filter {
//                find("MAS", along: $0, in: inputParameter, fromX: x, y: y)
//            })
//        }
//    }
//
//    for y in inputParameter.indices.dropFirst().dropLast() {
//        for x in inputParameter[y].indices.dropFirst().dropLast() {
//            let fromNW = masDirectionsGrid[y + 1][x - 1].contains(.se)
//            let fromNE = masDirectionsGrid[y + 1][x + 1].contains(.sw)
//            let fromSW = masDirectionsGrid[y - 1][x - 1].contains(.ne)
//            let fromSE = masDirectionsGrid[y - 1][x + 1].contains(.nw)
//            if [fromNW, fromNE, fromSW, fromSE].filter({ $0 }).count == 2 {
//                //                print("X-MAS at (\(x), \(y))")
//                x_masCount += 1
//            }
//        }
//    }
//
//    return x_masCount
//}

main()
