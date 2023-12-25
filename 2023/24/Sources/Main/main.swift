import Foundation

typealias Hails = [Hail]

struct Hail {
    let point: Vector3D
    let velocity: Vector3D
}

struct Vector3D: Equatable {
    let x: Double
    let y: Double
    let z: Double
}

func main() {
    var input: Hails = []

    while let line = readLine() {
        input.append(parseHail(from: line))
    }

    print(part1(hails: input))
    print(part2(hails: input))
}

func parseHail(from line: String) -> Hail {
    let parts = line.split(separator: "@").map { parseVector(from: String($0)) }
    return Hail(point: parts[0], velocity: parts[1])
}

func parseVector(from string: String) -> Vector3D {
    let parts = string.filter { $0 != " " }
        .split(separator: ",")
        .map { Int(String($0))! }
        .map { Double($0) }
    return Vector3D(x: parts[0], y: parts[1], z: parts[2])
}

// MARK: - Part 1

func part1(hails: Hails) -> Int {
//    hails.forEach { print($0) }

//    print(hails[0], hails[1])
//    let collision = hails[0].collisionPointIgnoringZ(with: hails[1])
//    print("collision ?", collision)

    var collideInZone = 0

    // input zone
    let xZone: ClosedRange<Double> = 200000000000000...400000000000000
    let yZone: ClosedRange<Double> = 200000000000000...400000000000000

    // Sample zone
//    let xZone: ClosedRange<Double> = 7...27
//    let yZone: ClosedRange<Double> = 7...27

    for i1 in 0..<(hails.count - 1) {
        for i2 in (i1 + 1)..<hails.count {
//            print("checking \(hails[i1]), \(hails[i2])")
            guard let collision = hails[i1].pathCollision(with: hails[i2], ignoringZ: true) else { continue }

//            print(" - \(collision)")

            if xZone.contains(collision.x), yZone.contains(collision.y) {
                collideInZone += 1
            }

//            print("collision ?", collision)
        }
    }

    return collideInZone

    fatalError()
}

extension Hail {

//    func collisionPoint(with other: Hail, ignoringZ: Bool) -> Vector3D? {
//        let x1 = self.point.x
//        let y1 = self.point.y
//        let vx1 = self.velocity.x
//        let vy1 = self.velocity.y
//        let x2 = other.point.x
//        let y2 = other.point.y
//        let vx2 = other.velocity.x
//        let vy2 = other.velocity.y
//
//        let dvx = vx1 - vx2
//        let dvy = vy1 - vy2
////        let dvx = vx2 - vx1
////        let dvy = vy2 - vy1
//
//        guard dvx != 0 || x1 == x2 else { return nil }
//        guard dvy != 0 || y1 == y2 else { return nil }
//        /*
//
//
//         x1 + t * vx1 = x2 + t * vx2
//         t = (x2 - x1) / (vx1 - vx2)
//         t = (y2 - y1) / (vy1 - vy2)
//
//         */
//
//
//        if x1 == x2 {
////            print("1")
//            guard vx1 == vx2 else { return nil }
//            guard vy1 != vy2 else { return nil }
//            let collisionTime = (y2 - y1) / (vy1 - vy2)
//            return self.position(after: collisionTime)
//        }
//
//        if y1 == y2 {
////            print("2")
//            guard vy1 == vy2 else { return nil }
//            guard vx1 != vx2 else { return nil }
//            let collisionTime = (x2 - x1) / (vx1 - vx2)
//            return self.position(after: collisionTime)
//        }
//
//        let collisionTimeX = (x2 - x1) / (vx1 - vx2)
//        let collisionTimeY = (y2 - y1) / (vy1 - vy2)
//
//        print("(x2 - x1) / (vx1 - vx2)", (x2 - x1), (vx1 - vx2))
//        print("collisionTimeX", collisionTimeX)
//        print("(y2 - y1) / (vy1 - vy2)", (y2 - y1), (vy1 - vy2))
//        print("collisionTimeY", collisionTimeY)
//
//        guard collisionTimeX == collisionTimeY else { return nil }
//
//        return self.position(after: collisionTimeX)
//
//
//        let t1: Double? = dvx != 0 ? (x2 - x1) / dvx : nil
//        let t2: Double? = dvy != 0 ? (y2 - y1) / dvy : nil
//
////        print(self, other)
//        print("t1, t2:", t1 ?? -1, t2 ?? -1)
//
//        if let t1, t1 > 0 {
//            if let t2, t1 != t2 { return nil }
//            let p1 = self.position(after: t1)
//            let p2 = other.position(after: t1)
//
//
//            print("interssect t1 ?", p1, p2, t1)
//            return p1
//        }
//
//        if let t2, t2 > 0 {
//            if let t1, t1 != t2 { return nil }
//            let p1 = self.position(after: t2)
//            let p2 = other.position(after: t2)
//
//            print("interssect t2 ?", p1, p2, t2)
//            return p1
//        }
//
//
//        return nil
//    }

