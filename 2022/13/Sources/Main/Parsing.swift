import Foundation

func parsePacket(from line: String) -> Packet? {
    let tokenProvider = TokenProvider(tokens: packetTokens(from: line))
    do {
        try tokenProvider.consumeToken(.listStart)

        var values: [PacketContent] = []
        while tokenProvider.currentToken != .listEnd {
            values.append(try parsePacketContent(from: tokenProvider))
            if tokenProvider.currentToken == .coma {
                try tokenProvider.consumeToken(.coma)
            }
        }

        try tokenProvider.consumeToken(.listEnd)

        return Packet(content: values)
    } catch {
        print(error)
        return nil
    }
}

func parsePacketContent(
    from tokenProvider: TokenProvider
) throws -> PacketContent {
    switch tokenProvider.currentToken {
    case .listStart:
        try tokenProvider.consumeToken(.listStart)
        var values: [PacketContent] = []
        while tokenProvider.currentToken != .listEnd {
            values.append(try parsePacketContent(from: tokenProvider))
            if tokenProvider.currentToken == .coma {
                try tokenProvider.consumeToken(.coma)
            }
        }
        try tokenProvider.consumeToken(.listEnd)
        return .list(values)
    case let .number(value):
        try tokenProvider.consumeToken(tokenProvider.currentToken)
        return .integer(value)

    case .listEnd, .coma, .endOfFile:
        throw SyntaxError.invalidSyntax(withToken: tokenProvider.currentToken)
    }
}

enum PacketToken: Equatable {
    case listStart
    case listEnd
    case coma
    case number(Int)
    case endOfFile
}

enum ParsingError: Error {
    case unexpectedToken(expecting: PacketToken, got: PacketToken)
}

enum SyntaxError: Error {
    case invalidSyntax(withToken: PacketToken)
}

class TokenProvider {
    private let tokens: [PacketToken]
    private var currentTokenIndex: Int

    init(tokens: [PacketToken]) {
        self.tokens = tokens
        self.currentTokenIndex = 0
    }

    var currentToken: PacketToken {
        guard tokens.indices.contains(currentTokenIndex) else { return .endOfFile }
        return tokens[currentTokenIndex]
    }

    func consumeToken(_ token: PacketToken) throws {
        guard token == currentToken else {
            throw ParsingError.unexpectedToken(expecting: token, got: currentToken)
        }
        currentTokenIndex += 1
    }
}

func packetTokens(from line: String) -> [PacketToken] {
    var tokens: [PacketToken] = []
    var currentIndex = line.startIndex
    while currentIndex < line.endIndex {
        switch line[currentIndex] {
        case "[":
            tokens.append(.listStart)
            currentIndex = line.index(after: currentIndex)
        case "]":
            tokens.append(.listEnd)
            currentIndex = line.index(after: currentIndex)
        case ",":
            tokens.append(.coma)
            currentIndex = line.index(after: currentIndex)
        case "0"..."9":
            var endNumberIndex = line.index(after: currentIndex)
            while endNumberIndex < line.endIndex, "0"..."9" ~= line[endNumberIndex] {
                let nextIndex = line.index(after: endNumberIndex)
                guard nextIndex != endNumberIndex else { break }
                endNumberIndex = nextIndex
            }
            let number = Int(String(line[currentIndex..<endNumberIndex]))!
            currentIndex = endNumberIndex
            tokens.append(.number(number))
        default:
            fatalError("Invalid character")
        }
    }

    return tokens
}
