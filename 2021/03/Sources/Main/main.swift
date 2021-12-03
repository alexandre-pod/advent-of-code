import Foundation

struct Report {
    let lines: [Line]
    let lineLength: Int

    struct Line {
        let bits: [Bool]
    }
}

func main() {
    var lines: [Report.Line] = []
    var lineLength = -1
    while let line = readLine() {
        let line = Report.Line(bits: line.map { $0 == "1" })
        if lineLength == -1 {
            lineLength = line.bits.count
        }
        assert(line.bits.count == lineLength)
        lines.append(line)
    }

    let report = Report(lines: lines, lineLength: lineLength)

    print(part1(report: report))
    print(part2(report: report))
}

func part1(report: Report) -> Int {
    var upBits: [Int] = Array(repeating: 0, count: report.lineLength)

    report.lines.forEach { line in
        line.bits.enumerated().forEach {
            if $0.element {
                upBits[$0.offset] += 1
            }
        }
    }

    let gammaUpThreshold = report.lines.count / 2
    let gammaRate = binaryToInt(upBits.map { $0 > gammaUpThreshold })
    let epsilonRate = binaryToInt(upBits.map { $0 < gammaUpThreshold })
    return gammaRate * epsilonRate
}

func binaryToInt(_ binary: [Bool]) -> Int {
    return binary.reduce(0) { partialResult, upBit in
        return (partialResult << 1) + (upBit ? 1 : 0)
    }
}

func part2(report: Report) -> Int {
    return findOxygenRating(in: report) * findCO2ScrubberRating(in: report)
}

func findOxygenRating(in report: Report) -> Int {
    var remainingLines: [Report.Line] = report.lines
    var currentIndex = 0
    while remainingLines.count > 1 {
        let bitCount = countUpBits(in: remainingLines, atIndex: currentIndex)
        let upInMajority = bitCount * 2 >= remainingLines.count
        remainingLines = remainingLines.filter {
            $0.bits[currentIndex] == upInMajority
        }
        currentIndex += 1
    }
    return binaryToInt(remainingLines.first!.bits)
}

func findCO2ScrubberRating(in report: Report) -> Int {
    var remainingLines: [Report.Line] = report.lines
    var currentIndex = 0
    while remainingLines.count > 1 {
        let bitCount = countUpBits(in: remainingLines, atIndex: currentIndex)
        let upInMajority = bitCount * 2 >= remainingLines.count
        remainingLines = remainingLines.filter {
            $0.bits[currentIndex] != upInMajority
        }
        currentIndex += 1
    }
    return binaryToInt(remainingLines.first!.bits)
}

func countUpBits(in lines: [Report.Line], atIndex index: Int) -> Int {
    lines.filter { $0.bits[index] }.count

}

main()
