import Foundation

struct Recipe {
    let ore: Int
    let clay: Int
    let obsidian: Int
}

struct Blueprint {
    let id: Int
    let oreRobotCosts: Recipe
    let clayRobotCosts: Recipe
    let obsidianRobotCosts: Recipe
    let geodeRobotCosts: Recipe

    let maxOreCost: Int
    let maxClayCost: Int
    let maxObsidianCost: Int

    internal init(id: Int, oreRobotCosts: Recipe, clayRobotCosts: Recipe, obsidianRobotCosts: Recipe, geodeRobotCosts: Recipe) {
        self.id = id
        self.oreRobotCosts = oreRobotCosts
        self.clayRobotCosts = clayRobotCosts
        self.obsidianRobotCosts = obsidianRobotCosts
        self.geodeRobotCosts = geodeRobotCosts

        maxOreCost = [oreRobotCosts, clayRobotCosts, obsidianRobotCosts, geodeRobotCosts].map(\.ore).max()!
        maxClayCost = [oreRobotCosts, clayRobotCosts, obsidianRobotCosts, geodeRobotCosts].map(\.clay).max()!
        maxObsidianCost = [oreRobotCosts, clayRobotCosts, obsidianRobotCosts, geodeRobotCosts].map(\.obsidian).max()!
    }

}

typealias InputType = [Blueprint]

func main() {
    var input: InputType = []

    while let line = readLine() {
        let parts = line.split(separator: ":")
        let blueprintId = Int(String(parts[0].split(separator: " ")[1]))!
        let recipes = parts[1].split(separator: ".", omittingEmptySubsequences: true)
        let blueprint = Blueprint(
            id: blueprintId,
            oreRobotCosts: Recipe(from: String(recipes[0])),
            clayRobotCosts: Recipe(from: String(recipes[1])),
            obsidianRobotCosts: Recipe(from: String(recipes[2])),
            geodeRobotCosts: Recipe(from: String(recipes[3]))
        )
        input.append(blueprint)
    }

    print(part1(inputParameter: input))
    print(part2(inputParameter: input))
}

extension Recipe {
    init(from input: String) {
        let components = Array(input.split(separator: " ").dropFirst(2))
        var ore = 0
        var clay = 0
        var obsidian = 0
        if let index = components.firstIndex(of: "ore") {
            ore = Int(String(components[index - 1]))!
        }
        if let index = components.firstIndex(of: "clay") {
            clay = Int(String(components[index - 1]))!
        }
        if let index = components.firstIndex(of: "obsidian") {
            obsidian = Int(String(components[index - 1]))!
        }
        self.ore = ore
        self.clay = clay
        self.obsidian = obsidian
    }
}

// MARK: - Part 1

let precomputedInputCache: [Int: Int] = [:]

func part1(inputParameter: InputType) -> Int {
    var qualitySum = 0
    for blueprint in inputParameter {
//        print("Blueprint \(blueprint.id)")
        let max = getMaxGeodeProduced(
            using: blueprint,
            remainingTime: 24
        )
//            print("Blueprint \(blueprint.id):", max)
        qualitySum += blueprint.id * max
    }

    return qualitySum
}

// MARK: - Part 2

func part2(inputParameter: InputType) -> Int {

    return inputParameter.prefix(3)
        .map { blueprint in
//            print("Start blueprint \(blueprint.id)")
            let max = getMaxGeodeProduced(
                using: blueprint,
                remainingTime: 32
            )
//            print("Blueprint \(blueprint.id):", max)
            return max
        }
        .reduce(1, *)
}

