//
//  CGRect+.swift
//  ReactionOverlay
//
//  Created by Larry Zeng on 11/7/25.
//
import SwiftUI

extension CGRect {
    func scaledVertically(by factor: CGFloat) -> CGRect {
        let newHeight = height * factor
        let heightDifference = newHeight - height
        let newY = origin.y - heightDifference / 2

        return CGRect(x: origin.x, y: newY, width: width, height: newHeight)
    }
}
