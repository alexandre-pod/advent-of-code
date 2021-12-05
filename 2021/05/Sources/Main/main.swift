import Foundation

struct Line {
    let start: Coordinate
    let end: Coordinate
}

struct Coordinate {
    let x: Int
    let y: Int
}

extension Line {
    init?<S: StringProtocol>(fromString string: S) {
        let components = string.split(separator: " ")
        guard components.count == 3 else { return nil }
        guard
            let start = Coordinate(fromString: components[0]),
            let end = Coordinate(fromString: components[2])
        else { return nil }
        self.init(start: start, end: end)
    }
}

extension Coordinate {
    init?<S: StringProtocol>(fromString string: S) {
        let components = string.split(separator: ",")
        guard components.count == 2 else { return nil }
        let intComponents = components.compactMap { Int($0) }
        guard intComponents.count == 2 else { return nil }
        self.init(x: intComponents[0], y: intComponents[1])
    }
}

// MARK: - Main

func main() {

    var lines: [Line] = []

    while let line = readLine() {
        lines.append(Line(fromString: line)!)
    }

    print(part1(lines: lines))
    print(part2(lines: lines))
}

// MARK: - Part 1

func part1(lines: [Line]) -> Int {

    return grid(
        from: lines.filter { $0.isHorizontal || $0.isVertical }
    ).flatMap { $0 }.filter { $0 >= 2 }.count
}

// MARK: - Part 2

func part2(lines: [Line]) -> Int {

    return grid(from: lines).flatMap { $0 }.filter { $0 >= 2 }.count
}

// MARK: - Utilities

func grid(from lines: [Line]) -> [[Int]] {
    let allX = lines.flatMap { [$0.start.x, $0.end.x] }
    let allY = lines.flatMap { [$0.start.x, $0.end.x] }
    let maxX = allX.max()!
    let maxY = allY.max()!

//    lines.forEach {
//        print($0)
//    }

    var grid: [[Int]] = Array(repeating: Array(repeating: 0, count: maxX + 1), count: maxY + 1)

    lines.forEach { line in
        line.points.forEach {
            grid[$0.y][$0.x] += 1
        }
    }

//    grid.forEach {
//        print($0)
//    }

    return grid
}

extension Line {

    var isHorizontal: Bool {
        start.y == end.y
    }

    var isVertical: Bool {
        start.x == end.x
    }

    var isDiagonal: Bool {
        let dx = abs(start.x - end.x)
        let dy = abs(start.y - end.y)
        return dx == dy
    }

    var points: [Coordinate] {
        if isHorizontal {
            return stride(
                from: start.x,
                through: end.x,
                by: start.x <= end.x ? 1 : -1
            ).map { Coordinate(x: $0, y: start.y) }
        }

        if isVertical {
            return stride(
                from: start.y,
                through: end.y,
                by: start.y <= end.y ? 1 : -1
            ).map { Coordinate(x: start.x, y: $0) }
        }

        if isDiagonal {
            let xStride = stride(
                from: start.x,
                through: end.x,
                by: start.x <= end.x ? 1 : -1
            )
            let yStride = stride(
                from: start.y,
                through: end.y,
                by: start.y <= end.y ? 1 : -1
            )
            return zip(xStride, yStride).map { Coordinate(x: $0.0, y: $0.1) }
        }

        fatalError("Unexpected line slope")
    }
}

main()

// MARK: - Debug

extension Line: CustomStringConvertible {
    var description: String {
        return "\(start) -> \(end)"
    }
}

extension Coordinate: CustomStringConvertible {
    var description: String {
        return "\(x),\(y)"
    }
}
