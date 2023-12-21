import Foundation

struct GardenMap {
    let start: Coordinates
    let rockTiles: [[Bool]]
}

func main() {

    var start: Coordinates = Coordinates(x: .min, y: .min)
    var rockTiles: [[Bool]] = []

    var y = 0
    while let line = readLine() {
        rockTiles.append(line.map { $0 == "#" })
        if let startX = line.map({ $0 }).firstIndex(of: "S") {
            start = Coordinates(x: startX, y: y)
        }
        y += 1
    }

    let input = GardenMap(start: start, rockTiles: rockTiles)

    print(part1(gardenMap: input))
    print(part2(gardenMap: input))
}

// MARK: - Part 1

func part1(gardenMap: GardenMap, distance: Int = 64) -> Int {
    var possiblePositions: Set<Coordinates> = [gardenMap.start]
    var distanceTravelled = 0

//    while distanceTravelled < 6 {
    while distanceTravelled < distance {
        let startPositions = possiblePositions

        possiblePositions = Set(startPositions.flatMap { $0.accessibleNeighbors(in: gardenMap.rockTiles) })
        distanceTravelled += 1

//        print("distance: \(distanceTravelled) -> possible tiles:", possiblePositions.count)
    }

    return possiblePositions.count
}

extension Coordinates {
    func accessibleNeighbors(in rockMap: [[Bool]]) -> [Coordinates] {
        let coordinates = (-1...1).flatMap { dy in
            (-1...1)
                .filter { abs(dy) + abs($0) == 1 }
                .map { dx in Coordinates(x: x + dx, y: y + dy) }
        }
        return coordinates
            .filter { rockMap.indices.contains($0.y) && rockMap[$0.y].indices.contains($0.x) }
            .filter { !rockMap[$0] }
    }
}


// MARK: - Part 2

func part2(gardenMap: GardenMap) -> Int {
    // 618460789348987 - too low
    // 620357841610265 - too high
    // 620351698366165 - too high
    // 620348631910321 - valid
    return part2UsingCycles(gardenMap: gardenMap)
//    return part2AfterAnalysis(gardenMap: gardenMap)
//    return part2Visualisation(gardenMap: gardenMap)
//    return part2Computed(gardenMap: gardenMap)
}

// MARK: - Part 2 - try 3 - Successful try

