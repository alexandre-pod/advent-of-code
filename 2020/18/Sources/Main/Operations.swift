//
//  Operations.swift
//  
//
//  Created by Alexandre Podlewski on 18/12/2020.
//

import Foundation

protocol Operation: CustomStringConvertible {
    func evaluate() -> Int
}

struct Value: Operation {
    let value: Int

    func evaluate() -> Int {
        return value
    }
}

struct Addition: Operation {
    let a: Operation
    let b: Operation

    func evaluate() -> Int {
        return a.evaluate() + b.evaluate()
    }
}

struct Multiplication: Operation {
    let a: Operation
    let b: Operation

    func evaluate() -> Int {
        return a.evaluate() * b.evaluate()
    }
}
