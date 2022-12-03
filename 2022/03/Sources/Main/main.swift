import Foundation

typealias Item = Character

func main() {
    var ruckSacks: [RuckSack] = []

    while let line = readLine() {
        let count = line.count
        assert(count % 2 == 0)
        let ruckSack = RuckSack(
            leftCompartment: line.prefix(count / 2).map {$0},
            rightCompartment: line.suffix(count / 2).map {$0}
        )
        assert(ruckSack.leftCompartment.count == count / 2)
        assert(ruckSack.rightCompartment.count == count / 2)
        ruckSacks.append(ruckSack)
    }

    print(part1(ruckSacks: ruckSacks))
    print(part2(ruckSacks: ruckSacks))
}

struct RuckSack {
    let leftCompartment: [Item]
    let rightCompartment: [Item]

    var allItems: [Item] { leftCompartment + rightCompartment }
}

// MARK: - Part 1

func part1(ruckSacks: [RuckSack]) -> Int {
    return ruckSacks
        .map { findCommonItem(in: $0) }
        .reduce(0) { $0 + priority(forItem: $1) }
}

func findCommonItem(in ruckSack: RuckSack) -> Item {
    let left = Set(ruckSack.leftCompartment)
    let right = Set(ruckSack.rightCompartment)

    let intersection = left.intersection(right)
    assert(intersection.count == 1)
    return intersection.first!
}

func priority(forItem item: Item) -> Int {
    let ascii = Int(item.asciiValue!)
    switch ascii {
    case 97...122: // a - z
        return ascii - 96
    case 65...90: // A - Z
        return ascii - 64 + 26
    default:
        fatalError("Invalid character: \(item)")
    }
}

// MARK: - Part 2

func part2(ruckSacks: [RuckSack]) -> Int {
    return ruckStackGroups(from: ruckSacks, numberPerGroup: 3)
        .map { group in
            findCommonItem(in: group)!
        }
        .reduce(0) { $0 + priority(forItem: $1) }
}

func ruckStackGroups(from ruckSacks: [RuckSack], numberPerGroup: Int) -> [[RuckSack]] {
    var remainingRuckStacks = ruckSacks

    var result: [[RuckSack]] = []

    assert(remainingRuckStacks.count % numberPerGroup == 0)

    while remainingRuckStacks.count > 0 {
        result.append(Array(remainingRuckStacks[...2]))
        remainingRuckStacks = Array(remainingRuckStacks.dropFirst(numberPerGroup))
    }

    return result
}

func findCommonItem(in ruckSacks: [RuckSack]) -> Item? {
    var itemToSackMap: [Item: Set<Int>] = [:]

    for (index, ruckSack) in zip(ruckSacks.indices, ruckSacks) {
        ruckSack.allItems.forEach { item in
            itemToSackMap[item, default: []].insert(index)
        }
    }

    return itemToSackMap.first { (item, ruckSacksIndex) in
        ruckSacksIndex.count == 3
    }?.key
}

main()
