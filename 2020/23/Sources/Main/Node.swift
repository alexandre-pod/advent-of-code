//
//  Node.swift
//  
//
//  Created by Alexandre Podlewski on 23/12/2020.
//

import Foundation

public class Node<T> {
    var value: T
    var next: Node?
    weak var previous: Node?

    public init(value: T) {
        self.value = value
    }
}
