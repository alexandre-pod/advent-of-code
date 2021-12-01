import Foundation

struct Food {
    typealias Ingredient = String
    typealias Alergen = String
    let ingredients: [Ingredient]
    let alergens: [Alergen]
}

func main() {
    var foods: [Food] = []

    while let line = readLine() {
        foods.append(parseLine(line))
    }

    part1(foods: foods)
    part2(foods: foods)
}

func parseLine(_ line: String) -> Food {
    let parenthesisSplit = line.split(separator: "(")
    let ingredients = parenthesisSplit[0]
        .trimmingCharacters(in: .whitespaces)
        .split(separator: " ")
        .map(String.init)
    let allergens = Array(parenthesisSplit[1]
        .split(separator: " ")
        .map { $0.trimmingCharacters(in: CharacterSet([",", ")"])) }
        .map { String($0) }
        .dropFirst()
    )
    return Food(ingredients: ingredients, alergens: allergens)
}

// MARK: - Part 1

func part1(foods: [Food]) {
    let alergensCandidates = reduceAlergensCandidates(getAlergensCandidates(from: foods))

    let allPossibleIngredientAlergen = alergensCandidates.values.reduce(Set<Food.Ingredient>()) { partial, ingredients in
        partial.union(ingredients)
    }

    let answer = foods.flatMap { $0.ingredients }.filter { !allPossibleIngredientAlergen.contains($0) }.count
    print("answer: \(answer)")
}

func getAlergensCandidates(from foods: [Food]) -> [Food.Alergen: Set<Food.Ingredient>] {
    var alergensCandidates: [Food.Alergen: Set<Food.Ingredient>] = [:]
    for food in foods {
        let allIngerdients = Set(food.ingredients)
        for alergen in food.alergens {
            if let knownAlergensCandidates = alergensCandidates[alergen] {
                alergensCandidates[alergen] = knownAlergensCandidates.intersection(allIngerdients)
            } else {
                alergensCandidates[alergen] = allIngerdients
            }
        }
    }
    return alergensCandidates
}

func reduceAlergensCandidates(_ candidates: [Food.Alergen: Set<Food.Ingredient>]) -> [Food.Alergen: Set<Food.Ingredient>] {
    var alergensCandidates = candidates

    var knownAlergens: Set<Food.Alergen> = []

    while let knownAlergen = alergensCandidates.first(where: { !knownAlergens.contains($0.key) && $0.value.count == 1 }) {
        let knownIngredient = knownAlergen.value.first!
        knownAlergens.insert(knownAlergen.key)
        alergensCandidates = alergensCandidates.mapValues { $0.filter { $0 != knownIngredient } }
        alergensCandidates[knownAlergen.key] = knownAlergen.value
    }

    return alergensCandidates
}

// MARK: - Part 2

func part2(foods: [Food]) {
    let alergensCandidates = reduceAlergensCandidates(getAlergensCandidates(from: foods))

    let alergens = getCertainAlergens(from: alergensCandidates)

    let answer = alergens.sorted(by: { $0.key < $1.key }).map(\.value).joined(separator: ",")

    print("answer: \(answer)")
}

func getCertainAlergens(from candidates: [Food.Alergen: Set<Food.Ingredient>]) -> [Food.Alergen: Food.Ingredient] {
    return candidates.mapValues {
        guard $0.count == 1 else {
            fatalError("Uncertain solution")
        }
        return $0.first!
    }
}

main()
