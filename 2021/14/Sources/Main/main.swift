import Foundation

// MARK: - Main

func main() {

    let polymer = readLine()!.map { $0 }
    _ = readLine() // empty line

    var pairInsertion: [String: Character] = [:]

    while let line = readLine() {
        let components = line.split(separator: " ")
        pairInsertion[String(components[0])] = components[2].first!
    }

    print(part1(polymer: polymer, pairInsertion: pairInsertion))
    print(part2(polymer: polymer, pairInsertion: pairInsertion))
}

// MARK: - Part 1

func part1(polymer: [Character], pairInsertion: [String: Character]) -> Int {
    var polymer = polymer

    for _ in 1...10 {
        polymer = step(polymer: polymer, pairInsertion: pairInsertion)
    }

    var characterCount: [Character: Int] = [:]

    polymer.forEach {
        characterCount[$0, default: 0] += 1
    }

    let maxCount = characterCount.values.max()!
    let minCount = characterCount.values.min()!

    return maxCount - minCount
}

func step(polymer: [Character], pairInsertion: [String: Character]) -> [Character] {
    return zip(polymer, polymer.dropFirst())
        .flatMap { left, right -> [Character] in
            let pair = String(left) + String(right)
            let insertion = pairInsertion[pair]!
            return [left, insertion]
        } + [polymer.last!]
}

// MARK: - Part 2

func part2(polymer: [Character], pairInsertion: [String: Character]) -> Int {
    let characterCount = cachedCharacterCount(polymer: polymer, pairInsertion: pairInsertion, steps: 40)

    let maxCount = characterCount.values.max()!
    let minCount = characterCount.values.min()!

    return maxCount - minCount
}

func cachedCharacterCount(polymer: [Character], pairInsertion: [String: Character], steps: Int) -> [Character: Int] {
    return zip(polymer, polymer.dropFirst())
        .enumerated()
        .reduce(into: [Character: Int]()) { result, elements in
            let count = cachedCharacterCount(
                between: elements.element.0,
                and: elements.element.1,
                pairInsertion: pairInsertion,
                steps: steps
            )
            result.merge(count, uniquingKeysWith: +)
            if elements.offset > 0 {
                result[elements.element.0, default: 0] -= 1
            }
        }
}

struct CacheKey: Hashable {
    let left: Character
    let right: Character
    let depth: Int
}

var cacheCount: [CacheKey: [Character: Int]] = [:]

func cachedCharacterCount(between left: Character,
                    and right: Character,
                    pairInsertion: [String: Character],
                    steps: Int) -> [Character: Int] {

    var result: [Character: Int] = [:]

    guard steps > 0 else {
        result[left, default: 0] += 1
        result[right, default: 0] += 1
        return result
    }

    let cacheKey = CacheKey(left: left, right: right, depth: steps)

    if let result = cacheCount[cacheKey] {
        return result
    }

    let middle = pairInsertion[String(left) + String(right)]!

    let leftPart = cachedCharacterCount(
        between: left,
        and: middle,
        pairInsertion: pairInsertion,
        steps: steps - 1
    )

    let rightPart = cachedCharacterCount(
        between: middle,
        and: right,
        pairInsertion: pairInsertion,
        steps: steps - 1
    )

    result = leftPart.merging(rightPart, uniquingKeysWith: +)
    result[middle, default: 0] -= 1
    cacheCount[cacheKey] = result
    return result
}

main()
