//
//  Int+Math.swift
//  
//
//  Created by Alexandre Podlewski on 20/12/2023.
//

import Foundation

func leastCommonMultiple(from numbers: [Int]) -> Int {
    var leastCommonMultipleFactors: [Int: Int] = [:]

    for number in numbers {
        number.primeFactors
            .reduce(into: [Int: Int]()) { primeFactors, factor in
                primeFactors[factor, default: 0] += 1
            }
            .forEach { (key: Int, value: Int) in
                leastCommonMultipleFactors[key] = max(leastCommonMultipleFactors[key] ?? 0, value)
            }
    }

    return leastCommonMultipleFactors
        .map { Int(pow(Double($0.key), Double($0.value))) }
        .reduce(1, *)
}

extension Int {
    var primeFactors: [Int] {
        let primes = primeNumbers(below: self)

        var remaining = self
        var factors: [Int] = []

        for prime in primes {
            while remaining.isMultiple(of: prime) {
                factors.append(prime)
                remaining = remaining / prime
            }
        }
        assert(remaining == 1)
        return factors
    }
}

/// if below is prime it will be returned
func primeNumbers(below maxValue: Int) -> some Sequence<Int> {
    var primeCandidates: Set<Int> = [2]
    primeCandidates.formUnion((3...maxValue).filter { $0 % 2 != 0 })

    var current = 3
    while current <= maxValue {
        defer { current += 1 }
        guard primeCandidates.contains(current) else { continue }
        var factor = 2
        while current * factor <= maxValue {
            primeCandidates.remove(current * factor)
            factor += 1
        }
    }


    return primeCandidates
}
