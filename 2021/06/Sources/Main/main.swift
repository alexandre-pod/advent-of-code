import Foundation

typealias LanternTimer = Int

/// timer value of a newly created lantern
let newLanternTimer: LanternTimer = 8
/// timer value of a lantern after reaching 0
let cycleLanternTimer: LanternTimer = 6

func main() {
    let timers: [LanternTimer] = readLine()!.split(separator: ",").map { Int($0)! }

    print(part1(timers: timers))
    print(part2(timers: timers))
}

func part1(timers: [LanternTimer]) -> Int {
    return numberOfLanterns(startingFromTimers: timers, afterSteps: 80)
}

func part2(timers: [LanternTimer]) -> Int {
    return numberOfLanterns(startingFromTimers: timers, afterSteps: 256)
}

func numberOfLanterns(startingFromTimers timers: [LanternTimer], afterSteps: Int) -> Int {
    var timerDictionary: [LanternTimer: Int] = [:]

    for timer in timers {
        timerDictionary[timer, default: 0] += 1
    }

    for _ in 1...afterSteps {
        stepTimer(timerDictionary: &timerDictionary)
    }

    return timerDictionary.reduce(0, { $0 + $1.value })
}

func stepTimer(timerDictionary: inout [LanternTimer: Int]) {
    let zeroLanterns = timerDictionary[0] ?? 0
    for index in 0..<newLanternTimer {
        timerDictionary[index] = timerDictionary[index + 1] ?? 0
    }

    timerDictionary[newLanternTimer] = zeroLanterns
    timerDictionary[cycleLanternTimer, default: 0] += zeroLanterns
}

main()
