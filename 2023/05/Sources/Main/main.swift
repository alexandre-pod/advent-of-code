import Foundation

struct Almanach {
    let wantedSeeds: [Int]
    let mappings: [Mapping]
}

struct Mapping {
    let source: String
    let destination: String
    let ranges: [Range]

    struct Range {
        let destinationStart: Int
        let sourceStart: Int
        let rangeLength: Int
    }
}

func main() {
    let input = parseAlmanach()

    print(part1(almanach: input))
    print(part2(almanach: input))
}

func parseAlmanach() -> Almanach {
    let seeds = readLine()!
        .split(separator: ":")[1]
        .trimmingCharacters(in: .whitespaces)
        .split(separator: " ")
        .map { Int($0)! }

    _ = readLine() // empty line

    var mappings: [Mapping] = []
    while let mapping = parseMapping() {
        mappings.append(mapping)
    }

    return Almanach(
        wantedSeeds: seeds,
        mappings: mappings
    )
}

func parseMapping() -> Mapping? {
    guard let mappingDefinition = readLine() else { return nil }
    let mappingTypes = mappingDefinition.split(separator: " ")[0].split(separator: "-")

    var ranges: [Mapping.Range] = []
    while let range = parseRange() {
        ranges.append(range)
    }

    return Mapping(
        source: String(mappingTypes[0]),
        destination: String(mappingTypes[2]),
        ranges: ranges.sorted { $0.sourceStart < $1.sourceStart }
    )
}

func parseRange() -> Mapping.Range? {
    guard let rangeString = readLine(), !rangeString.isEmpty else { return nil }

    let values = rangeString.split(separator: " ").map { Int($0)! }

    return Mapping.Range(
        destinationStart: values[0],
        sourceStart: values[1],
        rangeLength: values[2]
    )
}

// MARK: - Part 1

func part1(almanach: Almanach) -> Int {
    var values = almanach.wantedSeeds

    almanach.mappings.forEach { mapping in
        values = values.map { mapping.map(value: $0) }
    }
    return values.min() ?? Int.min
}

extension Mapping {
    func map(value: Int) -> Int {
        return ranges.lazy.compactMap { $0.map(value) }.first ?? value
    }
}

extension Mapping.Range {
    func map(_ value: Int) -> Int? {
        guard value >= sourceStart, value < sourceStart + rangeLength else { return nil }
        return destinationStart + value - sourceStart
    }
}

// MARK: - Part 2

func part2(almanach: Almanach) -> Int {
    var ranges = almanach.seedRanges

    almanach.mappings.forEach { mapping in
        ranges = ranges.flatMap { mapping.map(range: $0) }
    }

    return ranges.map(\.lowerBound).min()!
}

extension Almanach {
    var seedRanges: [Range<Int>] {
        assert(wantedSeeds.count % 2 == 0)
        var ranges: [Range<Int>] = []
        for i in wantedSeeds.indices where i % 2 == 0 {
            let start = wantedSeeds[i]
            let length = wantedSeeds[i + 1]
            ranges.append(start..<(start + length))
        }
        return ranges
    }
}

extension Mapping {
    func map(range: Swift.Range<Int>) -> [Swift.Range<Int>] {
        var mappedRanges: [Swift.Range<Int>] = []
        var remainingRange = range

        for range in ranges {
            guard let intersection = range.intersection(withSource: remainingRange) else { continue }

            if remainingRange.lowerBound < intersection.lowerBound {
                mappedRanges.append(remainingRange.lowerBound..<range.sourceStart)
            }

            mappedRanges.append(range.map(intersectionRange: intersection))
            remainingRange = intersection.upperBound..<remainingRange.upperBound
        }

        if !remainingRange.isEmpty {
            mappedRanges.append(remainingRange)
        }

        return mappedRanges
    }
}

extension Mapping.Range {
    func intersection(withSource range: Range<Int>) -> Range<Int>? {
        return range.intersection(with: sourceStart..<(sourceStart + rangeLength))
    }

    func map(intersectionRange range: Swift.Range<Int>) -> Swift.Range<Int> {
        assert(range.lowerBound >= sourceStart)
        assert(range.upperBound <= sourceStart + rangeLength)

        let start = destinationStart + range.lowerBound - sourceStart
        let end = start + range.count

        return start..<end
    }
}

extension Range {
    func intersection(with range: Self) -> Self? {
        guard overlaps(range) else { return nil }
        let lowerBound = Swift.max(self.lowerBound, range.lowerBound)
        let upperBound = Swift.min(self.upperBound, range.upperBound)
        return lowerBound..<upperBound
    }
}

main()
