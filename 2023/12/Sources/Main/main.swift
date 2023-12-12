import Foundation

typealias Rows = [Row]

struct Row {
    let records: [Record]
    let damagedGroups: [Int]
}

enum Record: Character, Equatable {
    case unknown = "?"
    case operational = "."
    case damaged = "#"
}

func main() {
    var input: Rows = []

    while let line = readLine() {
        input.append(parseRow(from: line))
    }

    print(part1(rows: input))
    print(part2(rows: input))
}

func parseRow(from string: String) -> Row {

    let parts = string.split(separator: " ")

    return Row(
        records: parts[0].map { Record(rawValue: $0)! },
        damagedGroups: parts[1].split(separator: ",").map { Int(String($0))! }
    )
}

// MARK: - Part 1

func part1(rows: Rows) -> Int {
//    rows.forEach {
//        print("\(String($0.records.debugString)) | \($0.damagedGroups) - \(findPossibleCombination(for: $0))")
//    }
    return rows.map { findPossibleCombination(for: $0) }.reduce(0, +)
}

func findPossibleCombination(for row: Row) -> Int {
    var cache: [CacheKey: Int] = [:]
    return findPossibleCombination(records: row.records, damagedGroups: row.damagedGroups, cache: &cache)
}

struct CacheKey: Hashable {
    let records: [Record]
    let damagedGroups: [Int]
    let currentGroupSize: Int
}

private func findPossibleCombination(
    records: some Collection<Record>,
    damagedGroups: [Int],
    currentGroupSize: Int = 0,
    repairedRecords: [Record] = [],
    cache: inout [CacheKey: Int]
) -> Int {

    let cacheKey = CacheKey(records: Array(records), damagedGroups: damagedGroups, currentGroupSize: currentGroupSize)
    if let cachedValue = cache[cacheKey] {
        return cachedValue
    }

    guard let nextDamagedGroup = damagedGroups.first else {
        if currentGroupSize > 0 {
            cache[cacheKey] = 0
            return 0
        }
        let canAllRecordsBeOperational = records.allSatisfy { $0 != .damaged }
        guard canAllRecordsBeOperational else { return 0 }
//        print("-", repairedRecords.debugString)
        cache[cacheKey] = 1
        return 1
    }

    guard currentGroupSize <= nextDamagedGroup else {
        cache[cacheKey] = 0
        return 0
    }

    guard let firstRecord = records.first else {
        let lastGroupFulfilled = damagedGroups.count == 1 && nextDamagedGroup == currentGroupSize
        guard lastGroupFulfilled else { return 0 }
//        print("-", repairedRecords.debugString)
        cache[cacheKey] = 1
        return 1
    }

    let asDamagedCount: Int
    let asOperationalCount: Int

    if firstRecord != .operational {
        asDamagedCount = findPossibleCombination(
            records: records.dropFirst(1),
            damagedGroups: damagedGroups,
            currentGroupSize: currentGroupSize + 1,
            repairedRecords: [],
//            repairedRecords: repairedRecords + [.damaged],
            cache: &cache
        )
    } else {
        asDamagedCount = 0
    }

    if firstRecord != .damaged {
        var remainingDamagedGroups = damagedGroups
        if currentGroupSize == 0 {
            asOperationalCount = findPossibleCombination(
                records: records.dropFirst(1),
                damagedGroups: remainingDamagedGroups,
                currentGroupSize: 0,
                repairedRecords: [],
//                repairedRecords: repairedRecords + [.operational],
                cache: &cache
            )
        } else {
            if currentGroupSize == nextDamagedGroup {
                remainingDamagedGroups.removeFirst()
                asOperationalCount = findPossibleCombination(
                    records: records.dropFirst(1),
                    damagedGroups: remainingDamagedGroups,
                    currentGroupSize: 0,
                    repairedRecords: [],
//                    repairedRecords: repairedRecords + [.operational],
                    cache: &cache
                )
            } else {
                asOperationalCount = 0
            }
        }
    } else {
        asOperationalCount = 0
    }

    cache[cacheKey] = asDamagedCount + asOperationalCount

    return asDamagedCount + asOperationalCount
}

// MARK: - Part 2

func part2(rows: Rows) -> Int {
//    let unfoldedRows = rows.map(\.unfolded)
//    var result = 0
//    for (offset, row) in unfoldedRows.enumerated() {
//        print("\(offset + 1) / \(unfoldedRows.count)")
//        result += findPossibleCombination(for: row)
//    }
//    return result
    return rows.map(\.unfolded).map { findPossibleCombination(for: $0) }.reduce(0, +)
}

extension Row {
    var unfolded: Self {
        return Row(
            records: Array(repeating: records, count: 5).joined(separator: [.unknown]).map { $0 },
            damagedGroups: Array(repeating: damagedGroups, count: 5).flatMap { $0 }
        )
    }
}

// MARK: - Visualisation

extension [Record] {
    var debugString: String {
        String(map(\.rawValue))
    }
}

extension Record: CustomStringConvertible {
    var description: String { String(rawValue) }
}

main()
