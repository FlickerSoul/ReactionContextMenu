//
//  HapticTouchDuration.swift
//  ReactionOverlay
//
//  Created by Larry Zeng on 11/7/25.
//

public enum HapticTouchDuration: CaseIterable {
    case fast
    case `default`
    case slow

    var duration: Double {
        switch self {
        case .fast: 0.2
        case .default: 0.3
        case .slow: 0.4
        }
    }

    public var description: String {
        switch self {
        case .fast: "Fast"
        case .default: "Default"
        case .slow: "Slow"
        }
    }
}
