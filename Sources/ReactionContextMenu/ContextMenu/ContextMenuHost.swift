//
//  ContextMenuHost.swift
//  ReactionOverlay
//
//  Created by Larry Zeng on 11/7/25.
//
import SwiftUI

@available(iOS 17, *)
public struct ContextMenuHost: ViewModifier {
    @StateObject private var contextMenuVM: ContextMenuViewModel

    public init(contextMenuVM: ContextMenuViewModel = .shared) {
        _contextMenuVM = .init(wrappedValue: contextMenuVM)
    }

    public func body(content: Content) -> some View {
        content
            .environmentObject(contextMenuVM)
            .overlay {
                overlay()
            }
    }

    @ViewBuilder
    private func overlay() -> some View {
        if contextMenuVM.showMenu, let presentedView = contextMenuVM.presentedView {
            ContextMenuOverlay(presentedView: presentedView)
                .environmentObject(contextMenuVM)
        }
    }
}
