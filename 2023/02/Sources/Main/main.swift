import Foundation

struct Game {
    let id: Int
    let draws: [Draw]
}

typealias Draw = [Color: Int]

enum Color: String {
    case red = "red"
    case green = "green"
    case blue = "blue"
}

func main() {
    var games: [Game] = []

    while let line = readLine() {
        games.append(parseGame(line: line))
    }

    print(part1(games: games))
    print(part2(games: games))
}

func parseGame(line: String) -> Game {
    let parts = line.split(separator: ":")
    let id = Int(String(parts[0].split(separator: " ")[1]))!
    let stringDraws = parts[1].split(separator: ";")

    let draws: [Draw] = stringDraws.map { rawDraw in
        let rawColors = rawDraw.split(separator: ",")
        return rawColors.map { colorDraw -> (Int, Color) in
                let colorPart = colorDraw
                    .trimmingCharacters(in: .whitespaces)
                    .split(separator: " ")
                let amount = Int(String(colorPart[0]))!
                let color = Color(rawValue: String(colorPart[1]))!
                return (amount, color)
            }
            .reduce(into: [Color:Int]()) { $0[$1.1] = $1.0 }
    }

    return Game(id: id, draws: draws)
}

// MARK: - Part 1

func part1(games: [Game]) -> Int {
    return games.filter { $0.isPossibleWithLimits(red: 12, green: 13, blue: 14) }.map(\.id).reduce(0, +)
}

extension Game {

    func isPossibleWithLimits(red: Int, green: Int, blue: Int) -> Bool {
        return draws.allSatisfy { draw in
            return draw[.red, default: 0] <= red
                && draw[.green, default: 0] <= green
                && draw[.blue, default: 0] <= blue
        }
    }
}

// MARK: - Part 2

func part2(games: [Game]) -> Int {
    return games.map { $0.gamePower() }.reduce(0, +)
}

extension Game {

    func gamePower() -> Int {
        let minimums = minimumAmountOfCubes()
        return minimums.red * minimums.green * minimums.blue
    }

    func minimumAmountOfCubes() -> (red: Int, green: Int, blue: Int) {
        return (
            red: draws.map { $0[.red] ?? 0 }.max() ?? 0,
            green: draws.map { $0[.green] ?? 0 }.max() ?? 0,
            blue: draws.map { $0[.blue] ?? 0 }.max() ?? 0
        )
    }
}

main()
