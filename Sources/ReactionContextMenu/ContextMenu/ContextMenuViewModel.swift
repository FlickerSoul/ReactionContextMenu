//
//  ContextMenuViewModel.swift
//  ReactionOverlay
//
//  Created by Larry Zeng on 11/7/25.
//
import Combine
import SwiftUI

@MainActor
public class ContextMenuViewModel: ObservableObject {
    public static let shared = ContextMenuViewModel()

    struct PresentedView {
        typealias OnSelectionChange = @MainActor (String?) -> Void
        let view: AnyView
        let shapeInfo: ViewShapeInfo
        let menu: AnyView
        let appearingSide: ContextMenuAppearingSide
        let onSelectionChange: OnSelectionChange
    }

    @Published public private(set) var showMenu = false
    @Published private(set) var presentedView: PresentedView?
    @Published private(set) var dragLocation: CGPoint?
    @Published private(set) var reactionSelected: String?

    func showContextMenu(
        presentedView: PresentedView,
        reactionSelected: String?
    ) {
        self.reactionSelected = reactionSelected
        withAnimation(.easeOut(duration: 0.2)) {
            self.dragLocation = .zero
            self.presentedView = presentedView
            showMenu = true
        }
    }

    func hideContextMenu() {
        showMenu = false
    }

    func setDragLocation(_ location: CGPoint?) {
        dragLocation = location
    }

    func toggleReaction(_ reaction: String) {
        if reactionSelected == reaction {
            reactionSelected = nil
        } else {
            reactionSelected = reaction
        }

        presentedView?.onSelectionChange(reactionSelected)
    }
}
