//
//  polygonArea.swift
//  
//
//  Created by Alexandre Podlewski on 18/12/2023.
//

import Foundation

func polygonArea(_ segments: [Segment]) -> Int {
    let allY: [Int] = Set(segments.lazy.flatMap { [$0.minPoint.y, $0.maxPoint.y] }).sorted()

    var boundingRects: [Rect] = []

    for (y, nextY) in zip(allY, allY.dropFirst() + [allY.last! + 1]) {
        let zoneHeight = nextY - y + 1

        let concernedSegments = segments
            .filter { $0.intersectY(y) }
            .sorted {
                $0.minX < $1.minX || ($0.minX == $1.minX && (!$0.isHorizontal || $1.isHorizontal))
            }
//        print(concernedSegments)

        let intersections = locateIntersections(in: concernedSegments, atY: y)
//        print(intersections)

        let insideSegments = insideSegments(from: intersections)
//        print(insideSegments)

        let volumeRects = insideSegments.map {
            Rect(start: Coordinates(x: $0.x1, y: y), width: $0.x2 - $0.x1 + 1, height: zoneHeight)
        }

        boundingRects.append(contentsOf: volumeRects)

    }

    return area(of: boundingRects)
}


func locateIntersections(in segments: [Segment], atY y: Int) -> [LocatedIntersection] {

    var result: [LocatedIntersection] = []
    var segmentIndex = 0

    while segmentIndex < segments.count {
        let segment = segments[segmentIndex]
        if segment.isHorizontal {
            let nextVertical = segments[segmentIndex + 1]
            if nextVertical.minY == y {
                result.append(LocatedIntersection(type: .rightDown, x: segment.maxX))
            } else if nextVertical.maxY == y {
                result.append(LocatedIntersection(type: .rightUp, x: segment.maxX))
            } else {
                fatalError("Impossible state")
            }
            segmentIndex += 2
        } else {
            if segment.minY == y {
                assert(segmentIndex + 1 == segments.count || segments[segmentIndex + 1].isHorizontal)
                result.append(LocatedIntersection(type: .upRight, x: segment.minX))
            } else if segment.maxY == y {
                assert(segmentIndex + 1 == segments.count || segments[segmentIndex + 1].isHorizontal)
                result.append(LocatedIntersection(type: .downRight, x: segment.minX))
            } else {
                result.append(LocatedIntersection(type: .flat, x: segment.minX))
            }
            segmentIndex += 1
        }
    }

    return result
}

struct LocatedIntersection {
    let type: Intersection
    let x: Int
}

enum Intersection {
    case flat
    case upRight
    case downRight
    case rightDown
    case rightUp
}

func insideSegments(from intersections: [LocatedIntersection]) -> [(x1: Int, x2: Int)] {
    var result: [(x1: Int, x2: Int)] = []

    var isInside = false
    var zoneStartX = Int.min

    for intersection in intersections {
        switch intersection.type {
        case .flat:
            if isInside {
                result.append((x1: zoneStartX, x2: intersection.x))
                isInside = false
            } else {
                isInside = true
                zoneStartX = intersection.x
            }
        case .upRight:
            if isInside {
                result.append((x1: zoneStartX, x2: intersection.x))
                isInside = false
            } else {
                zoneStartX = intersection.x
                isInside = true
            }
        case .downRight:
            // no-op - does not change inside / outside state
            break
        case .rightDown:
            if isInside {
                result.append((x1: zoneStartX, x2: intersection.x))
                isInside = false
            } else {
                zoneStartX = intersection.x
                isInside = true
            }
        case .rightUp:
            // no-op - does not change inside / outside state
            break
        }
    }

    assert(!isInside)

    return result
}

func area(of rects: [Rect]) -> Int {
    let areaWithOverlap = rects
        .map { $0.width * $0.height }
        .reduce(0, +)
    let overlapArea = pairs(from: rects)
        .compactMap { $0.0.intersection(with: $0.1) }
        .map { $0.width * $0.height }
        .reduce(0, +)
    return areaWithOverlap - overlapArea
}

func pairs<T>(from array: [T]) -> [(T, T)] {
    var pairs: [(T, T)] = []

    for i1 in 0..<(array.count - 1) {
        for i2 in (i1 + 1)..<array.count {
            pairs.append((array[i1], array[i2]))
        }
    }

    return pairs
}
