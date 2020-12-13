import Foundation

func main() {
    let earliestTimestamp = Int(readLine()!)!
    let busList = readLine()!.split(separator: ",")

    part1(earliestTimestamp: earliestTimestamp, busList: busList)
//    part2Exaustive(busList: busList)
    part2(busList: busList)
}

func part1(earliestTimestamp: Int, busList: [String.SubSequence]) {

    let availableBusIDs = busList.filter { $0 != "x" }.map { Int($0)! }

    let waitingAndIDs = availableBusIDs.map { busID -> (Int, Int) in
        let timeAfterDeparture = earliestTimestamp % busID
        if timeAfterDeparture == 0 {
            return (0, busID)
        } else {
            return (busID - timeAfterDeparture, busID)
        }
    }
    let minWaitingAndIDs = waitingAndIDs.min { $0.0 < $1.0 }
    let answer = minWaitingAndIDs.map { $0 * $1 }

    print(answer!)
}

func part2Exaustive(busList: [String.SubSequence]) {
    let busWithOffset: [(offset: Int, busID: Int)] = busList
        .enumerated()
        .compactMap { index, busID in
            if busID == "x" {
                return nil
            }
            return (offset: index, busID: Int(busID)!)
        }

    let biggestBusIDWithOffset = busWithOffset.max { $0.busID < $1.busID }!
    let biggestBusID = biggestBusIDWithOffset.busID
    let biggestBusIDOffset = biggestBusIDWithOffset.offset

    let startIndex = 100_000_000_000_000 / biggestBusID

    for index in startIndex... {
        let potentialX = biggestBusID * index - biggestBusIDOffset
        if busWithOffset.allSatisfy({ offset, busID in
            (potentialX + offset) % busID == 0
        }) {
            print(potentialX)
            return
        }
    }
    // Result: 741745043105674, computation time ~20min
}

func part2(busList: [String.SubSequence]) {
    let busWithOffset: [(offset: Int, busID: Int)] = busList
        .enumerated()
        .compactMap { index, busID in
            if busID == "x" {
                return nil
            }
            return (offset: index, busID: Int(busID)!)
        }

    print(busWithOffset.map(\.busID).sorted())

    let ni = busWithOffset.map(\.busID)
    let ai = busWithOffset.map { $0.offset == 0 ? $0.offset : $0.busID - $0.offset }
    print(chineseRemainder(ni: ni, ai: ai))
}

// Source: https://fr.wikipedia.org/wiki/Théorème_des_restes_chinois#Algorithme
func chineseRemainder(ni: [Int], ai: [Int]) -> Int {
    let n = ni.reduce(1, { $0 * $1 })
    let ei = ni
        .map { (ni: $0, ni_: n / $0) }
        .map { euclide(a: $0.ni, b: $0.ni_).v * $0.ni_ }
    let x = zip(ai, ei).map { $0.0 * $0.1 }.reduce(0, (+))
    return x % n
}

// Source: https://fr.wikipedia.org/wiki/Algorithme_d%27Euclide_étendu#Pseudo-code
func euclide(a: Int, b: Int) -> (r: Int, u: Int, v: Int) {
    func euclideRec(r: Int, u: Int, v: Int, r_: Int, u_: Int, v_: Int) -> (r: Int, u: Int, v: Int) {
        if r_ == 0 {
            return (r: r, u: u, v: v)
        }
        return euclideRec(r: r_, u: u_, v: v_, r_: r - (r / r_) * r_, u_: u - (r / r_) * u_, v_: v - (r / r_) * v_)
    }

    return euclideRec(r: a, u: 1, v: 0, r_: b, u_: 0, v_: 1)
}

main()
