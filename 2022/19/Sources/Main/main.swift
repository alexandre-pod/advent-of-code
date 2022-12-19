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

func part1(inputParameter: InputType) -> Int {
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

func getMaxGeodeProduced(
    using blueprint: Blueprint,
    currentState: MiningState,
    remainingTime: Int
) -> Int {
    guard remainingTime > 0 else {
//        print(currentState.geode)
        return currentState.geode
    }

//    print(currentState)

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

    if !blueprint.canAffordAllRecipes(currentState) {
        withoutCrafting = getMaxGeodeProduced(
            using: blueprint,
            currentState: currentState.collectingResources(),
            remainingTime: remainingTime - 1
        )
    }

    if blueprint.oreRobotCosts.canAfford(with: currentState) {
        withCraftingOreRobot = getMaxGeodeProduced(
            using: blueprint,
            currentState: currentState.collectingResources().addingOreRobot(using: blueprint),
            remainingTime: remainingTime - 1
        )
    }
    if blueprint.clayRobotCosts.canAfford(with: currentState) {
        withCraftingClayRobot = getMaxGeodeProduced(
            using: blueprint,
            currentState: currentState.collectingResources().addingClayRobot(using: blueprint),
            remainingTime: remainingTime - 1
        )
    }
    if blueprint.obsidianRobotCosts.canAfford(with: currentState) {
        withCraftingObsidianRobot = getMaxGeodeProduced(
            using: blueprint,
            currentState: currentState.collectingResources().addingObsidianRobot(using: blueprint),
            remainingTime: remainingTime - 1
        )
    }
    if blueprint.geodeRobotCosts.canAfford(with: currentState) {
        withCraftingGeodeRobot = getMaxGeodeProduced(
            using: blueprint,
            currentState: currentState.collectingResources().addingGeodeRobot(using: blueprint),
            remainingTime: remainingTime - 1
        )
    }

//    if blueprint.geodeRobotCosts.canAfford(with: currentState) {
//        withCraftingGeodeRobot = getMaxGeodeProduced(
//            using: blueprint,
//            currentState: currentState.collectingResources().addingGeodeRobot(using: blueprint),
//            remainingTime: remainingTime - 1
//        )
//    } else if blueprint.obsidianRobotCosts.canAfford(with: currentState) {
//        withCraftingObsidianRobot = getMaxGeodeProduced(
//            using: blueprint,
//            currentState: currentState.collectingResources().addingObsidianRobot(using: blueprint),
//            remainingTime: remainingTime - 1
//        )
//    } else if blueprint.clayRobotCosts.canAfford(with: currentState) {
//        withCraftingClayRobot = getMaxGeodeProduced(
//            using: blueprint,
//            currentState: currentState.collectingResources().addingClayRobot(using: blueprint),
//            remainingTime: remainingTime - 1
//        )
//    } else if blueprint.oreRobotCosts.canAfford(with: currentState) {
//        withCraftingOreRobot = getMaxGeodeProduced(
//            using: blueprint,
//            currentState: currentState.collectingResources().addingOreRobot(using: blueprint),
//            remainingTime: remainingTime - 1
//        )
//    } else {
//        withoutCrafting = getMaxGeodeProduced(
//            using: blueprint,
//            currentState: currentState.collectingResources(),
//            remainingTime: remainingTime - 1
//        )
//    }

    return max(withoutCrafting, withCraftingOreRobot, withCraftingClayRobot, withCraftingObsidianRobot, withCraftingGeodeRobot)
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

func part2(inputParameter: InputType) -> Int {
    fatalError()
}

main()
