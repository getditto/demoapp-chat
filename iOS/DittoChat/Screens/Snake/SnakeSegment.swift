//
//  SnakeSegment.swift
//  Snake
//
//  Created by Shaunak Jagtap on 14/04/24.
//

import SwiftUI
// Model representing a segment of the snake
@available(macOS 10.15, *)
struct SnakeSegment: Hashable {
    var position: CGPoint
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(position.x)
        hasher.combine(position.y)
    }
    
    static func ==(lhs: SnakeSegment, rhs: SnakeSegment) -> Bool {
        return lhs.position == rhs.position
    }
}
