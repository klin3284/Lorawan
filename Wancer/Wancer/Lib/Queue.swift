//
//  Queue.swift
//  Wancer
//
//  Created by Kenny Lin on 3/26/24.
//

import SwiftUI

struct Queue<T> {
    private var elements: [T] = []

    mutating func enqueue(_ element: T) {
        elements.append(element)
    }

    mutating func dequeue() -> T? {
        guard !elements.isEmpty else {
            return nil
        }
        return elements.removeFirst()
    }

    var isEmpty: Bool {
        elements.isEmpty
    }

    var count: Int {
        elements.count
    }
}
