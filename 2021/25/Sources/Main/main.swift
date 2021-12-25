import Foundation

struct Position: Hashable {
    let x: Int
    let y: Int
}

struct SeaCucumber : Hashable {
    let isVertical: Bool
    let position: Position
}

struct Map {
    var cucumbers: [SeaCucumber]
    let height: Int
    let width: Int
}

// MARK: - Main

func main() {

    var cucumbers: [SeaCucumber] = []

    var y = 0
    var width = -1

    while let line = readLine() {
        if width == -1 {
            width = line.count
        }
        line.enumerated().forEach {
            switch $0.element {
            case "v":
                cucumbers.append(SeaCucumber(isVertical: true, position: Position(x: $0.offset, y: y)))
            case ">":
                cucumbers.append(SeaCucumber(isVertical: false, position: Position(x: $0.offset, y: y)))
            default:
                return
            }
        }
        y += 1
    }

    let map = Map(
        cucumbers: cucumbers,
        height: y,
        width: width
    )

    print(part1(map: map))
}

// MARK: - Part 1

func part1(map: Map) -> Int {

    var step = 1

    var previousMap = map
    var nextMap = previousMap.moveCuncumbers()

    while Set(nextMap.cucumbers) != Set(previousMap.cucumbers) {
        previousMap = nextMap
        nextMap = previousMap.moveCuncumbers()
        step += 1
    }

    return step
}

extension Map {

    func moveCuncumbers() -> Map {
        return moveHorizontalCuncumbers().moveVerticalCuncumbers()
    }

    func moveVerticalCuncumbers() -> Map {
        var copy = self
        copy.cucumbers = copy.cucumbers.filter { !$0.isVertical }
        let usedSpaces: Set<Position> = Set(cucumbers.map(\.position))

        copy.cucumbers.append(
            contentsOf: cucumbers
            .filter { $0.isVertical }
            .map {
                let nextPosition = $0.nextPosition(in: self)
                if usedSpaces.contains(nextPosition) {
                    return $0
                } else {
                    return SeaCucumber(isVertical: true, position: nextPosition)
                }
            }
        )

        return copy
    }

    func moveHorizontalCuncumbers() -> Map {
        var copy = self
        copy.cucumbers = copy.cucumbers.filter { $0.isVertical }
        let usedSpaces: Set<Position> = Set(cucumbers.map(\.position))

        copy.cucumbers.append(
            contentsOf: cucumbers
                .filter { !$0.isVertical }
                .map {
                    let nextPosition = $0.nextPosition(in: self)
                    if usedSpaces.contains(nextPosition) {
                        return $0
                    } else {
                        return SeaCucumber(isVertical: false, position: nextPosition)
                    }
                }
        )

        return copy
    }
}

extension SeaCucumber {
    func nextPosition(in map: Map) -> Position {
        if isVertical {
            return Position(x: position.x, y: (position.y + 1) % map.height)
        } else {
            return Position(x: (position.x + 1) % map.width, y: position.y)
        }
    }
}

// MARK: - Start

main()

// MARK: - Debug

extension Map {
    func debugPrint() {
        for y in 0..<self.height {
            print((0..<self.width).map { x -> String in
                let position = Position(x: x, y: y)
                if let found = cucumbers.first(where: { $0.position == position }) {
                    return found.isVertical ? "v" : ">"
                }
                return "."
            }.joined())
        }
    }
}
