import Foundation

struct Point: Hashable {
    let x: Int
    let y: Int
}

enum Fold {
    case alongX(Int)
    case alongY(Int)
}

// MARK: - Main

func main() {

    var points: [Point] = []
    var folds: [Fold] = []

    while let line = readLine(), !line.isEmpty {
        let coords = line.split(separator: ",").map { Int($0)! }
        points.append(Point(x: coords[0], y: coords[1]))
    }

    while let line = readLine() {
        let parts = line.split(separator: "=")
        if parts[0].last == "x" {
            folds.append(Fold.alongX(Int(parts[1])!))
        } else {
            folds.append(Fold.alongY(Int(parts[1])!))
        }
    }

    print(part1(points: points, folds: folds))
    part2(points: points, folds: folds)
}

// MARK: - Part 1

func part1(points: [Point], folds: [Fold]) -> Int {
    return fold(map: Set<Point>(points), along: folds[0]).count
}

func fold(map: Set<Point>, along: Fold) -> Set<Point> {
    var foldedMap: Set<Point> = []

    switch along {
    case .alongX(let x):
        for point in map {
            if point.x > x {
                foldedMap.insert(Point(x: x - (point.x - x), y: point.y))
            } else {
                foldedMap.insert(point)
            }
        }
    case .alongY(let y):
        for point in map {
            if point.y > y {
                foldedMap.insert(Point(x: point.x, y: y - (point.y - y)))
            } else {
                foldedMap.insert(point)
            }
        }
    }

    return foldedMap
}

// MARK: - Part 2

func part2(points: [Point], folds: [Fold]) {
    let finalMap = folds.reduce(Set<Point>(points)) { partialResult, fold in
        return Main.fold(map: partialResult, along: fold)
    }

    let maxX = finalMap.map(\.x).max()!
    let maxY = finalMap.map(\.y).max()!

    for y in 0...maxY {
        let line = (0...maxX).map { finalMap.contains(Point(x: $0, y: y)) ? "#" : "." }.joined(separator: "")
        print(line)
    }
/*
 .##....##.####..##..#....#..#.###....##
 #..#....#....#.#..#.#....#..#.#..#....#
 #.......#...#..#....#....#..#.#..#....#
 #.##....#..#...#.##.#....#..#.###.....#
 #..#.#..#.#....#..#.#....#..#.#....#..#
 .###..##..####..###.####..##..#.....##.
 */
}

main()