    func position(after time: Double) -> Vector3D {
        Vector3D(
            x: point.x + velocity.x * time,
            y: point.y + velocity.y * time,
            z: point.z + velocity.z * time
        )
    }

    func pathCollision(with other: Hail, ignoringZ: Bool, ignoringPast: Bool = false) -> Vector3D? {
//    func collisionPoint(with other: Hail, ignoringZ: Bool) -> Vector3D? {
        let x1 = self.point.x
        let y1 = self.point.y
        let vx1 = self.velocity.x
        let vy1 = self.velocity.y
        let x2 = other.point.x
        let y2 = other.point.y
        let vx2 = other.velocity.x
        let vy2 = other.velocity.y

        guard vy1 != 0 else {
            if vy2 == 0 { return nil }
            return other.pathCollision(with: self, ignoringZ: ignoringZ, ignoringPast: ignoringPast)
        }

        let bDenominator = vy2 * vx1 - vx2 * vy1

        guard bDenominator != 0 else {
            return nil // is this really true ?
        }

        let bNumerator = (x2 - x1) * vy1 - (y2 - y1) * vx1

        let b = bNumerator / bDenominator

        let a: Double
        if vx1 != 0 {
            a = (x2 - x1 + b * vx2) / vx1
        } else if vy1 != 0 {
            a = (y2 - y1 + b * vy2) / vy1
        } else {
            return nil
        }

        let intersection1 = Vector3D(x: x1 + a * vx1, y: y1 + a * vy1, z: self.point.z + a * velocity.z)
        let intersection2 = Vector3D(x: x2 + b * vx2, y: y2 + b * vy2, z: other.point.z + b * other.velocity.z)

        if !ignoringPast && (a < 0 || b < 0) { // time only goes in one direction
            return nil
        }

        if ignoringZ {
//            print("intersection1: ", intersection1)
//            print("intersection2: ", intersection2)
//            assert(intersection1.x.isEqual(to: intersection2.x, errorMargin: 0.1))
//            assert(intersection1.y.isEqual(to: intersection2.y, errorMargin: 0.1))
            return intersection1
        } else {
            if intersection1.z.isEqual(to: intersection2.z, errorMargin: 10) {
                return intersection1
            } else {
                return nil
            }
        }

    }
}

extension Double {
    func isEqual(to other: Double, errorMargin: Double) -> Bool {
        return abs(self - other) < errorMargin
    }
}

extension Vector3D {
    func withZ(_ newZ: Double) -> Vector3D {
        Vector3D(x: x, y: y, z: newZ)
    }
}


// MARK: - Part 2

func part2(hails: Hails) -> Int {


    let expectedAnswer = Hail(point: Vector3D(x: 24, y: 13, z: 10), velocity: Vector3D(x: -3, y: 1, z: 2))
//    for hail in hails {
//        print("collidingPosition", hail.collidingPosition(with: expectedAnswer))
//    }

//    var collideInZone = 0

//    var currentHails = hails
    var currentHails = Array(hails[0..<3])

    var startTime = 0

    while true && startTime < 1000000 {
        if startTime % 1000 == 0 {
            print("startTime", startTime)
        }

            if let stone = findStoneBreaker(from: currentHails[0], to: currentHails[1], hails: currentHails, maxDuration: 100000) {
                let startPoint = stone.after(time: -startTime).point
                print("Start point", startPoint)
                return Int(startPoint.x + startPoint.y + startPoint.z)
            }
            if let stone = findStoneBreaker(from: currentHails[1], to: currentHails[0], hails: currentHails, maxDuration: 100000) {
                let startPoint = stone.after(time: -startTime).point
                print("Start point", startPoint)
                return Int(startPoint.x + startPoint.y + startPoint.z)
            }

//        let firstHail = currentHails[0]
//        let secondHail = currentHails[1]

//        let firstHail = currentHails[1]
//        let secondHail = currentHails[0]
//
//        let candidatesVelocities = firstHail.point.collidingVelocities(with: secondHail, maxDuration: 100000)
//
//        for candidate in candidatesVelocities {
//
//            if candidate == expectedAnswer.velocity {
//                print("Expecting velocity to success")
//
//            }
//
//            let stone = Hail(point: firstHail.point, velocity: candidate)
//
//            let allCollides = currentHails.allSatisfy {
//                $0.collidingPosition(with: stone) != nil
////                $0.pathCollision(with: stone, ignoringZ: false, ignoringPast: false) != nil
//            }
//
//            if allCollides {
//                print("startTime", startTime)
//                print("Possible matching: \(candidate)")
//                print("Start point", stone.after(time: -startTime).point)
//
//                fatalError("valid result ?")
//            }
//
//        }

        currentHails = currentHails.map { $0.after(time: 1) }

        startTime += 1



    }

//    let aaa = firstHail.point.collidingVelocities(with: secondHail, maxDuration: 1000)

//    print(aaa)



    // input zone
//    let xZone: ClosedRange<Double> = 200000000000000...400000000000000
//    let yZone: ClosedRange<Double> = 200000000000000...400000000000000

    // Sample zone
    //    let xZone: ClosedRange<Double> = 7...27
    //    let yZone: ClosedRange<Double> = 7...27

//    for i1 in 0..<(hails.count - 1) {
//        for i2 in (i1 + 1)..<hails.count {
//            print("checking \(hails[i1]), \(hails[i2])")
//            guard let collision = hails[i1].pathCollision(with: hails[i2], ignoringZ: false) else { continue }
//            print(" - \(collision)")
//
////            if xZone.contains(collision.x), yZone.contains(collision.y) {
////                collideInZone += 1
////            }
//
//            //            print("collision ?", collision)
//        }
//    }

//    return collideInZone

    fatalError()

    fatalError()
}

