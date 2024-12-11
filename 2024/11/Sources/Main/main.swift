import Foundation

typealias StoneNumbers = [Int]

func main() {
    let input: StoneNumbers = readLine()!.split(separator: " ").map { Int(String($0))! }
    print(part1(stoneNumbers: input))
    print(part2(stoneNumbers: input))
}

// MARK: - Part 1

func part1(stoneNumbers: StoneNumbers) -> Int {
//    print(stoneNumbers)

    var cache: [CacheKey: Int] = [:]
    let blinks = 25
    return stoneNumbers
        .map { stonesCount(from: $0, afterBlinks: blinks, cache: &cache) }
        .reduce(0, +)
}

func stonesCount(from stone: Int, afterBlinks blinks: Int, cache: inout [CacheKey: Int]) -> Int {
    guard blinks > 0 else { return 1 }
    let cacheKey = CacheKey(stone: stone, blinks: blinks)
    if let cachedValue = cache[cacheKey] {
        return cachedValue
    }
    let nextStones: [Int]

    if stone == 0 {
        nextStones = [1]
    } else {
        let stoneString = String(stone)
        if stoneString.count % 2 == 0 {
            let midIndex = stoneString.index(stoneString.startIndex, offsetBy: stoneString.count / 2)
            nextStones = [
                Int(String(stoneString[..<midIndex]))!,
                Int(String(stoneString[midIndex...]))!
            ]
        } else {
            nextStones = [2024 * stone]
        }
    }

    var result = nextStones
        .map { stonesCount(from: $0, afterBlinks: blinks - 1, cache: &cache) }
        .reduce(0, +)

    cache[cacheKey] = result
    return result
}

struct CacheKey: Hashable {
    let stone: Int
    let blinks: Int
}

// MARK: - Part 2

func part2(stoneNumbers: StoneNumbers) -> Int {
    var cache: [CacheKey: Int] = [:]
    let blinks = 75
    return stoneNumbers
        .map { stonesCount(from: $0, afterBlinks: blinks, cache: &cache) }
        .reduce(0, +)
}

main()