func part2UsingCycles(gardenMap: GardenMap) -> Int {
    let totalDistance = 26501365
    let height = gardenMap.rockTiles.count
    let width = gardenMap.rockTiles[0].count

    print("height", height)
    print("width", width)

    assert(height == width)

    let totalCycles = totalDistance / (2 * width)
    let cycleOffset = totalDistance % (2 * width)

    print("totalDistance / 2 * width", totalCycles)
    print("totalDistance % 2 * width", cycleOffset)

    print("test length: ", cycleOffset + totalCycles * 2 * width)
    print("=============", totalDistance)

    var positions = [RepeatingCoordinates(coordinates: gardenMap.start, chunks: [Coordinates(x: 0, y: 0)])]

    positions = possiblePositions(from: positions, in: gardenMap.rockTiles, distance: cycleOffset)

    displayPositionsPerChunk(with: positions)

    positions = possiblePositions(from: positions, in: gardenMap.rockTiles, distance: 2 * width)
    displayPositionsPerChunk(with: positions)

    positions = possiblePositions(from: positions, in: gardenMap.rockTiles, distance: 2 * width)
    displayPositionsPerChunk(with: positions)

    positions = possiblePositions(from: positions, in: gardenMap.rockTiles, distance: 2 * width)
    displayPositionsPerChunk(with: positions)

    /*
     input

     3821

     0000 0970 5685 0976 0000
     0970 6623 7602 6618 0976
     5705 7602 7556 7602 5672
     0973 6638 7602 6610 0959
     0000 0973 5692 0959 0000

     0000 0000 0000 0970 5685 0976 0000 0000 0000
     0000 0000 0970 6623 7602 6618 0976 0000 0000
     0000 0970 6623 7602 7556 7602 6618 0976 0000
     0970 6623 7602 7556 7602 7556 7602 6618 0976
     5705 7602 7556 7602 7556 7602 7556 7602 5672
     0973 6638 7602 7556 7602 7556 7602 6610 0959
     0000 0973 6638 7602 7556 7602 6610 0959 0000
     0000 0000 0973 6638 7602 6610 0959 0000 0000
     0000 0000 0000 0973 5692 0959 0000 0000 0000

     0000 0000 0000 0000 0000 0970 5685 0976 0000 0000 0000 0000 0000
     0000 0000 0000 0000 0970 6623 7602 6618 0976 0000 0000 0000 0000
     0000 0000 0000 0970 6623 7602 7556 7602 6618 0976 0000 0000 0000
     0000 0000 0970 6623 7602 7556 7602 7556 7602 6618 0976 0000 0000
     0000 0970 6623 7602 7556 7602 7556 7602 7556 7602 6618 0976 0000
     0970 6623 7602 7556 7602 7556 7602 7556 7602 7556 7602 6618 0976
     5705 7602 7556 7602 7556 7602 7556 7602 7556 7602 7556 7602 5672
     0973 6638 7602 7556 7602 7556 7602 7556 7602 7556 7602 6610 0959
     0000 0973 6638 7602 7556 7602 7556 7602 7556 7602 6610 0959 0000
     0000 0000 0973 6638 7602 7556 7602 7556 7602 6610 0959 0000 0000
     0000 0000 0000 0973 6638 7602 7556 7602 6610 0959 0000 0000 0000
     0000 0000 0000 0000 0973 6638 7602 6610 0959 0000 0000 0000 0000
     0000 0000 0000 0000 0000 0973 5692 0959 0000 0000 0000 0000 0000
    */
    /*
     sample

     0000 0005 0000
     0010 0035 0006
     0000 0007 0000

     0000 0000 0000 0002 0000 0000 0000
     0000 0000 0018 0034 0024 0000 0000
     0000 0018 0039 0042 0039 0024 0000
     0002 0032 0042 0039 0042 0031 0001
     0000 0021 0039 0042 0037 0012 0000
     0000 0000 0021 0030 0012 0000 0000
     0000 0000 0000 0001 0000 0000 0000

     0000 0000 0000 0000 0000 0002 0000 0000 0000 0000 0000
     0000 0000 0000 0000 0018 0034 0024 0000 0000 0000 0000
     0000 0000 0000 0018 0039 0042 0039 0024 0000 0000 0000
     0000 0000 0018 0039 0042 0039 0042 0039 0024 0000 0000
     0000 0018 0039 0042 0039 0042 0039 0042 0039 0024 0000
     0002 0031 0042 0039 0042 0039 0042 0039 0042 0028 0001
     0000 0021 0039 0042 0039 0042 0039 0042 0037 0012 0000
     0000 0000 0021 0039 0042 0039 0042 0037 0012 0000 0000
     0000 0000 0000 0021 0039 0042 0037 0012 0000 0000 0000
     0000 0000 0000 0000 0021 0030 0012 0000 0000 0000 0000
     0000 0000 0000 0000 0000 0001 0000 0000 0000 0000 0000

     0000 0000 0000 0000 0000 0000 0000 0002 0000 0000 0000 0000 0000 0000 0000
     0000 0000 0000 0000 0000 0000 0018 0034 0024 0000 0000 0000 0000 0000 0000
     0000 0000 0000 0000 0000 0018 0039 0042 0039 0024 0000 0000 0000 0000 0000
     0000 0000 0000 0000 0018 0039 0042 0039 0042 0039 0024 0000 0000 0000 0000
     0000 0000 0000 0018 0039 0042 0039 0042 0039 0042 0039 0024 0000 0000 0000
     0000 0000 0018 0039 0042 0039 0042 0039 0042 0039 0042 0039 0024 0000 0000
     0000 0018 0039 0042 0039 0042 0039 0042 0039 0042 0039 0042 0039 0024 0000
     0002 0031 0042 0039 0042 0039 0042 0039 0042 0039 0042 0039 0042 0028 0001
     0000 0021 0039 0042 0039 0042 0039 0042 0039 0042 0039 0042 0037 0012 0000
     0000 0000 0021 0039 0042 0039 0042 0039 0042 0039 0042 0037 0012 0000 0000
     0000 0000 0000 0021 0039 0042 0039 0042 0039 0042 0037 0012 0000 0000 0000
     0000 0000 0000 0000 0021 0039 0042 0039 0042 0037 0012 0000 0000 0000 0000
     0000 0000 0000 0000 0000 0021 0039 0042 0037 0012 0000 0000 0000 0000 0000
     0000 0000 0000 0000 0000 0000 0021 0030 0012 0000 0000 0000 0000 0000 0000
     0000 0000 0000 0000 0000 0000 0000 0001 0000 0000 0000 0000 0000 0000 0000

     */

    // input - sample

    let withOffsetChunkWidth = 1

    let finalChunkWidth = withOffsetChunkWidth + totalCycles * 4

    // Vertex
    let vertexesPositions = 5685 + 5672 + 5692 + 5705

    // diagonals
//    let externalDiagonalCounts = totalCycles * 2
    let externalDiagonalCounts = (finalChunkWidth - 1) / 2
    let internalDiagonalCounts = externalDiagonalCounts - 1

    let externalDiagonals = [0976, 0959, 0973, 0970]
    let internalDiagonals = [6618, 6610, 6638, 6623]

    let externalDiagonalsPositions = externalDiagonals.map { $0 * externalDiagonalCounts }.reduce(0, +)
    let internalDiagonalsPositions = internalDiagonals.map { $0 * internalDiagonalCounts }.reduce(0, +)

    // interior

    var centerInteriorCount = 0
    var offsetInteriorCount = 0

    var remainingWidth = finalChunkWidth - 2

    offsetInteriorCount = 1 + (remainingWidth - 1) / 2
    centerInteriorCount = (remainingWidth - 1) / 2

    remainingWidth -= 2

    while remainingWidth > 0 {
        remainingWidth -= 1
        offsetInteriorCount += 2
        assert(remainingWidth % 2 == 0)

        offsetInteriorCount += remainingWidth // (remainingWidth / 2) * 2
        centerInteriorCount += remainingWidth // (remainingWidth / 2) * 2

        remainingWidth -= 1
    }

    let centerChunkPositions = 7556
    let offsetChunkPositions = 7602

    return vertexesPositions 
    + externalDiagonalsPositions
    + internalDiagonalsPositions
    + centerInteriorCount * centerChunkPositions
    + offsetInteriorCount * offsetChunkPositions
}

