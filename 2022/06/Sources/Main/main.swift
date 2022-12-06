import Foundation

func main() {
    let stream = readLine()!.map { $0 }

    print(part1(stream: stream))
    print(part2(stream: stream))
}

// MARK: - Part 1

class StartMarkerDetector {
    let length: Int
    
    private var collectedCharacters: [Character] = []
    
    init(length: Int) {
        self.length = length
    }
    
    func addCharacter(_ character: Character) {
        if collectedCharacters.count == length {
            collectedCharacters.remove(at: 0)
        }
        collectedCharacters.append(character)
    }
    
    func isValidStartMarker() -> Bool {
        return collectedCharacters.count == length && Set(collectedCharacters).count == length
    }
}

func part1(stream: [Character]) -> Int {
    var detector = StartMarkerDetector(length: 4)
    for (index, character) in stream.enumerated() {
        detector.addCharacter(character)
        if detector.isValidStartMarker() {
            return index + 1
        }
    }
    fatalError("No marker found")
}

// MARK: - Part 2

func part2(stream: [Character]) -> Int {
    var detector = StartMarkerDetector(length: 14)
    for (index, character) in stream.enumerated() {
        detector.addCharacter(character)
        if detector.isValidStartMarker() {
            return index + 1
        }
    }
    fatalError("No marker found")
}

main()
