import Foundation

typealias Races = [Race]

struct Race {
    let duration: Int
    let bestScore: Int
}

func main() {
    let stringDurations = readLine()!.split(separator: ":")[1]
    let stringBestScores = readLine()!.split(separator: ":")[1]
    let durations = stringDurations.split(separator: " ").compactMap { Int(String($0)) }
    let bestScores = stringBestScores.split(separator: " ").compactMap { Int(String($0)) }
    
    let races = zip(durations, bestScores).map { Race(duration: $0.0, bestScore: $0.1) }
    
    print(part1(races: races))

    let duration = Int(String(stringDurations.filter { $0.isNumber }))!
    let bestScore = Int(String(stringBestScores.filter { $0.isNumber }))!
    let race = Race(duration: duration, bestScore: bestScore)

    print(part2(race: race))
}

// MARK: - Part 1

func part1(races: Races) -> Int {
    return races.map { $0.winnableWayCount }.reduce(1, *)
}

extension Race {

    var winnableWayCount: Int {
        optimizedWinnableWayCount
    }

    var slowWinnableWayCount: Int {
        return (1..<duration)
            .map { scoreWhenWaiting($0) }
            .filter { $0 > bestScore }
            .count
    }

    var optimizedWinnableWayCount: Int {
        let firstWinningPosition = findWinningDurationLimit(in: 0...(duration / 2))
        let lastWinningPosition = findWinningDurationLimit(in: (duration / 2)...duration)
        return lastWinningPosition - firstWinningPosition + 1
    }

    func findWinningDurationLimit(in range: ClosedRange<Int>) -> Int {
        guard range.count > 1 else { return range.lowerBound }

        let lowerScore = scoreWhenWaiting(range.lowerBound) - bestScore
        let upperScore = scoreWhenWaiting(range.upperBound) - bestScore

        assert(lowerScore > 0 || upperScore > 0)
        guard range.count > 2 else {
            return lowerScore > 0 ? range.lowerBound : range.upperBound
        }

        let midPosition = range.lowerBound + (range.upperBound - range.lowerBound) / 2
        let midScore = scoreWhenWaiting(midPosition) - bestScore

        let isGrowing = lowerScore < upperScore

        if lowerScore > 0, upperScore > 0 {
            return isGrowing ? lowerScore : upperScore
        }

        if midScore > 0 {
            return findWinningDurationLimit(
                in: isGrowing ? range.lowerBound...midPosition : midPosition...range.upperBound
            )
        } else {
            return findWinningDurationLimit(
                in: isGrowing ? midPosition...range.upperBound : range.lowerBound...midPosition
            )
        }
    }

    func scoreWhenWaiting(_ time: Int) -> Int {
        guard time <= duration else { return 0 }
        return (duration - time) * time
    }
}

// MARK: - Part 2

func part2(race: Race) -> Int {
    return race.winnableWayCount
}

main()
