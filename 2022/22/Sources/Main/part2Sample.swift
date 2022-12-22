import Foundation

func sampleWrapCache() -> [DirectionalCoordinate : DirectionalCoordinate] {
    var wrapCache: [DirectionalCoordinate : DirectionalCoordinate] = [:]

    struct Edge {
        let sideX: Int
        let sideY: Int
        let direction: Direction
    }

    //    let aaaaaa: [(Edge, Edge)] = [
    //        (Edge(sideX: 2, sideY: 0, direction: .left), Edge(sideX: 1, sideY: 1, direction: .up)),
    //        (Edge(sideX: 2, sideY: 0, direction: .up), Edge(sideX: 0, sideY: 1, direction: .up)),
    //        (Edge(sideX: 2, sideY: 0, direction: .right), Edge(sideX: 3, sideY: 2, direction: .right))
    //        (Edge(sideX: 2, sideY: 1, direction: .right), Edge(sideX: 3, sideY: 2, direction: .up))
    //    ]

    let side = 4

    for i in 0..<side {
        let fromSideX = 1
        let fromSideY = 1
        let fromDirection = Direction.up
        let toSideX = 2
        let toSideY = 0
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
        let fromSideY = 1
        let fromDirection = Direction.up
        let toSideX = 2
        let toSideY = 0
        let toDirection = Direction.bottom
        let fromCoordinate = Coordinate(
            x: fromSideX * side + i,
            y: fromSideY * side
        )
        let toCoordinate = Coordinate(
            x: toSideX * side + (side - 1) - i,
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
        let fromSideX = 2
        let fromSideY = 1
        let fromDirection = Direction.right
        let toSideX = 3
        let toSideY = 2
        let toDirection = Direction.bottom
        let fromCoordinate = Coordinate(
            x: fromSideX * side + (side - 1),
            y: fromSideY * side + i
        )
        let toCoordinate = Coordinate(
            x: toSideX * side + (side - 1) - i,
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
        let fromSideX = 2
        let fromSideY = 0
        let fromDirection = Direction.right
        let toSideX = 3
        let toSideY = 2
        let toDirection = Direction.left
        let fromCoordinate = Coordinate(
            x: fromSideX * side + (side - 1),
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
        let fromSideX = 1
        let fromSideY = 1
        let fromDirection = Direction.bottom
        let toSideX = 2
        let toSideY = 2
        let toDirection = Direction.right
        let fromCoordinate = Coordinate(
            x: fromSideX * side + i,
            y: fromSideY * side + (side - 1)
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
        let fromSideY = 1
        let fromDirection = Direction.bottom
        let toSideX = 2
        let toSideY = 2
        let toDirection = Direction.up
        let fromCoordinate = Coordinate(
            x: fromSideX * side + i,
            y: fromSideY * side + (side - 1)
        )
        let toCoordinate = Coordinate(
            x: toSideX * side + (side - 1) - i,
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
        let fromSideX = 0
        let fromSideY = 1
        let fromDirection = Direction.left
        let toSideX = 3
        let toSideY = 2
        let toDirection = Direction.up
        let fromCoordinate = Coordinate(
            x: fromSideX * side,
            y: fromSideY * side + i
        )
        let toCoordinate = Coordinate(
            x: toSideX * side + (side - 1) - i,
            y: toSideY * side + (side - 1)
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
