import Foundation

enum ChunkType {
    case parentheses
    case brackets
    case accolade
    case chevron
}

struct Chunk {
    let type: ChunkType
    let content: [Chunk]
}

enum ParsingError: Error {
    case unexpectedCharacter(Character)
    case illegalToken(ChunkType)
    case endOfString(expectedClosingTypes: [ChunkType])
}

// MARK: - Main

func main() {

    var lines: [String] = []

    while let line = readLine() {
        lines.append(line)
    }

    print(part1(lines: lines))
    print(part2(lines: lines))
}

// MARK: - Part 1

func part1(lines: [String]) -> Int {
    return lines.map { parse(line: $0) }.reduce(0, +)
}

func parse(line: String) -> Int {

    let result = parseSubString(line: line[line.startIndex...])

    switch result {
    case .success:
        return 0
    case .failure(let error):
        if case .illegalToken(let type) = error {
            return type.illegalTokenPoints
        } else {
            return 0
        }
    }
}

func parseSubString(line: Substring) -> Result<(Chunk, Substring.Index?), ParsingError> {
    guard let first = line.first else { return .failure(.endOfString(expectedClosingTypes: [])) }

    let chunkType = try! chunkType(for: first)
    guard try! isChunkOpenning(for: first) else { return .failure(.illegalToken(chunkType)) }

    var content: [Chunk] = []
    var nextIndex: Substring.Index = line.index(line.startIndex, offsetBy: 1)

    while
        nextIndex < line.endIndex,
        try! isChunkOpenning(for: line[nextIndex])
    {
        switch parseSubString(line: line[nextIndex...]) {
        case .failure(let error):
            switch error {
            case .endOfString(let expectedClosingTypes):
                return .failure(.endOfString(expectedClosingTypes: expectedClosingTypes + [chunkType]))
            default:
                return .failure(error)
            }
        case let .success((chunk, endIndex)):
            content.append(chunk)
            guard let endIndex = endIndex else {
                return .failure(.endOfString(expectedClosingTypes: [chunkType]))
            }
            nextIndex = endIndex
        }
    }

    guard nextIndex < line.endIndex else {
        return .failure(.endOfString(expectedClosingTypes: [chunkType]))
    }

    let closingChunkType = try! Main.chunkType(for: line[nextIndex])

    if closingChunkType != chunkType {
        return .failure(.illegalToken(closingChunkType))
    } else {
        return .success((
            Chunk(type: chunkType, content: content),
            nextIndex == line.endIndex ? nil : line.index(nextIndex, offsetBy: 1)
        ))
    }
}

func chunkType(for character: Character) throws -> ChunkType {
    switch character {
    case "(", ")":
        return .parentheses
    case "[", "]":
        return .brackets
    case "{", "}":
        return .accolade
    case "<", ">":
        return .chevron
    default:
        throw ParsingError.unexpectedCharacter(character)
    }
}

func isChunkOpenning(for character: Character) throws -> Bool {
    switch character {
    case "(", "[", "{", "<":
        return true
    case ")", "]", "}", ">":
        return false
    default:
        throw ParsingError.unexpectedCharacter(character)
    }
}

extension ChunkType {
    var illegalTokenPoints: Int {
        switch self {
        case .parentheses:
            return 3
        case .brackets:
            return 57
        case .accolade:
            return 1197
        case .chevron:
            return 25137
        }
    }
}

// MARK: - Part 2

func part2(lines: [String]) -> Int {

    let scores = lines.compactMap { parsePart2(line: $0) }.sorted()

    return scores[(scores.count) / 2]
}

func parsePart2(line: String) -> Int? {

    let result = parseSubString(line: line[line.startIndex...])

    switch result {
    case .success:
        return nil
    case .failure(let error):
        if case .endOfString(let expectedClosingTypes) = error {
            return expectedClosingTypes.map(\.missingTokenPoints).reduce(0) { $0 * 5 + $1 }
        } else {
            return nil
        }
    }
}

extension ChunkType {
    var missingTokenPoints: Int {
        switch self {
        case .parentheses:
            return 1
        case .brackets:
            return 2
        case .accolade:
            return 3
        case .chevron:
            return 4
        }
    }
}

main()
