import Foundation

struct MapCoordinate: Hashable {
    let line: Int
    let column: Int
}

extension MapCoordinate: CustomStringConvertible {
    var description: String { "[\(column), \(line)]" }

    func move(along direction: MapDirection) -> MapCoordinate {
        switch direction {
        case .top:
            return MapCoordinate(line: line - 1, column: column)
        case .left:
            return MapCoordinate(line: line, column: column - 1)
        case .right:
            return MapCoordinate(line: line, column: column + 1)
        case .bottom:
            return MapCoordinate(line: line + 1, column: column)
        }
    }
}
