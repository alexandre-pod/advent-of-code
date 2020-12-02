import Foundation

func partOne(from values: [Int]) {
    let valuesSet = Set(values)
    if let result = getValues(summingTo: 2020, in: valuesSet) {
        print("\(result.0) * \(result.1) = \(result.0 * result.1)")
    } else {
        print("not found")
    }
}

func getValues(summingTo sumValue: Int, in values: Set<Int>) -> (Int, Int)? {
    for value in values {
        let complementToSumValue = sumValue - value
        if values.contains(complementToSumValue) {
            return (value, complementToSumValue)
        }
    }
    return nil
}

func partTwo(from values: [Int]) {
    let valuesSet = Set(values)
    for value in valuesSet {
        let target = 2020 - value
        if let result = getValues(summingTo: target, in: valuesSet) {
            print("\(value) * \(result.0) * \(result.1) = \(value * result.0 * result.1)")
            return
        }
    }
}

var values: [Int] = []
while let line = readLine() {
    values.append(Int(line)!)
}
partOne(from: values)
partTwo(from: values)
