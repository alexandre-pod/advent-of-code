//
//  CyclicLinkedList.swift
//  
//
//  Created by Alexandre Podlewski on 23/12/2020.
//

import Foundation

class CyclicLinkedList<T> {

    private let initialNode: Node<T>

    private init(initialNode: Node<T>) {
        self.initialNode = initialNode

        initialNode.next = initialNode
        initialNode.previous = initialNode
    }

    internal init(values: [T]) {
        precondition(!values.isEmpty)

        let nodes = values.map { Node(value: $0) }

        zip(nodes, nodes[1...]).forEach {
            let (current, next) = $0
            current.next = next
            next.previous = current
        }

        let initialNode = nodes.first!
        let finalNode = nodes.last!

        initialNode.previous = finalNode
        finalNode.next = initialNode

        self.initialNode = initialNode
    }

    deinit {
        let node = initialNode
        node.next = nil
    }

    func add(contentsOf nodes: [Node<T>], after node: Node<T>) {
        zip(nodes, [node] + nodes).forEach { next, previous in
            self.add(next, after: previous)
        }
    }

    func add(_ newNode: Node<T>, after node: Node<T>) {
        newNode.previous = node
        newNode.next = node.next
        node.next?.previous = newNode
        node.next = newNode
    }

    func removeNode(_ node: Node<T>) {
        node.previous?.next = node.next
        node.next?.previous = node.previous
        node.next = nil
        node.previous = nil
    }

    func removeNodes(number: Int, after node: Node<T>) -> [Node<T>] {
        var result: [Node<T>] = []
        while result.count < number, let nextNode = node.next {
            removeNode(nextNode)
            result.append(nextNode)
        }
        return result
    }

    var nodes: [Node<T>] {
        var allNodes = [initialNode]
        var current = initialNode.next!
        while current !== initialNode {
            allNodes.append(current)
            current = current.next!
        }
        return allNodes
    }
}
