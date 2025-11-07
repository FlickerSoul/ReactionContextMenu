//
//  CustomContextMenuWrapper.swift
//  ReactionOverlay
//
//  Created by Larry Zeng on 11/7/25.
//
import SwiftUI

struct ViewShapeInfo: Equatable, Sendable {
    let size: CGSize
    let position: CGRect
}

public struct CustomContextMenuWrapper<Content: View, Menu: View>: View {
    let hapticTouchDuration: HapticTouchDuration
    let contextMenuAppearingSide: ContextMenuAppearingSide
    @Binding var selectedReaction: String?

    @ViewBuilder let content: Content
    @ViewBuilder let menu: Menu

    @State private var contentShapeInfo: ViewShapeInfo?
    @EnvironmentObject private var contextMenuVM: ContextMenuViewModel

    public init(
        hapticTouchDuration: HapticTouchDuration,
        contextMenuAppearingSide: ContextMenuAppearingSide,
        selectedReaction: Binding<String?>,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder menu: @escaping () -> Menu
    ) {
        self.hapticTouchDuration = hapticTouchDuration
        self.contextMenuAppearingSide = contextMenuAppearingSide
        _selectedReaction = selectedReaction
        self.content = content()
        self.menu = menu()
    }

    public var body: some View {
        content
            .onGeometryChange(for: ViewShapeInfo.self) { proxy in
                .init(
                    size: proxy.size,
                    position: proxy.frame(in: .global)
                )
            } action: { newValue in
                contentShapeInfo = newValue
            }
            .onLongPressGesture(minimumDuration: hapticTouchDuration.duration) {
                let impact = UIImpactFeedbackGenerator(style: .heavy)
                impact.impactOccurred()

                if let contentShapeInfo {
                    contextMenuVM.showContextMenu(
                        presentedView: .init(
                            view: AnyView(content),
                            shapeInfo: contentShapeInfo,
                            menu: AnyView(menu),
                            appearingSide: contextMenuAppearingSide
                        ) { newReaction in
                            selectedReaction = newReaction
                        },
                        reactionSelected: selectedReaction
                    )
                }
            }
            .simultaneousGesture(DragGesture(minimumDistance: 20, coordinateSpace: .global).onChanged { value in
                if contextMenuVM.showMenu {
                    contextMenuVM.setDragLocation(value.location)
                }
            }.onEnded { _ in
                if contextMenuVM.showMenu {
                    contextMenuVM.setDragLocation(nil)
                }
            })
    }
}
