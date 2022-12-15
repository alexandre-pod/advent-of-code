import Foundation

struct RangeGroup: Equatable {
    private var mergedRanges: [ClosedRange<Int>] = []

    var ranges: [ClosedRange<Int>] { mergedRanges }

    func contains(_ value: Int) -> Bool {
        return mergedRanges.contains { $0.contains(value) }
    }

    func addingRange(_ range: ClosedRange<Int>) -> RangeGroup {
        var copy = self
        copy.addRange(range)
        return copy
    }

    mutating func addRange(_ range: ClosedRange<Int>) {
//        print("Adding to \(self)")
//        print("Adding \(range)")

        var newRanges: [ClosedRange<Int>] = []

        var currentRangeIndex = 0

        while
            mergedRanges.indices.contains(currentRangeIndex),
            mergedRanges[currentRangeIndex].upperBound < range.lowerBound - 1
        {
            newRanges.append(mergedRanges[currentRangeIndex])
            currentRangeIndex += 1
        }

        guard mergedRanges.indices.contains(currentRangeIndex) else {
            newRanges.append(range)
            self.mergedRanges = newRanges
            return
        }

        let lowerBound = min(mergedRanges[currentRangeIndex].lowerBound, range.lowerBound)
        var upperBound = range.upperBound

        while
            mergedRanges.indices.contains(currentRangeIndex),
            mergedRanges[currentRangeIndex].lowerBound < upperBound + 1
        {
            upperBound = max(upperBound, mergedRanges[currentRangeIndex].upperBound)
            currentRangeIndex += 1
        }

        newRanges.append(lowerBound...upperBound)

        if mergedRanges.indices.contains(currentRangeIndex) {
            while mergedRanges.indices.contains(currentRangeIndex) {
                newRanges.append(mergedRanges[currentRangeIndex])
                currentRangeIndex += 1
            }
        }

        self.mergedRanges = newRanges
    }
}
