import Foundation

func part2WrapCache() -> [DirectionalCoordinate : DirectionalCoordinate] {
    var wrapCache: [DirectionalCoordinate : DirectionalCoordinate] = [:]

    let side = 50

    for i in 0..<side {
        let fromSideX = 0
        let fromSideY = 2
        let fromDirection = Direction.up
        let toSideX = 1
        let toSideY = 1
        let toDirection = Direction.right
        let fromCoordinate = Coordinate(
            x: fromSideX * side + i,
            y: fromSideY * side
        )
        let toCoordinate = Coordinate(
            x: toSideX * side,
            y: toSideY * side + i
        )
        let from = DirectionalCoordinate(coordinate: fromCoordinate, direction: fromDirection)
        let to = DirectionalCoordinate(coordinate: toCoordinate, direction: toDirection)
        wrapCache[from] = to

        let fromOpposite = DirectionalCoordinate(coordinate: fromCoordinate, direction: fromDirection.opposite)
        let toOpposite = DirectionalCoordinate(coordinate: toCoordinate, direction: toDirection.opposite)
        wrapCache[toOpposite] = fromOpposite
    }

    for i in 0..<side {
        let fromSideX = 0
        let fromSideY = 2
        let fromDirection = Direction.left
        let toSideX = 1
        let toSideY = 0
        let toDirection = Direction.right
        let fromCoordinate = Coordinate(
            x: fromSideX * side,
            y: fromSideY * side + i
        )
        let toCoordinate = Coordinate(
            x: toSideX * side,
            y: toSideY * side + (side - 1) - i
        )
        let from = DirectionalCoordinate(coordinate: fromCoordinate, direction: fromDirection)
        let to = DirectionalCoordinate(coordinate: toCoordinate, direction: toDirection)
        wrapCache[from] = to

        let fromOpposite = DirectionalCoordinate(coordinate: fromCoordinate, direction: fromDirection.opposite)
        let toOpposite = DirectionalCoordinate(coordinate: toCoordinate, direction: toDirection.opposite)
        wrapCache[toOpposite] = fromOpposite
    }

    for i in 0..<side {
        let fromSideX = 0
        let fromSideY = 3
        let fromDirection = Direction.left
        let toSideX = 1
        let toSideY = 0
        let toDirection = Direction.bottom
        let fromCoordinate = Coordinate(
            x: fromSideX * side,
            y: fromSideY * side + i
        )
        let toCoordinate = Coordinate(
            x: toSideX * side + i,
            y: toSideY * side
        )
        let from = DirectionalCoordinate(coordinate: fromCoordinate, direction: fromDirection)
        let to = DirectionalCoordinate(coordinate: toCoordinate, direction: toDirection)
        wrapCache[from] = to

        let fromOpposite = DirectionalCoordinate(coordinate: fromCoordinate, direction: fromDirection.opposite)
        let toOpposite = DirectionalCoordinate(coordinate: toCoordinate, direction: toDirection.opposite)
        wrapCache[toOpposite] = fromOpposite
    }

    for i in 0..<side {
        let fromSideX = 0
        let fromSideY = 3
        let fromDirection = Direction.bottom
        let toSideX = 2
        let toSideY = 0
        let toDirection = Direction.bottom
        let fromCoordinate = Coordinate(
            x: fromSideX * side + i,
            y: fromSideY * side + side - 1
        )
        let toCoordinate = Coordinate(
            x: toSideX * side + i,
            y: toSideY * side
        )
        let from = DirectionalCoordinate(coordinate: fromCoordinate, direction: fromDirection)
        let to = DirectionalCoordinate(coordinate: toCoordinate, direction: toDirection)
        wrapCache[from] = to

        let fromOpposite = DirectionalCoordinate(coordinate: fromCoordinate, direction: fromDirection.opposite)
        let toOpposite = DirectionalCoordinate(coordinate: toCoordinate, direction: toDirection.opposite)
        wrapCache[toOpposite] = fromOpposite
    }

    for i in 0..<side {
        let fromSideX = 0
        let fromSideY = 3
        let fromDirection = Direction.right
        let toSideX = 1
        let toSideY = 2
        let toDirection = Direction.up
        let fromCoordinate = Coordinate(
            x: fromSideX * side + (side - 1),
            y: fromSideY * side + i
        )
        let toCoordinate = Coordinate(
            x: toSideX * side + i,
            y: toSideY * side + (side - 1)
        )
        let from = DirectionalCoordinate(coordinate: fromCoordinate, direction: fromDirection)
        let to = DirectionalCoordinate(coordinate: toCoordinate, direction: toDirection)
        wrapCache[from] = to

        let fromOpposite = DirectionalCoordinate(coordinate: fromCoordinate, direction: fromDirection.opposite)
        let toOpposite = DirectionalCoordinate(coordinate: toCoordinate, direction: toDirection.opposite)
        wrapCache[toOpposite] = fromOpposite
    }

    for i in 0..<side {
        let fromSideX = 1
        let fromSideY = 1
        let fromDirection = Direction.right
        let toSideX = 2
        let toSideY = 0
        let toDirection = Direction.up
        let fromCoordinate = Coordinate(
            x: fromSideX * side + (side - 1),
            y: fromSideY * side + i
        )
        let toCoordinate = Coordinate(
            x: toSideX * side + i,
            y: toSideY * side + (side - 1)
        )
        let from = DirectionalCoordinate(coordinate: fromCoordinate, direction: fromDirection)
        let to = DirectionalCoordinate(coordinate: toCoordinate, direction: toDirection)
        wrapCache[from] = to

        let fromOpposite = DirectionalCoordinate(coordinate: fromCoordinate, direction: fromDirection.opposite)
        let toOpposite = DirectionalCoordinate(coordinate: toCoordinate, direction: toDirection.opposite)
        wrapCache[toOpposite] = fromOpposite
    }

    for i in 0..<side {
        let fromSideX = 1
        let fromSideY = 2
        let fromDirection = Direction.right
        let toSideX = 2
        let toSideY = 0
        let toDirection = Direction.left
        let fromCoordinate = Coordinate(
            x: fromSideX * side + (side - 1),
            y: fromSideY * side + i
        )
        let toCoordinate = Coordinate(
            x: toSideX * side + (side - 1),
            y: toSideY * side + (side - 1) - i
        )
        let from = DirectionalCoordinate(coordinate: fromCoordinate, direction: fromDirection)
        let to = DirectionalCoordinate(coordinate: toCoordinate, direction: toDirection)
        wrapCache[from] = to

        let fromOpposite = DirectionalCoordinate(coordinate: fromCoordinate, direction: fromDirection.opposite)
        let toOpposite = DirectionalCoordinate(coordinate: toCoordinate, direction: toDirection.opposite)
        wrapCache[toOpposite] = fromOpposite
    }


    return wrapCache
}
