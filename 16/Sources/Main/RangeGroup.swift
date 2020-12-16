import Foundation

struct RangeGroup {
    private var mergedRanges: [ClosedRange<Int>] = []

    func contains(_ value: Int) -> Bool {
        return mergedRanges.contains { $0.contains(value) }
    }

    mutating func addRange(_ range: ClosedRange<Int>) {
        guard !mergedRanges.isEmpty else {
            mergedRanges.append(range)
            return
        }
        let insertionIndex = mergedRanges.firstIndex { $0.lowerBound > range.lowerBound } ?? mergedRanges.count

        let previousIndex = insertionIndex - 1
        let nextIndex = insertionIndex + 1

        let canMergeWithPrevious = mergedRanges.indices.contains(previousIndex)
            && mergedRanges[previousIndex].upperBound >= range.lowerBound - 1
        let canMergeWithNext = mergedRanges.indices.contains(nextIndex)
            && mergedRanges[nextIndex].lowerBound <= range.upperBound + 1

        if canMergeWithPrevious && canMergeWithNext {
            let nextRange = mergedRanges.remove(at: nextIndex)
            mergedRanges[previousIndex] = mergedRanges[previousIndex].lowerBound...nextRange.upperBound

        } else if canMergeWithPrevious {
            mergedRanges[previousIndex] = mergedRanges[previousIndex].lowerBound...range.upperBound
        } else if canMergeWithNext {
            mergedRanges[nextIndex] = range.lowerBound...mergedRanges[nextIndex].upperBound
        } else {
            mergedRanges.insert(range, at: insertionIndex)
        }
    }
}
