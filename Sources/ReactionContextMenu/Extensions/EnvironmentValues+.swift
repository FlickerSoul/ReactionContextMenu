//
//  EnvironmentValues+.swift
//  ReactionOverlay
//
//  Created by Larry Zeng on 11/7/25.
//
import SwiftUI

extension EnvironmentValues {
    @Entry var isPresentedInContextMenu = false
    @Entry var menuEdgeInsets: EdgeInsets = .init()
    @Entry var dismissContextMenu: (ReactionChoice) -> Void = { _ in }
    @Entry public var reactionProvider: any ReactionProvider = DefaultReactionProvider()
}
