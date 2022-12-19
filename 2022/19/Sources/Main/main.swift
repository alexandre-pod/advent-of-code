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

func main() async {
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

    print(await part1(inputParameter: input))
    print(await part2(inputParameter: input))
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
//let precomputedInputCache: [Int: Int] = [
//    1: 4,
//    2: 0,
//    3: 0,
//    4: 2,
//    5: 5,
//    6: 3,
//    7: 9,
//    8: 1,
//    9: 0,
//    10: 16,
//    11: 3,
//    12: 2,
//    13: 5,
//    14: 0,
//    15: 2,
//    16: 2,
//    17: 0,
//    18: 3,
//    19: 5,
//    20: 6,
//    21: 5,
//    22: 0,
//    23: 9,
//    24: 0,
//    25: 1,
//    26: 0,
//    27: 13,
//    28: 0,
//    29: 0,
//    30: 0,
//]

func part1(inputParameter: InputType) async -> Int {
//        return await withTaskGroup(of: Int.self) { group in
//            for blueprint in inputParameter {
//                group.addTask {
//                    print("Start blueprint \(blueprint.id)")
//                    if let value = precomputedInputCache[blueprint.id] {
//                        print("Blueprint \(blueprint.id) [CACHED]:", value)
//                        return blueprint.id * value
//                    } else {
//                        let max = getMaxGeodeProduced(
//                            using: blueprint,
//                            currentState: MiningState(),
//                            remainingTime: 24
//                        )
//                        print("Blueprint \(blueprint.id):", max)
//                        return blueprint.id * max
//                    }
//                }
//            }
//    //        group.waitForAll()
//            return await group.reduce(0, +)
//        }
    var qualitySum = 0
    for blueprint in inputParameter {
        print("Blueprint \(blueprint.id)")
        let max = getMaxGeodeProduced(
            using: blueprint,
            currentState: MiningState(),
            remainingTime: 24
        )
        print(max)
        qualitySum += blueprint.id * max
    }

    return qualitySum
}

struct MiningState {
    var oreRobot: Int = 1
    var clayRobot: Int = 0
    var obsidianRobot: Int = 0
    var geodeRobot: Int = 0

    var ore: Int = 0
    var clay: Int = 0
    var obsidian: Int = 0
    var geode: Int = 0
}

extension MiningState: CustomStringConvertible {
    var description: String {
        return "Resources: \(ore) - \(clay) - \(obsidian) - \(geode) \t Robots: \(oreRobot) - \(clayRobot) - \(obsidian) - \(geodeRobot)"
    }
}

func getMaxGeodeProducedOLD(
    using blueprint: Blueprint,
    currentState: MiningState,
    remainingTime: Int
) -> Int {
    guard remainingTime > 0 else {
//        print(currentState.geode)
        return currentState.geode
    }

//    print(remainingTime, " : ", currentState)
//    Thread.sleep(forTimeInterval: 0.016)

//
//    var nextState = currentState
//    nextState.ore += currentState.oreRobot
//    nextState.clay += currentState.clayRobot
//    nextState.obsidian += currentState.obsidianRobot


    var withoutCrafting = 0
    var withCraftingOreRobot = 0
    var withCraftingClayRobot = 0
    var withCraftingObsidianRobot = 0
    var withCraftingGeodeRobot = 0

    let canCraftOreRobot = currentState.oreRobot < blueprint.maxOreCost && blueprint.oreRobotCosts.canAfford(with: currentState)
    let canCraftClayRobot = currentState.clayRobot < blueprint.maxClayCost && blueprint.clayRobotCosts.canAfford(with: currentState)
    let canCraftObsidianRobot = currentState.obsidianRobot < blueprint.maxObsidianCost && blueprint.obsidianRobotCosts.canAfford(with: currentState)
    let canCraftGeodeRobot = blueprint.geodeRobotCosts.canAfford(with: currentState)

    if canCraftOreRobot {
        withCraftingOreRobot = getMaxGeodeProduced(
            using: blueprint,
            currentState: currentState.collectingResources().addingOreRobot(using: blueprint),
            remainingTime: remainingTime - 1
        )
    }
    if canCraftClayRobot {
        withCraftingClayRobot = getMaxGeodeProduced(
            using: blueprint,
            currentState: currentState.collectingResources().addingClayRobot(using: blueprint),
            remainingTime: remainingTime - 1
        )
    }
    if canCraftObsidianRobot {
        withCraftingObsidianRobot = getMaxGeodeProduced(
            using: blueprint,
            currentState: currentState.collectingResources().addingObsidianRobot(using: blueprint),
            remainingTime: remainingTime - 1
        )
    }
    if canCraftGeodeRobot {
        withCraftingGeodeRobot = getMaxGeodeProduced(
            using: blueprint,
            currentState: currentState.collectingResources().addingGeodeRobot(using: blueprint),
            remainingTime: remainingTime - 1
        )
    }

    let canAffordAll = blueprint.canAffordAllRecipes(currentState)
//    let couldAffordClayRobot = blueprint.clayRobotCosts.

    if !blueprint.canAffordAllRecipes(currentState) {
        withoutCrafting = getMaxGeodeProduced(
            using: blueprint,
            currentState: currentState.collectingResources(),
            remainingTime: remainingTime - 1
        )
    }

    return max(
        currentState.geode,
        withoutCrafting,
        withCraftingOreRobot,
        withCraftingClayRobot,
        withCraftingObsidianRobot,
        withCraftingGeodeRobot
    )
}

extension MiningState {
    func collectingResources() -> MiningState {
        var nextState = self
        nextState.ore += self.oreRobot
        nextState.clay += self.clayRobot
        nextState.obsidian += self.obsidianRobot
        nextState.geode += self.geodeRobot
        return nextState
    }

    func addingOreRobot(using blueprint: Blueprint) -> MiningState {
        guard blueprint.oreRobotCosts.canAfford(with: self) else { return self }
        var nextState = self
        nextState.oreRobot += 1
        nextState.ore -= blueprint.oreRobotCosts.ore
        nextState.clay -= blueprint.oreRobotCosts.clay
        nextState.obsidian -= blueprint.oreRobotCosts.obsidian
        return nextState
    }

    func addingClayRobot(using blueprint: Blueprint) -> MiningState {
        guard blueprint.clayRobotCosts.canAfford(with: self) else { return self }
        var nextState = self
        nextState.clayRobot += 1
        nextState.ore -= blueprint.clayRobotCosts.ore
        nextState.clay -= blueprint.clayRobotCosts.clay
        nextState.obsidian -= blueprint.clayRobotCosts.obsidian
        return nextState
    }

    func addingObsidianRobot(using blueprint: Blueprint) -> MiningState {
        guard blueprint.obsidianRobotCosts.canAfford(with: self) else { return self }
        var nextState = self
        nextState.obsidianRobot += 1
        nextState.ore -= blueprint.obsidianRobotCosts.ore
        nextState.clay -= blueprint.obsidianRobotCosts.clay
        nextState.obsidian -= blueprint.obsidianRobotCosts.obsidian
        return nextState
    }

    func addingGeodeRobot(using blueprint: Blueprint) -> MiningState {
        guard blueprint.geodeRobotCosts.canAfford(with: self) else { return self }
        var nextState = self
        nextState.geodeRobot += 1
        nextState.ore -= blueprint.geodeRobotCosts.ore
        nextState.clay -= blueprint.geodeRobotCosts.clay
        nextState.obsidian -= blueprint.geodeRobotCosts.obsidian
        return nextState
    }
}

extension Blueprint {
    func canAffordAllRecipes(_ state: MiningState) -> Bool {
        return oreRobotCosts.canAfford(with: state)
        && clayRobotCosts.canAfford(with: state)
        && obsidianRobotCosts.canAfford(with: state)
        && geodeRobotCosts.canAfford(with: state)
    }
}

extension Recipe {
    func canAfford(with state: MiningState) -> Bool {
        return ore <= state.ore
            && clay <= state.clay
            && obsidian <= state.obsidian
    }
}

// MARK: - Part 2

func part2(inputParameter: InputType) async -> Int {

    return inputParameter.prefix(3)
        .map { blueprint in
            print("Start blueprint \(blueprint.id)")
            let max = getMaxGeodeProduced(
                using: blueprint,
                currentState: MiningState(),
                remainingTime: 32
            )
            print("Blueprint \(blueprint.id):", max)
            return max
        }
        .reduce(1, *)

//        return await withTaskGroup(of: Int.self) { group in
//            for blueprint in inputParameter.prefix(3) {
//                group.addTask {
//                    print("Start blueprint \(blueprint.id)")
//    //                if let value = precomputedInputCache[blueprint.id] {
//    //                    print("Blueprint \(blueprint.id) [CACHED]:", value)
//    //                    return blueprint.id * value
//    //                } else {
//                        let max = getMaxGeodeProduced(
//                            using: blueprint,
//                            currentState: MiningState(),
//                            remainingTime: 32
//                        )
//                        print("Blueprint \(blueprint.id):", max)
//                        return max
//    //                }
//                }
//            }
//            //        group.waitForAll()
//            return await group.reduce(1, *)
//        }
    //    for blueprint in inputParameter {
    //        print("Blueprint \(blueprint.id)")
    //        let max = getMaxGeodeProduced(
    //            using: blueprint,
    //            currentState: MiningState(),
    //            remainingTime: 24
    //        )
    //        print(max)
    //        qualitySum += blueprint.id * max
    //    }

    //    return qualitySum
}

func getMaxGeodeProduced(
    using blueprint: Blueprint,
    currentState: MiningState,
    remainingTime: Int
) -> Int {
//    maximumPossibleGeodesCache.removeAll()
//    var optimalStrategyReached: [Int: (Int, Int)] = [:]
//    //    var maximumGeodeFound = 0
//    var maximumGeodeFound = 10
//    return getMaxGeodeProduced2(
//        using: Blueprint2(
//            oreRobot: blueprint.oreRobotCosts.arrayRecipe,
//            clayRobot: blueprint.clayRobotCosts.arrayRecipe,
//            obsidianRobot: blueprint.obsidianRobotCosts.arrayRecipe,
//            geodeRobot: blueprint.geodeRobotCosts.arrayRecipe
//        ),
//        materials: [currentState.ore, currentState.clay, currentState.obsidian, currentState.geode],
//        robots: [currentState.oreRobot, currentState.clayRobot, currentState.obsidianRobot, currentState.geodeRobot],
//        remainingTime: remainingTime,
//        maximumGeodeFound: &maximumGeodeFound,
//        optimalStrategyReached: &optimalStrategyReached
//    )
    return getMaxGeodeProduced3(
        using: Blueprint2(
            oreRobot: blueprint.oreRobotCosts.arrayRecipe,
            clayRobot: blueprint.clayRobotCosts.arrayRecipe,
            obsidianRobot: blueprint.obsidianRobotCosts.arrayRecipe,
            geodeRobot: blueprint.geodeRobotCosts.arrayRecipe
        ),
        materials: [currentState.ore, currentState.clay, currentState.obsidian, currentState.geode],
        robots: [currentState.oreRobot, currentState.clayRobot, currentState.obsidianRobot, currentState.geodeRobot],
        remainingTime: remainingTime
    )
}

struct Blueprint2 {
    let oreRobot: [Int]
    let clayRobot: [Int]
    let obsidianRobot: [Int]
    let geodeRobot: [Int]

    let maximumCost: [Int]

    init(oreRobot: [Int], clayRobot: [Int], obsidianRobot: [Int], geodeRobot: [Int]) {
        self.oreRobot = oreRobot
        self.clayRobot = clayRobot
        self.obsidianRobot = obsidianRobot
        self.geodeRobot = geodeRobot

        let allRecipes = [oreRobot, clayRobot, obsidianRobot, geodeRobot]
        self.maximumCost = (0..<4).map { index in allRecipes.map { $0[index] }.max()! }
    }
}

@inlinable
func greaterOrEqual(_ materials: [Int], _ recipe: [Int]) -> Bool {
    return zip(materials, recipe).allSatisfy { $0.0 >= $0.1 }
}

@inlinable
func increment(materials: [Int], robots: [Int]) -> [Int] {
    return zip(materials, robots).map { $0.0 + $0.1 }
}

@inlinable
func remove(from materials: [Int], recipe: [Int]) -> [Int] {
    return zip(materials, recipe).map { $0.0 - $0.1 }
}

extension Recipe {
    var arrayRecipe: [Int] {
        return [ore, clay, obsidian, 0]
    }
}


struct TupleKey: Hashable {
    private let a: Int
    private let b: Int
    private let c: Int

    init(_ a: Int, _ b: Int, _ c: Int) {
        self.a = a
        self.b = b
        self.c = c
    }
}

var maximumPossibleGeodesCache: [TupleKey: Int] = [:]

func maximumPossibleGeodes(
    currentCount: Int,
    geodeRobots: Int,
    remainingTime: Int
) -> Int {
    guard remainingTime > 0 else { return currentCount }
    let key = TupleKey(currentCount, geodeRobots, remainingTime)
    if let cached = maximumPossibleGeodesCache[key] {
        return cached
    }
    let value = remainingTime * geodeRobots + (remainingTime * (remainingTime + 1)) / 2
    maximumPossibleGeodesCache[key] = value
    return value
}
/*

 Start blueprint 1
 Max found: 1
 Max found: 2
 Max found: 3
 Max found: 4
 Max found: 5
 Max found: 6
 Max found: 7
 Max found: 8
 Max found: 9
 Max found: 11
 Max found: 13
 found optimal at: 1

 */

func getMaxGeodeProduced2(
    using blueprint: Blueprint2,
    materials: [Int] = [0, 0, 0, 0],
    robots: [Int] = [1, 0, 0, 0],
    remainingTime: Int,
    maximumGeodeFound: inout Int,
    optimalStrategyReached: inout [Int: (Int, Int)]
) -> Int {
    guard remainingTime > 0 else {
        if materials[3] > maximumGeodeFound {
            print("Max found:", materials[3])
            maximumGeodeFound = materials[3]
        }
        return materials[3]
    }

//    print(remainingTime, "resources: \(materials)\t Robots: \(robots)")
//    Thread.sleep(forTimeInterval: 0.016)

    let incrementedMaterials = increment(materials: materials, robots: robots)

    if greaterOrEqual(robots, blueprint.geodeRobot) {
        if greaterOrEqual(materials, blueprint.geodeRobot) {
            if let currentOptimal = optimalStrategyReached[remainingTime] {
                if materials[3] >= currentOptimal.0, robots[3] >= currentOptimal.1 {
                    if materials[3] > currentOptimal.0 || robots[3] > currentOptimal.1 {
                        print("found optimal at:", remainingTime, "with", materials[3], "robots: \(robots)")
                        optimalStrategyReached[remainingTime] = (materials[3], robots[3])
                    }
                }
            } else {
                print("found optimal at:", remainingTime, "with", materials[3], "robots: \(robots)")
                optimalStrategyReached[remainingTime] = (materials[3], robots[3])
            }
            return getMaxGeodeProduced2(
                using: blueprint,
                materials: remove(from: incrementedMaterials, recipe: blueprint.geodeRobot),
                robots: increment(materials: robots, robots: [0, 0, 0, 1]),
                remainingTime: remainingTime - 1,
                maximumGeodeFound: &maximumGeodeFound,
                optimalStrategyReached: &optimalStrategyReached
            )
        } else {
            return getMaxGeodeProduced2(
                using: blueprint,
                materials: incrementedMaterials,
                robots: robots,
                remainingTime: remainingTime - 1,
                maximumGeodeFound: &maximumGeodeFound,
                optimalStrategyReached: &optimalStrategyReached
            )
        }
    }

    let maxPossible = maximumPossibleGeodes(
        currentCount: materials[3],
        geodeRobots: robots[3],
        remainingTime: remainingTime
    )
    if maxPossible < maximumGeodeFound {
//        print("Found less optimal")
        return 0
    }

    if let optimal = optimalStrategyReached[remainingTime] {
        let maxFromOptimal = maximumPossibleGeodes(
            currentCount: optimal.0,
            geodeRobots: optimal.1,
            remainingTime: remainingTime
        )

        if maxPossible < maxFromOptimal {
            return 0
        }
    }

    let canAffordAll = greaterOrEqual(materials, blueprint.maximumCost)

    var maximumSeen = materials[3]

    if !canAffordAll {
        let count = getMaxGeodeProduced2(
            using: blueprint,
            materials: incrementedMaterials,
            robots: robots,
            remainingTime: remainingTime - 1,
            maximumGeodeFound: &maximumGeodeFound,
            optimalStrategyReached: &optimalStrategyReached
        )
        maximumSeen = max(maximumSeen, count)
    }

    if greaterOrEqual(materials, blueprint.geodeRobot) {
        let count = getMaxGeodeProduced2(
            using: blueprint,
            materials: remove(from: incrementedMaterials, recipe: blueprint.geodeRobot),
            robots: increment(materials: robots, robots: [0, 0, 0, 1]),
            remainingTime: remainingTime - 1,
            maximumGeodeFound: &maximumGeodeFound,
            optimalStrategyReached: &optimalStrategyReached
        )
        maximumSeen = max(maximumSeen, count)
    }

    if robots[2] < blueprint.maximumCost[2] && greaterOrEqual(materials, blueprint.obsidianRobot) {
        let count = getMaxGeodeProduced2(
            using: blueprint,
            materials: remove(from: incrementedMaterials, recipe: blueprint.obsidianRobot),
            robots: increment(materials: robots, robots: [0, 0, 1, 0]),
            remainingTime: remainingTime - 1,
            maximumGeodeFound: &maximumGeodeFound,
            optimalStrategyReached: &optimalStrategyReached
        )
        maximumSeen = max(maximumSeen, count)
    }

    if robots[1] < blueprint.maximumCost[1] && greaterOrEqual(materials, blueprint.clayRobot) {
        let count = getMaxGeodeProduced2(
            using: blueprint,
            materials: remove(from: incrementedMaterials, recipe: blueprint.clayRobot),
            robots: increment(materials: robots, robots: [0, 1, 0, 0]),
            remainingTime: remainingTime - 1,
            maximumGeodeFound: &maximumGeodeFound,
            optimalStrategyReached: &optimalStrategyReached
        )
        maximumSeen = max(maximumSeen, count)
    }

    if robots[0] < blueprint.maximumCost[0] && greaterOrEqual(materials, blueprint.oreRobot) {
        let count = getMaxGeodeProduced2(
            using: blueprint,
            materials: remove(from: incrementedMaterials, recipe: blueprint.oreRobot),
            robots: increment(materials: robots, robots: [1, 0, 0, 0]),
            remainingTime: remainingTime - 1,
            maximumGeodeFound: &maximumGeodeFound,
            optimalStrategyReached: &optimalStrategyReached
        )
        maximumSeen = max(maximumSeen, count)
    }


    return maximumSeen
}

// MARK: - Try 3

func getMaxGeodeProduced3(
    using blueprint: Blueprint2,
    materials: [Int] = [0, 0, 0, 0],
    robots: [Int] = [1, 0, 0, 0],
    remainingTime: Int
) -> Int {

    let oreRobotOre = blueprint.oreRobot[0]
    let clayRobotOre = blueprint.clayRobot[0]
    let obsidianRobotOre = blueprint.obsidianRobot[0]
    let obsidianRobotClay = blueprint.obsidianRobot[1]
    let geodeRobotOre = blueprint.geodeRobot[0]
    let geodeRobotObsidian = blueprint.geodeRobot[2]

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


await main()