func findStoneBreaker(from firstHail: Hail, to secondHail: Hail, hails currentHails: Hails, maxDuration: Int) -> Hail? {
    let candidatesVelocities = firstHail.point.collidingVelocities(with: secondHail, maxDuration: maxDuration)

    for candidate in candidatesVelocities {
        let stone = Hail(point: firstHail.point, velocity: candidate)

        let allCollides = currentHails.allSatisfy { $0.collidingPosition(with: stone) != nil }

        if allCollides {

            return stone

//            print("startTime", startTime)
//            print("Possible matching: \(candidate)")
//            print("Start point", stone.after(time: -startTime).point)
//
//            fatalError("valid result ?")
        }

    }
    return nil
}

extension Hail {
    func after(time: Int) -> Hail {
        Hail(
            point: Vector3D(
                x: point.x + Double(time) * velocity.x,
                y: point.y + Double(time) * velocity.y,
                z: point.z + Double(time) * velocity.z
            ),
            velocity: velocity
        )
    }

    func collidingPosition(with other: Hail) -> Vector3D? {


        /*
         x1 + t * vx1 == x2 + t * vx2

         t = (x2 - x1) / (vx1 - vx2)
         */

        let x1 = self.point.x
        let y1 = self.point.y
        let z1 = self.point.z
        let vx1 = self.velocity.x
        let vy1 = self.velocity.y
        let vz1 = self.velocity.z
        let x2 = other.point.x
        let y2 = other.point.y
        let z2 = other.point.z
        let vx2 = other.velocity.x
        let vy2 = other.velocity.y
        let vz2 = other.velocity.z

        let tX = vx1 != vx2 ? (x2 - x1) / (vx1 - vx2) : nil
        let tY = vy1 != vy2 ? (y2 - y1) / (vy1 - vy2) : nil
        let tZ = vz1 != vz2 ? (z2 - z1) / (vz1 - vz2) : nil

//        print("vx1 - vx2", vx1 - vx2)
//        print("vy1 - vy2", vy1 - vy2)
//        print("vz1 - vz2", vz1 - vz2)
//
//
//        print("tX", tX)
//        print("tY", tY)
//        print("tZ", tZ)

        let nonNilTimes = [tX, tY, tZ].compactMap { $0 }
//        print(nonNilTimes)

        guard !nonNilTimes.isEmpty, nonNilTimes.allSatisfy({ $0 == nonNilTimes.first }) else {
            return nil
        }
        return self.position(after: nonNilTimes.first!)
    }
}

extension Vector3D {
    func collidingVelocities(with hail: Hail, maxDuration: Int) -> [Vector3D] {
        (1...maxDuration).compactMap { intTime -> Vector3D? in
            let time = Double(intTime)
            let vx = Int(hail.point.x) + intTime * Int(hail.velocity.x) - Int(self.x)
            let vy = Int(hail.point.y) + intTime * Int(hail.velocity.y) - Int(self.y)
            let vz = Int(hail.point.z) + intTime * Int(hail.velocity.z) - Int(self.z)

            guard 
                vx.isMultiple(of: intTime),
                vy.isMultiple(of: intTime),
                vz.isMultiple(of: intTime)
            else { return nil }

            return Vector3D(
                x: Double(vx / intTime),
                y: Double(vy / intTime),
                z: Double(vz / intTime)
            )
        }
    }

//    func collidingVelocitiesNEW(with hail: Hail, maxDuration: Int) -> [Vector3D] {
//        (1...maxDuration).compactMap { intTime -> Vector3D? in
//            let time = Double(intTime)
//            let vx = Int(hail.point.x) + intTime * Int(hail.velocity.x) - Int(self.x)
//            let vy = Int(hail.point.y) + intTime * Int(hail.velocity.y) - Int(self.y)
//            let vz = Int(hail.point.z) + intTime * Int(hail.velocity.z) - Int(self.z)
//
//            guard
//                vx.isMultiple(of: intTime),
//                vy.isMultiple(of: intTime),
//                vz.isMultiple(of: intTime)
//            else { return nil }
//
//            return Vector3D(
//                x: Double(vx / intTime),
//                y: Double(vy / intTime),
//                z: Double(vz / intTime)
//            )
//        }
//    }
}

//extension Hail {}

main()
