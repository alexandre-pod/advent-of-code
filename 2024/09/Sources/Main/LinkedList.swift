//
//  LinkedList.swift
//  Main
//
//  Created by Alexandre Podlewski on 09/12/2024.
//

final class Node<Value> {
    var value: Value
    var next: Node<Value>?
    var previous: Node<Value>?

    init(value: Value, next: Node<Value>? = nil, previous: Node<Value>? = nil) {
        self.value = value
        self.next = next
        self.previous = previous

        assert(next?.previous == nil)
        next?.previous = self
        assert(previous?.next == nil)
        previous?.next = self
    }
}

extension Node {
    convenience init?(from sequence: [Value]) {
        guard let first = sequence.first else {
            return nil
        }
        self.init(value: first)
        var lastNode = self

        for value in sequence.dropFirst() {
            lastNode = Node(value: value, previous: lastNode)
        }
    }
}

extension Node {
    func insertBefore(_ node: Node<Value>) {
        assert(node.previous == nil && node.next == nil)
        node.previous = previous
        node.next = self
        previous?.next = node
        previous = node
    }

    func insertAfter(_ node: Node<Value>) {
        assert(node.previous == nil && node.next == nil)
        node.next = next
        node.previous = self
        next?.previous = node
        next = node
    }

    func removeFromList() {
        previous?.next = next
        next?.previous = previous
        next = nil
        previous = nil
    }
}

extension Node {

    var last: Node {
        var current = self
        while let next = current.next {
            current = next
        }
        return current
    }

    /// `contition` should not update self
    func findFirst(before lastNode: Node, where condition: (Node) -> Bool) -> Node? {
        for candidate in sequence(first: self, next: \.next) {
            if candidate === lastNode { return nil }
            if condition(candidate) { return candidate }
        }
        return nil
    }
}

// MARK: - Printable

extension Node where Value: CustomStringConvertible {
    func printList() {
        for node in sequence(first: self, next: \.next) {
            print("\(node.value)", terminator: " -> ")
        }
        print()
    }
}