func displayPositionsPerChunk(with positions: [RepeatingCoordinates]) {

    var chunkCounts: [Coordinates: Int] = [:]

    positions.forEach { repeatingPosition in
        repeatingPosition.chunks.forEach {
            chunkCounts[$0, default: 0] += 1
        }
    }

    let minChunkX = chunkCounts.keys.map(\.x).min()!
    let maxChunkX = chunkCounts.keys.map(\.x).max()!
    let minChunkY = chunkCounts.keys.map(\.y).min()!
    let maxChunkY = chunkCounts.keys.map(\.y).max()!

    let numberFormatter = NumberFormatter()
    numberFormatter.minimumIntegerDigits = 4
    numberFormatter.maximumIntegerDigits = 4

    for y in minChunkY...maxChunkY {
        for x in minChunkX...maxChunkX {
            let count = chunkCounts[Coordinates(x: x, y: y)] ?? 0
            print(numberFormatter.string(from: count as NSNumber)! + " ", terminator: "")
        }
        print()
    }

    print()
}

func possiblePositions(from positions: [RepeatingCoordinates], in rockTiles: [[Bool]], distance: Int) -> [RepeatingCoordinates] {
    var possiblePositions: [Coordinates: RepeatingCoordinates] = [:]
    positions.forEach {
        assert(possiblePositions[$0.coordinates] == nil)
        possiblePositions[$0.coordinates] = $0
    }
    var distanceTravelled = 0

    while distanceTravelled < distance {

        let startPositions = possiblePositions

        possiblePositions.removeAll(keepingCapacity: false)

        startPositions.values
            .flatMap { $0.accessibleNeighbors(in: rockTiles) }
            .filter { !$0.chunks.isEmpty }
            .forEach {
                possiblePositions[$0.coordinates, default: $0].merge(with: $0)
            }
        distanceTravelled += 1
    }

    return Array(possiblePositions.values)
}

