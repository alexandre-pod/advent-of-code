import Foundation

typealias InputType = [Int]

func main() {
    let input: InputType = readLine()!.map { Int(String($0))! }

    print(part1(input: input))
    print(part2(input: input))
}

// MARK: - Part 1

func part1(input: InputType) -> Int {
    assert(!input.isEmpty)
//    print(input)
//    print(input.count)

    var checksum = 0

    var currentTransformedPosition = 0

    var currentIndexLeft = 0
    var remainingLeft = 0
    var currentIndexRight = input.count - 1
    var remainingRight = 0

    remainingLeft = input[currentIndexLeft]
    remainingRight = input[currentIndexRight]

    while currentIndexLeft < currentIndexRight {
        if currentIndexLeft % 2 == 0 {
            // left is space occupied
            if remainingLeft == 0 {
                currentIndexLeft += 1
                remainingLeft = input[currentIndexLeft]
            } else {
                let fileID = currentIndexLeft / 2
                checksum += fileID * currentTransformedPosition
//                print("[\(currentTransformedPosition)]: \(fileID) (from left)")
                currentTransformedPosition += 1
                remainingLeft -= 1
            }
        } else {
            // left is free space
            if currentIndexRight % 2 == 0 {
                // right is space occupied
                if remainingRight == 0 {
                    currentIndexRight -= 1
                    remainingRight = input[currentIndexRight]
                } else {
                    if remainingLeft > 0 {
                        let fileID = currentIndexRight / 2
                        checksum += fileID * currentTransformedPosition
//                        print("[\(currentTransformedPosition)]: \(fileID) (from right)")
                        currentTransformedPosition += 1
                        remainingRight -= 1
                        remainingLeft -= 1
                    } else {
                        currentIndexLeft += 1
                        remainingLeft = input[currentIndexLeft]
                    }
                }
            } else {
                // right is free space
                currentIndexRight -= 1
                remainingRight = input[currentIndexRight]
            }
        }
    }

    assert(currentIndexLeft == currentIndexRight)
    if currentIndexLeft % 2 == 0 {
        var remaining = min(remainingLeft, remainingRight)
        let fileID = currentIndexLeft / 2
        while remaining > 0 {
            checksum += fileID * currentTransformedPosition
            currentTransformedPosition += 1
            remaining -= 1
        }
    }
    return checksum
}

// MARK: - Part 2

func part2(input: InputType) -> Int {
    let list = Node(
        from: input.enumerated().map {
            DiskSpace(
                fileID: $0.offset % 2 == 0 ? $0.offset / 2 : nil,
                size: $0.element
            )
        }
    )!

//    list.printList()
//    print(list.aocDebugDescription())

    let lastNode = list.last
    var currentNode: Node<DiskSpace>? = lastNode

    while let node = currentNode {
        let previous = node.previous
        defer { currentNode = previous }
        guard node.value.fileID != nil else { continue }

        attemptMoveToLeft(node, in: list)
    }

//    list.printList()
//    print(list.aocDebugDescription())


    return list.checkSum()
}

func attemptMoveToLeft(_ file: Node<DiskSpace>, in list: Node<DiskSpace>) {
    guard let fileID = file.value.fileID else { return }
    let fileSize = file.value.size

    guard let freeSpace = list.findFirst(
        before: file,
        where: { $0.value.fileID == nil && $0.value.size >= fileSize }
    ) else { return }

    let remainingFreeSpace = freeSpace.value.size - fileSize

    if remainingFreeSpace > 0 {
        file.value.fileID = nil
        freeSpace.insertBefore(Node(value: DiskSpace(fileID: fileID, size: fileSize)))
        freeSpace.value.size = remainingFreeSpace

        // merge adjacent free spaces - not useful in our problem, and not perfect either
//        while let nextNode = file.next, nextNode.value.fileID == nil {
//            file.value.size += nextNode.value.size
//            nextNode.removeFromList()
//        }
//        if let previousNode = file.previous, previousNode.value.fileID == nil {
//            previousNode.value.size += file.value.size
//            file.removeFromList()
//        }

    } else {
        file.value.fileID = nil
        freeSpace.value.fileID = fileID
    }
}

extension Node<DiskSpace> {
    func checkSum() -> Int {
        var absolutePosition = 0
        var result = 0
        for node in sequence(first: self, next: \.next) {
            defer { absolutePosition += node.value.size }
            guard let fileID = node.value.fileID else { continue }
            let fileSize = node.value.size
//            print("[\(fileID), \(fileSize)] from \(absolutePosition)")
            let fileChecksum = (fileSize * (fileSize - 1) / 2 + fileSize * absolutePosition) * fileID
            result += fileChecksum
        }
        return result
    }

    func aocDebugDescription() -> String {
        return sequence(first: self, next: \.next).map {
            let character: Character
            if let fileID = $0.value.fileID {
                character = String(fileID).first!
            } else {
                character = "."
            }
            return String(Array(repeating: character, count: $0.value.size))
        }.joined()
    }
}

main()

struct DiskSpace {
    var fileID: Int?
    var size: Int
}

extension DiskSpace: CustomStringConvertible {

    var description: String {
        if let fileID {
            return "[\(size)] \(fileID)"
        } else {
            return "[\(size)] free"
        }
    }
}
