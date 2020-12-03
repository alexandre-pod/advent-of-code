import Foundation

func main() {
    var map: [[Bool]] = []
    var mapWidth = -1
    while let line = readLine() {
        if mapWidth == -1 {
            mapWidth = line.count
        }
        assert(line.count == mapWidth)
        map.append(line.map { $0 == "#" })
    }
    let mapHeight = map.count
    
    // part 1
    let count_3_1 = countTrees(map: map, width: mapWidth, height: mapHeight, slopeX: 3, slopeY: 1)
    print("x: 3, y:1 : \(count_3_1)")
    
    // part 2
    let count_1_1 = countTrees(map: map, width: mapWidth, height: mapHeight, slopeX: 1, slopeY: 1)
    print("x: 1, y:1 : \(count_1_1)")
    let count_5_1 = countTrees(map: map, width: mapWidth, height: mapHeight, slopeX: 5, slopeY: 1)
    print("x: 5, y:1 : \(count_5_1)")
    let count_7_1 = countTrees(map: map, width: mapWidth, height: mapHeight, slopeX: 7, slopeY: 1)
    print("x: 7, y:1 : \(count_7_1)")
    let count_1_2 = countTrees(map: map, width: mapWidth, height: mapHeight, slopeX: 1, slopeY: 2)
    print("x: 1, y:2 : \(count_1_2)")


    print(count_3_1 * count_1_1 * count_5_1 * count_7_1 * count_1_2)
}

func partOne() {
    
}

func countTrees(map: [[Bool]], width: Int, height: Int, slopeX: Int, slopeY: Int) -> Int {
    var currentPos = (x: 0, y: 0)
    var treeCount = 0

    while currentPos.y < height {
        if map[currentPos.y][currentPos.x % width] {
            treeCount += 1
        }
        currentPos = (x: currentPos.x + slopeX, y: currentPos.y + slopeY)
    }
    
    return treeCount
}





main()
