import Foundation

struct Map<Element> {
    private let grid: [[Element]]

    init(_ grid: [[Element]]) {
        self.grid = grid
    }

    var height: Int {
        grid.count
    }

    var width: Int {
        guard height > 0 else { return 0 }
        return grid[0].count
    }

    subscript(_ coordinates: MapCoordinate) -> Element {
        grid[coordinates.line][coordinates.column]
    }

    func isValid(_ coordinates: MapCoordinate) -> Bool {
        return grid.indices.contains(coordinates.line)
        && grid[coordinates.line].indices.contains(coordinates.column)
    }
}

extension Map {

    var allCoordinates: [MapCoordinate] {
        return grid.indices.flatMap { line in
            grid[line].indices.map { MapCoordinate(line: line, column: $0) }
        }
    }

    func coordinates(from coordinate: MapCoordinate, along direction: MapDirection) -> [MapCoordinate] {
        var coordinates: [MapCoordinate] = []
        var currentCoordinate = coordinate
        while self.isValid(currentCoordinate) {
            coordinates.append(currentCoordinate)
            currentCoordinate = currentCoordinate.move(along: direction)
        }
        return coordinates
    }
}
