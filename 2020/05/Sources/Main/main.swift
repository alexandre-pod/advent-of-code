import Foundation

struct BoardingPass {
    let passID: Int
    var row: Int { passID / 8 }
    var column: Int { passID % 8 }
}

extension BoardingPass {
    init(from boardingPassCode: String) {
        let binaryPassCode = boardingPassCode
            .replacingOccurrences(of: "F", with: "0")
            .replacingOccurrences(of: "B", with: "1")
            .replacingOccurrences(of: "L", with: "0")
            .replacingOccurrences(of: "R", with: "1")
        let passID = Int(binaryPassCode, radix: 2)!
        self.init(passID: passID)
    }
}


func main() {
    var passes: [BoardingPass] = []
    while let line = readLine() {
        passes.append(BoardingPass(from: line))
    }
    part1(passes: passes)
    part2(passes: passes)
}

func part1(passes: [BoardingPass]) {
    let maxID = passes.map(\.passID).max()
    print("maxID: \(maxID ?? -1)")
}

func part2(passes: [BoardingPass]) {
    guard !passes.isEmpty else { return print("No passes given !") }
    let minID = passes.map(\.passID).min()!
    let maxID = passes.map(\.passID).max()!
    let idSet = Set(passes.map(\.passID))
    for id in (minID...maxID) {
        if idSet.contains(id) { continue }
        if
            idSet.contains(id - 1),
            idSet.contains(id + 1) {
            print("Your id: \(id)")
        }
    }
}


main()