// MARK: - Part 2 - try 2 - failed analysis of input

// Not working - invalid hypothesis of even grid size...
//    func part2AfterAnalysis(gardenMap: GardenMap) -> Int {
//
//        let height = gardenMap.rockTiles.count
//        let width = gardenMap.rockTiles[0].count
//
//        print("height", height)
//        print("width", width)
//
//    //    let distanceToTravel = 26501365
//
//        // Full chunks
//        let fullCount = part1(gardenMap: gardenMap, distance: 65 + 64)
//        print("When full:", fullCount)
//
//        let fullChunksToRight = (distanceToTravel - (65 + 64)) / width
//
//        let fullChunkHorizontalLineCount = 1 + 2 * fullChunksToRight
//
//        var fullChunks = fullChunkHorizontalLineCount
//        var remainingLine = fullChunkHorizontalLineCount - 2
//        while remainingLine > 0 {
//            fullChunks += 2 * remainingLine
//            remainingLine -= 2
//        }
//
//        let fullChunksPositions = fullCount * fullChunks
//
//        // Diagonals
//
//        let diagonalCounts = fullChunksToRight
//
//        let remainingDiagonalDistance = (distanceToTravel - (65 + 64)) % width
//
//        let startFromBottomLeft = part1(
//            gardenMap: GardenMap(start: Coordinates(x: 0, y: height - 1), rockTiles: gardenMap.rockTiles),
//            distance: remainingDiagonalDistance
//        )
//        let startFromBottomRight = part1(
//            gardenMap: GardenMap(start: Coordinates(x: width - 1, y: height - 1), rockTiles: gardenMap.rockTiles),
//            distance: remainingDiagonalDistance
//        )
//        let startFromTopLeft = part1(
//            gardenMap: GardenMap(start: Coordinates(x: 0, y: 0), rockTiles: gardenMap.rockTiles),
//            distance: remainingDiagonalDistance
//        )
//        let startFromTopRight = part1(
//            gardenMap: GardenMap(start: Coordinates(x: width - 1, y: 0), rockTiles: gardenMap.rockTiles),
//            distance: remainingDiagonalDistance
//        )
//
//        let diagonalChunksPositions = diagonalCounts * (
//            startFromBottomLeft + startFromBottomRight + startFromTopLeft + startFromTopRight
//        )
//
//        // Vertexes
//
//        let remainingLinearDistance = (distanceToTravel - 65) % width
//
//        let startFromLeft = part1(
//            gardenMap: GardenMap(start: Coordinates(x: width + 1, y: height / 2), rockTiles: gardenMap.rockTiles),
//            distance: remainingLinearDistance + 1 // +1 for initial propagation
//        )
//        let startFromRight = part1(
//            gardenMap: GardenMap(start: Coordinates(x: -1, y: height / 2), rockTiles: gardenMap.rockTiles),
//            distance: remainingLinearDistance + 1 // +1 for initial propagation
//        )
//        let startFromTop = part1(
//            gardenMap: GardenMap(start: Coordinates(x: width / 2, y: -1), rockTiles: gardenMap.rockTiles),
//            distance: remainingLinearDistance + 1 // +1 for initial propagation
//        )
//        let startFromBottom = part1(
//            gardenMap: GardenMap(start: Coordinates(x: width / 2, y: height + 1), rockTiles: gardenMap.rockTiles),
//            distance: remainingLinearDistance + 1 // +1 for initial propagation
//        )
//
//        let finalResult = fullChunksPositions + diagonalChunksPositions + startFromTop + startFromRight + startFromBottom + startFromLeft
//
//        return finalResult
//    }

