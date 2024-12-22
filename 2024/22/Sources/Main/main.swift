import Foundation

typealias RandomNumberSeeds = [Int]

func main() {
    var input: RandomNumberSeeds = []

    while let line = readLine() {
        input.append(Int(line)!)
    }

    print(part1(randomNumberSeeds: input))
    print(part2(randomNumberSeeds: input))
}

// MARK: - Part 1

func part1(randomNumberSeeds: RandomNumberSeeds) -> Int {
//    var generator = PuzzleRandomNumberGenerator(secret: 123)
//    generator.prefix(10).forEach {
//        print($0)
//    }

    var result = 0

    for seed in randomNumberSeeds {
        var generator = PuzzleRandomNumberGenerator(secret: seed)
        for _ in 1...2000 {
            generator.generateNextSecretValue()
        }
//        print(seed, generator.secret)
        result += generator.secret
    }

    return result
}

struct PuzzleRandomNumberGenerator {
    var secret: Int

    @discardableResult
    mutating func generateNextSecretValue() -> Int {
        secret = (secret * 64) ^ secret
        secret = secret % 16777216

        secret = (secret / 32) ^ secret
        secret = secret % 16777216
        secret = (secret * 2048) ^ secret
        secret = secret % 16777216

//        secret = newSecret
        return secret
    }
}

extension PuzzleRandomNumberGenerator: Sequence, IteratorProtocol {
    mutating func next() -> Int? {
        defer { _ = generateNextSecretValue() }
        return secret
    }
}

// MARK: - Part 2

func part2(randomNumberSeeds: RandomNumberSeeds) -> Int {

    typealias Sequence = [Int]
    typealias SequenceToPrice = [Sequence: Int]

    var sequenceToPriceMaps: [SequenceToPrice] = []


    for seed in randomNumberSeeds {
        var sequenceToPriceMap: SequenceToPrice = [:]


        var generator = PuzzleRandomNumberGenerator(secret: seed)
        let allValues = [seed] + (1...2000).map { _ in generator.generateNextSecretValue() }

        // `distanceFromPrevious[i]` correspond to value `allValues[i+1]` because the first one has no previous value
        let distanceFromPrevious = zip(allValues.dropFirst(), allValues).map { ($0 % 10) - ($1 % 10) }

        assert(distanceFromPrevious.count == 2000)

        // `fourSequenceValues[i]` correspond to the sequence `distanceFromPrevious[i]` to `distanceFromPrevious[i+3]`
        // and should correspond to a price of `allValues[i+4]`
        let fourSequenceValues = zip(
            zip(
                distanceFromPrevious,
                distanceFromPrevious.dropFirst()
            ),
            zip(
                distanceFromPrevious.dropFirst(2),
                distanceFromPrevious.dropFirst(3)
            )
        )

        for (zipSequence, randomValue) in zip(fourSequenceValues, allValues.dropFirst(4)) {
            let sequence = [zipSequence.0.0, zipSequence.0.1, zipSequence.1.0, zipSequence.1.1]
            guard sequenceToPriceMap[sequence] == nil else { continue }
            let price = randomValue % 10
            sequenceToPriceMap[sequence] = price
        }

//        print(sequenceToPriceMap.keys.count)

        sequenceToPriceMaps.append(sequenceToPriceMap)
    }

    let allSeenSequences = sequenceToPriceMaps.map(\.keys).reduce(into: Set<Sequence>()) { partialResult, sequences in
        partialResult.formUnion(sequences)
    }

    print("sequences", allSeenSequences.count)

    var bestSequence: [Int] = [.max, .max, .max, .max]
    var bestPrice = Int.min

    for sequence in allSeenSequences {
        let sumPrice = sequenceToPriceMaps
            .map { $0[sequence, default: 0] }
            .reduce(0, +)
        if sumPrice > bestPrice {
            bestPrice = sumPrice
            bestSequence = sequence
//            print("current bestPrice", bestPrice)
//            print(sequenceToPriceMaps.map { $0[sequence, default: 0] })
        }
    }

    print("Best sequence:", bestSequence.map { String($0) }.joined(separator: ","))
    return bestPrice
}

main()
