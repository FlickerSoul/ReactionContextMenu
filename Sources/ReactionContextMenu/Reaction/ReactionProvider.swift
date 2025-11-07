//
//  ReactionProvider.swift
//  ReactionOverlay
//
//  Created by Larry Zeng on 11/7/25.
//

public protocol ReactionProvider {
    func reactions() -> [String]
}

public struct DefaultReactionProvider: ReactionProvider {
    public func reactions() -> [String] {
        ["👍", "❤️", "😂", "😮", "😢", "🙏", "🤣", "👏", "🥰"]
    }
}
