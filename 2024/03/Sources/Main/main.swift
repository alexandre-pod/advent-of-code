import Foundation

typealias InputType = [String]

func main() {
    var input: InputType = []

    while let line = readLine() {
        input.append(line)
    }

    print(part1(inputParameter: input))
    print(part2(inputParameter: input))
}

// MARK: - Part 1

func part1(inputParameter: InputType) -> Int {
    let mulRegex = #/mul\((\d+),(\d+)\)/#

    return inputParameter.flatMap { line -> [Int] in
        return line.matches(of: mulRegex)
            .map { match in
//                print("mul: \(match.output.1), \(match.output.2)")
                return Int(match.output.1)! * Int(match.output.2)!
            }
    }.reduce(0, +)
}

// MARK: - Part 2

func part2(inputParameter: InputType) -> Int {

    var operations = inputParameter.flatMap {
        let tokens = getValidTokens(from: $0)
        let opereations = parseOperations(from: tokens)
        return opereations
    }
    return computeOperations(operations)
}

func computeOperations(_ opereations: [Operation]) -> Int {
    var result = 0

    var mulEnabled = true

    for opereation in opereations {
        switch opereation {
        case .enableMul:
            mulEnabled = true
        case .disableMul:
            mulEnabled = false
        case .mul(let val1, let val2):
            if mulEnabled {
                result += val1 * val2
            }
        }
    }

    return result
}

enum Operation {
    case enableMul
    case mul(Int, Int)
    case disableMul
}

func parseOperations(from tokens: [Token]) -> [Operation] {
    var operations: [Operation] = []

    var position = 0
    while position < tokens.count {
        switch tokens[position] {
        case .mul where position + 5 < tokens.count:
            if tokens[position + 1] == .openBrace,
               case let .number(val1) = tokens[position + 2],
               tokens[position + 3] == .coma,
               case let .number(val2) = tokens[position + 4],
               tokens[position + 5] == .closeBrace
            {
                operations.append(.mul(val1, val2))
                position += 5
            } else {
                position += 1
            }
        case .doToken where position + 2 < tokens.count:
            if tokens[position + 1] == .openBrace, tokens[position + 2] == .closeBrace {
                   operations.append(.enableMul)
                position += 3
            } else {
                position += 1
            }
        case .dont where position + 2 < tokens.count:
            if tokens[position + 1] == .openBrace, tokens[position + 2] == .closeBrace {
                operations.append(.disableMul)
                position += 3
            } else {
                position += 1
            }
        default:
            position += 1
        }
    }

    return operations
}

enum Token: Equatable {
    case openBrace // (
    case coma // ,
    case number(Int)
    case closeBrace // )
    case mul // mul
    case doToken // don't
    case dont // do
    case corrupted
}

func getValidTokens(from string: String) -> [Token] {
    var position = string.startIndex
    var tokens: [Token] = []
    while position < string.endIndex {
        var token: Token = .corrupted
        switch string[position] {
        case "(":
            consume("(", in: string, at: &position)
            token = .openBrace
        case ")":
            consume(")", in: string, at: &position)
            token = .closeBrace
        case ",":
            consume(",", in: string, at: &position)
            token = .coma
        case "m":
            if attemptParse("mul", in: string, at: &position) {
                token = .mul
            }
        case "d":
            if attemptParse("don't", in: string, at: &position) {
                token = .dont
            } else if attemptParse("do", in: string, at: &position) {
                token = .doToken
            }
        case "0"..."9":
            token = .number(parseNumber(in: string, at: &position))
        default:
            break
        }
        tokens.append(token)
        if token == .corrupted {
            _ = consumeNextChar(in: string, at: &position)
        }
    }
    return tokens
}

func attemptParse(_ text: String, in string: String, at position: inout String.Index) -> Bool {
    var tmpPosition = position

    for letter in text {
        guard attemptParse(letter, in: string, at: &tmpPosition) else { return false }
    }

    position = tmpPosition
    return true
}

func attemptParse(_ character: Character, in string: String, at position: inout String.Index) -> Bool {
    guard position < string.endIndex, string[position] == character else { return false }
    position = string.index(after: position)
    return true
}

func parseNumber(in string: String, at position: inout String.Index) -> Int {
    var stringNumber: [Character] = []
    var tmpPosition = position
    loop: while tmpPosition < string.endIndex {
        switch string[tmpPosition] {
        case "0"..."9":
            stringNumber.append(string[tmpPosition])
        default:
            break loop
        }
        tmpPosition = string.index(after: tmpPosition)
    }
    position = tmpPosition
    return Int(String(stringNumber))!
}

func consumeNextChar(in string: String, at position: inout String.Index) -> Character {
    defer { position = string.index(after: position) }
    return string[position]
}

func consume(_ character: Character, in string: String, at position: inout String.Index) {
    precondition(string[position] == character)
    position = string.index(after: position)
}

main()
