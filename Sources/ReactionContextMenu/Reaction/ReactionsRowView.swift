//
//  ReactionsRowView.swift
//  ReactionOverlay
//
//  Created by Larry Zeng on 11/7/25.
//
import SwiftUI

@available(iOS 17, *)
struct ReactionsRowView: View {
    let appearingSide: ContextMenuAppearingSide

    @State private var appeared = false
    @State private var longPressStarted = false

    @Environment(\.reactionProvider) private var reactionProvider
    @EnvironmentObject private var contextMenuVM: ContextMenuViewModel

    var body: some View {
        let reactions = reactionProvider.reactions()

        ScrollView(.horizontal) {
            let showingSpeed = 0.06
            HStack(spacing: 0) {
                ForEach(0 ..< reactions.count, id: \.self) { index in
                    let delay: Double? = if index >= 8 {
                        nil
                    } else {
                        switch appearingSide {
                        case .leading:
                            showingSpeed * Double(index + 1)
                        case .trailing:
                            showingSpeed * Double(reactions.count - index)
                        }
                    }

                    ReactionElement(
                        reaction: reactions[index],
                        appearingDelay: delay
                    )
                }
            }
            .scrollTargetLayout()
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
        }
        .scrollDisabled(longPressStarted)
        .scrollClipDisabled(true)
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned)
        .background {
            Color.white.clipShape(
                RoundedRectangle(
                    cornerSize: .init(
                        width: 36,
                        height: 36
                    )
                )
            )
        }
        .padding(.top, 40)
        .clipped()
        .scaleEffect(
            x: appeared ? 1 : 0,
            anchor: appearingSide.unitPoint
        )
        .containerRelativeFrame(
            .horizontal,
            count: 10,
            span: 8,
            spacing: 0
        )
        .onAppear {
            withAnimation {
                appeared = true
            }
        }
        .simultaneousGesture(gesture)
    }

    private var gesture: some Gesture {
        LongPressGesture(
            minimumDuration: 0.1,
            maximumDistance: 5
        )
        .onEnded { value in
            if !longPressStarted {
                longPressStarted = value
            }
        }
        .sequenced(
            before: DragGesture(
                minimumDistance: 0,
                coordinateSpace: .global
            )
        )
        .onChanged { value in
            guard case let .second(_, dragInfo) = value else {
                return
            }

            contextMenuVM.setDragLocation(dragInfo?.location)
        }
        .onEnded { value in
            guard case .second = value else { return }

            longPressStarted = false
            contextMenuVM.setDragLocation(nil)
        }
    }
}
