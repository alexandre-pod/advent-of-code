import Foundation

enum CellState {
    case active
    case inactive
}

func main() {
    var plane: Plane = []
    while let line = readLine() {
        plane.append(line.map { $0 == "#" ? .active: .inactive })
    }

    part1(plane: plane)
    part2(plane: plane)
}

func part1(plane: Plane) {
    var grid = Grid(arrayLiteral: plane)

    let maxCycle = 6

//    print("Cycle: 0")
//    grid.debugPrint()
    (1...maxCycle).forEach { cycle in
        grid = grid.nextIteration()
//        print("Cycle: \(cycle)")
//        grid.debugPrint()
    }

    let answer = grid.countActiveCells

    print("answer: \(answer)")
}

func part2(plane: Plane) {
    var cube4D = Cube4D(arrayLiteral: [plane])

    let maxCycle = 6

    (1...maxCycle).forEach { cycle in
        cube4D = cube4D.nextIteration()
    }

    let answer = cube4D.countActiveCells

    print("answer: \(answer)")
}


extension Grid {
    func debugPrint() {
        for (index, plane) in self.enumerated() {
            print("z=\(index)")
            plane.debugPrint()
        }
    }
}

extension Plane {
    func debugPrint() {
        print(self.map { $0.map { $0 == .active ? "X" : "." }.joined() }.joined(separator: "\n"))
    }
}

main()