func part2Visualisation(gardenMap: GardenMap) -> Int {
    var possiblePositions: [Coordinates: RepeatingCoordinates] = [
        gardenMap.start: RepeatingCoordinates(
            coordinates: gardenMap.start,
            chunks: [gardenMap.start.chunkCoordinates(in: gardenMap.rockTiles)]
        )
    ]
    var distanceTravelled = 0

    let rockCount = gardenMap.rockTiles.map { $0.filter { $0 }.count }.reduce(0, +)
    let accessibleTilesCount = gardenMap.rockTiles.count * gardenMap.rockTiles[0].count - rockCount

    print("Full when \(accessibleTilesCount)")

    let chunkRenderRadius = 0

    let height = gardenMap.rockTiles.count
    let width = gardenMap.rockTiles[0].count

    while distanceTravelled < 26501365 {

        if (26501365 - distanceTravelled) % 2 == 0 {
            var buffer = DisplayBuffer()
            for dx in -chunkRenderRadius...chunkRenderRadius {
                for dy in -chunkRenderRadius...chunkRenderRadius {
                    buffer.renderMap(gardenMap.rockTiles, chunkOffset: Coordinates(x: dx, y: dy))
                }
            }

            possiblePositions.values.forEach { repeatingCoordinates in
                repeatingCoordinates.chunks
                    .filter { abs($0.x) <= chunkRenderRadius && abs($0.y) <= chunkRenderRadius }
                    .forEach {
                        buffer.pixels[Coordinates(
                            x: $0.x * width + repeatingCoordinates.coordinates.x,
                            y: $0.y * height + repeatingCoordinates.coordinates.y
                        )] = "▒"
                    }
            }

            buffer.print()

            print()

            Thread.sleep(forTimeInterval: 0.1)
        }

        let startPositions = possiblePositions

        possiblePositions.removeAll(keepingCapacity: false)

        startPositions.values
            .flatMap { $0.accessibleNeighbors(in: gardenMap.rockTiles) }
            .filter { !$0.chunks.isEmpty }
            .forEach {
                possiblePositions[$0.coordinates, default: $0].merge(with: $0)
            }
        distanceTravelled += 1
    }

    return possiblePositions.values.map(\.chunks.count).reduce(0, +)
}

extension DisplayBuffer {
    mutating func renderMap(_ rockMap: [[Bool]], chunkOffset: Coordinates) {
        let height = rockMap.count
        let width = rockMap[0].count

        let dx = chunkOffset.x * width
        let dy = chunkOffset.y * height

        for y in rockMap.indices {
            for x in rockMap[y].indices {
                pixels[Coordinates(x: x + dx, y: y + dy)] = rockMap[y][x] ? "█" : " "
            }
        }
    }
}

// MARK: - Part 2 - try 1 - too expensive - try optimizing execution