func getMaxGeodeProduced(
    using blueprint: Blueprint,
    materials: [Int] = [0, 0, 0, 0],
    robots: [Int] = [1, 0, 0, 0],
    remainingTime: Int
) -> Int {

    let oreRobotOre = blueprint.oreRobotCosts.ore
    let clayRobotOre = blueprint.clayRobotCosts.ore
    let obsidianRobotOre = blueprint.obsidianRobotCosts.ore
    let obsidianRobotClay = blueprint.obsidianRobotCosts.clay
    let geodeRobotOre = blueprint.geodeRobotCosts.ore
    let geodeRobotObsidian = blueprint.geodeRobotCosts.obsidian

    let maxOreRobot = max(oreRobotOre, clayRobotOre, obsidianRobotOre, geodeRobotOre)
    let maxClayRobot = obsidianRobotClay
    let maxObsidianRobot = geodeRobotObsidian

    struct CacheKey: Hashable {
        let ore: Int
        let clay: Int
        let obsidian: Int
        let oreRobot: Int
        let clayRobot: Int
        let obsidianRobot: Int
        let remainingTime: Int
    }

    var cache: [CacheKey: Int] = [:]

    func best(
        ore: Int,
        clay: Int,
        obsidian: Int,
        oreRobot: Int,
        clayRobot: Int,
        obsidianRobot: Int,
        remainingTime: Int
    ) -> Int {
        if remainingTime == 0 {
            return 0
        }
        let key = CacheKey(ore: ore, clay: clay, obsidian: obsidian, oreRobot: oreRobot, clayRobot: clayRobot, obsidianRobot: obsidianRobot, remainingTime: remainingTime)
        if let cached = cache[key] {
            return cached
        }
        var maxGeode = 0
        if !(ore >= maxOreRobot && clay >= maxOreRobot && obsidian >= maxObsidianRobot) {
            let geodes = best(
                ore: ore + oreRobot,
                clay: clay + clayRobot,
                obsidian: obsidian + obsidianRobot,
                oreRobot: oreRobot,
                clayRobot: clayRobot,
                obsidianRobot: obsidianRobot,
                remainingTime: remainingTime - 1
            )
            maxGeode = max(maxGeode, geodes)
        }
        if ore >= oreRobotOre, oreRobot < maxOreRobot {
            let geodes = best(
                ore: ore + oreRobot - oreRobotOre,
                clay: clay + clayRobot,
                obsidian: obsidian + obsidianRobot,
                oreRobot: oreRobot + 1,
                clayRobot: clayRobot,
                obsidianRobot: obsidianRobot,
                remainingTime: remainingTime - 1
            )
            maxGeode = max(maxGeode, geodes)
        }
        if ore >= clayRobotOre, clayRobot < maxClayRobot {
            let geodes = best(
                ore: ore + oreRobot - clayRobotOre,
                clay: clay + clayRobot,
                obsidian: obsidian + obsidianRobot,
                oreRobot: oreRobot,
                clayRobot: clayRobot + 1,
                obsidianRobot: obsidianRobot,
                remainingTime: remainingTime - 1
            )
            maxGeode = max(maxGeode, geodes)
        }
        if ore >= obsidianRobotOre, clay >= obsidianRobotClay, obsidianRobot < maxObsidianRobot {
            let geodes = best(
                ore: ore + oreRobot - obsidianRobotOre,
                clay: clay + clayRobot - obsidianRobotClay,
                obsidian: obsidian + obsidianRobot,
                oreRobot: oreRobot,
                clayRobot: clayRobot,
                obsidianRobot: obsidianRobot + 1,
                remainingTime: remainingTime - 1
            )
            maxGeode = max(maxGeode, geodes)
        }

        if ore >= geodeRobotOre, obsidian >= geodeRobotObsidian {
            let geodes = (remainingTime - 1) + best(
                ore: ore + oreRobot - geodeRobotOre,
                clay: clay + clayRobot,
                obsidian: obsidian + obsidianRobot - geodeRobotObsidian,
                oreRobot: oreRobot,
                clayRobot: clayRobot,
                obsidianRobot: obsidianRobot,
                remainingTime: remainingTime - 1
            )
            maxGeode = max(maxGeode, geodes)
        }

        cache[key] = maxGeode
        return maxGeode

    }

    return materials[3] + best(
        ore: materials[0],
        clay: materials[1],
        obsidian: materials[2],
        oreRobot: robots[0],
        clayRobot: robots[1],
        obsidianRobot: robots[2],
        remainingTime: remainingTime
    )
}

main()
