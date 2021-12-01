import Foundation

func main() {
    let cardPublicKey = Int(readLine()!)!
    let doorPublicKey = Int(readLine()!)!

    part1(cardPublicKey: cardPublicKey, doorPublicKey: doorPublicKey)
    part2()
}

// MARK: - Part 1

func part1(cardPublicKey: Int, doorPublicKey: Int) {
    let cardSecretLoopSize = findPrivateLoopNumber(forPublicKey: cardPublicKey)
//    let doorSecretLoopSize = findPrivateLoopNumber(forPublicKey: doorPublicKey)

//    print(cardSecretLoopSize)
//    print(doorSecretLoopSize)

    let cardEncryptionKey = transform(subjectNumber: doorPublicKey, loopSize: cardSecretLoopSize)
//    let doorEncryptionKey = transform(subjectNumber: cardPublicKey, loopSize: doorSecretLoopSize)

    print("answer: \(cardEncryptionKey)")
//    print(doorEncryptionKey)
}

func findPrivateLoopNumber(forPublicKey publicKey: Int) -> Int {
    let subjectNumber = 7
    var value = 1
    var loopCount = 0

    while value != publicKey {
        value = (value * subjectNumber) % 20201227
        loopCount += 1
    }

    return loopCount
}

func transform(subjectNumber: Int, loopSize: Int) -> Int {
    var value = 1
    for _ in 1...loopSize {
        value = (value * subjectNumber) % 20201227
    }
    return value
}

// MARK: - Part 2

func part2() {
    print("You just need to click on the button with the 49 previous stars !")
}

main()