func part2Computed(gardenMap: GardenMap) -> Int {
    var possiblePositions: [Coordinates: RepeatingCoordinates] = [
        gardenMap.start: RepeatingCoordinates(
            coordinates: gardenMap.start,
            chunks: [gardenMap.start.chunkCoordinates(in: gardenMap.rockTiles)]
        )
    ]
    var distanceTravelled = 0

    let rockCount = gardenMap.rockTiles.map { $0.filter { $0 }.count }.reduce(0, +)
    let accessibleTilesCount = gardenMap.rockTiles.count * gardenMap.rockTiles[0].count - rockCount

    print("Full when \(accessibleTilesCount)")

    var fullChunks: Set<Coordinates> = []
    var fullChunkCandidates: Set<Coordinates> = []

    while distanceTravelled < 26501365 {
        let startPositions = possiblePositions

        possiblePositions.removeAll(keepingCapacity: false)

        startPositions.values
            .flatMap { $0.accessibleNeighbors(in: gardenMap.rockTiles) }
            .map {
                RepeatingCoordinates(
                    coordinates: $0.coordinates,
                    chunks: $0.chunks.filter { !fullChunks.contains($0) }
                )
            }
            .filter { !$0.chunks.isEmpty }
            .forEach { possiblePositions[$0.coordinates, default: $0].merge(with: $0) }

        if possiblePositions.count == accessibleTilesCount {
            let chunks = possiblePositions
                .values
                .lazy
                .map(\.chunks)
            let stepFullChunks = chunks.reduce(into: chunks.first!) { partialResult, aaaa in
                partialResult.formIntersection(aaaa)
            }

            let zeroChunkCount = chunks.filter { $0.contains(Coordinates(x: 0, y: 0)) }.count

            let newFull = stepFullChunks.intersection(fullChunkCandidates)
            fullChunkCandidates = stepFullChunks

            newFull.forEach { fullChunks.insert($0) }
        }

        distanceTravelled += 1

        if distanceTravelled % 100 == 0 {
            let possibleCount = possiblePositions.values.map(\.chunks.count).reduce(0, +)

            let fullChunkCounts = fullChunks.count * accessibleTilesCount

            print("possiblePosition keys count", possiblePositions.count)
            print("set avg size", possibleCount / possiblePositions.count)
            print("full chunks count:", fullChunks.count)

            print("distance: \(distanceTravelled) -> possible tiles:", possibleCount + fullChunkCounts)
        }
    }

    return possiblePositions.values.map(\.chunks.count).reduce(0, +)
}

extension RepeatingCoordinates {
    mutating func merge(with other: Self) {
        assert(coordinates == other.coordinates)
        self.chunks.formUnion(other.chunks)
    }
}

struct RepeatingCoordinates: Hashable {
    let coordinates: Coordinates
    var chunks: Set<Coordinates>
}

extension RepeatingCoordinates {
    func accessibleNeighbors(in rockMap: [[Bool]]) -> [RepeatingCoordinates] {

        var result: [RepeatingCoordinates] = []


        for dy in -1...1 {
            for dx in -1...1 where abs(dy) + abs(dx) == 1 {
                let target = Coordinates(x: coordinates.x + dx, y: coordinates.y + dy)

                if target.isIn(rockMap) {
                    guard !rockMap[target] else { continue }
                    result.append(RepeatingCoordinates(coordinates: target, chunks: chunks))
                } else {
                    let normalizedTarget = Coordinates(x: coordinates.x + dx, y: coordinates.y + dy).normalized(in: rockMap)
                    let chunkDelta = target.chunkCoordinates(in: rockMap)
                    result.append(RepeatingCoordinates(
                        coordinates: normalizedTarget,
                        chunks: Set(chunks.map { Coordinates(x: $0.x + chunkDelta.x, y: $0.y + chunkDelta.y) })
                    ))
                }
            }
        }

        return result
    }
}

extension Coordinates {
    func isIn(_ rockMap: [[Bool]]) -> Bool {
        rockMap.indices.contains(y) && rockMap[y].indices.contains(x)
    }

    func accessibleNeighbors(inInfiniteMap rockMap: [[Bool]]) -> [Coordinates] {
        let coordinates = (-1...1).flatMap { dy in
            (-1...1)
                .filter { abs(dy) + abs($0) == 1 }
                .map { dx in Coordinates(x: x + dx, y: y + dy) }
        }
        return coordinates.filter { !rockMap[infinite: $0] }
    }

    func normalized(in rockMap: [[Bool]]) -> Coordinates {
        let height = rockMap.count
        let normalizedY = (height + (y % height)) % height
        let width = rockMap[normalizedY].count
        let normalizedX = (width + (x % width)) % width
        return Coordinates(x: normalizedX, y: normalizedY)
    }

    func chunkCoordinates(in rockMap: [[Bool]]) -> Coordinates {
        let height = Double(rockMap.count)
        let chunkY = Int((Double(y) / height).rounded(.down))
        let width = Double(rockMap[0].count)
        let chunkX = Int((Double(x) / width).rounded(.down))
        return Coordinates(x: chunkX, y: chunkY)
    }
}

extension [[Bool]] {
    subscript(infinite coordinates: Coordinates) -> Bool {
        self[coordinates.normalized(in: self)]
    }
}

main()
