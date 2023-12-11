import Foundation

typealias StellarMap = [[Bool]]

func main() {
    var input: StellarMap = []

    while let line = readLine() {
        input.append(line.map { $0 == "#" })
    }

    print(part1(stellarMap: input))
    print(part2(stellarMap: input))
}

struct Coordinates: Hashable {
    let x: Int
    let y: Int
}

extension Coordinates {
    func distance(to other: Coordinates) -> Int {
        return abs(other.x - x) + abs(other.y - y)
    }
}

// MARK: - Part 1

func part1(stellarMap: StellarMap) -> Int {
    let starPositions = stellarMap.starPosition(withEmptyDistortionFactor: 2)
    return starPositions.pairs.map { $0.0.distance(to: $0.1) }.reduce(0, +)
}

extension StellarMap {
    func starPosition(withEmptyDistortionFactor distorsionFactor: Int) -> [Coordinates] {
        let emptyLineIndexes = self.enumerated().filter { $0.element.allSatisfy { !$0 } }.map(\.offset)
        let emptyColumnsIndexes = self[0].indices.filter { column in self.allSatisfy { !$0[column] } }

        var starPositions: [Coordinates] = []

        var distortedX = 0
        var distortedY = 0

        for rawY in self.indices {
            guard !emptyLineIndexes.contains(rawY) else {
                distortedY += distorsionFactor
                continue
            }
            distortedX = 0
            for rawX in self[rawY].indices {
                guard !emptyColumnsIndexes.contains(rawX) else {
                    distortedX += distorsionFactor
                    continue
                }
                if self[rawY][rawX] {
                    starPositions.append(Coordinates(x: distortedX, y: distortedY))
                }
                distortedX += 1
            }
            distortedY += 1
        }

        return starPositions
    }
}

extension Array {
    var pairs: [(Element, Element)] {
        var result: [(Element, Element)] = []
        for index in 0..<count {
            for pairIndex in index..<count {
                result.append((self[index], self[pairIndex]))
            }
        }
        return result
    }
}

// MARK: - Part 2

func part2(stellarMap: StellarMap) -> Int {
    let starPositions = stellarMap.starPosition(withEmptyDistortionFactor: 1000000)
    return starPositions.pairs.map { $0.0.distance(to: $0.1) }.reduce(0, +)
}

main()
