//
//  Array+sortedInsertion.swift
//  
//
//  Created by Alexandre Podlewski on 17/12/2023.
//

import Foundation

extension Array {
    mutating func sortedInsertion(
        of element: Element,
        using comparator: (Element, Element) -> Bool
    ) {
        let index = sortedInsertionIndex(of: element, using: comparator)
        insert(element, at: index)
    }

    private func sortedInsertionIndex(
        of element: Element,
        using comparator: (Element, Element) -> Bool
    ) -> Int {
        guard !isEmpty else { return 0 }
        guard comparator(element, self.last!) else { return count }
        var leftIndex = 0
        var rightIndex = count - 1

        while rightIndex - leftIndex > 1  {
            let midPoint = leftIndex + (rightIndex - leftIndex) / 2
            if comparator(element, self[midPoint]) {
                rightIndex = midPoint
            } else {
                leftIndex = midPoint
            }
        }
        return comparator(element, self[leftIndex]) ? leftIndex : rightIndex
    }
}
