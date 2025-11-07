//
//  ReactionElement.swift
//  ReactionOverlay
//
//  Created by Larry Zeng on 11/7/25.
//
import SwiftUI

@available(iOS 17, *)
struct ReactionElement: View {
    let reaction: String
    let appearingDelay: Double?

    let singleSidePadding = 4.0

    @State private var appeared = false
    @State private var onChosenShrinkAnimation = false

    @State private var popUpOnChoose = false
    @State private var frame: CGRect = .zero
    @State private var size: CGSize = .zero
    @EnvironmentObject private var contextMenuVM: ContextMenuViewModel
    @Environment(\.menuEdgeInsets) private var menuEdgeInsets
    @Environment(\.dismissContextMenu) private var dismissContextMenu
    @Environment(\.fontResolutionContext) private var fontResolutionContext

    private var reactionText: some View {
        Text(reaction)
            .font(.title)
            .padding(.horizontal, singleSidePadding)
    }

    private var isChosen: Bool {
        contextMenuVM.reactionSelected == reaction
    }

    var body: some View {
        reactionText
            .opacity(0)
            .overlay {
                let popUpScaleFactor = 1.5
                let onSelectShrinkFactor = 0.6
                VStack {
                    Text(reaction)
                        .font(.system(size: 300))
                        .minimumScaleFactor(0.01)
                        .scaleEffect(appeared ? 1 : 0)
                        .offset(y: popUpOnChoose ? -size.height : 0)
                }
                .frame(
                    width: size.width * popUpScaleFactor,
                    height: size.height * popUpScaleFactor
                )
                .scaleEffect(popUpOnChoose ? 1.0 : 1.0 / popUpScaleFactor)
                .scaleEffect(onChosenShrinkAnimation ? onSelectShrinkFactor : 1)
            }
            .background {
                Circle()
                    .fill(
                        isChosen ? Color( // #CCC
                            red: 204 / 255,
                            green: 204 / 255,
                            blue: 204 / 255
                        ) : .clear
                    )
                    .animation(.spring, value: isChosen)
                    .frame(
                        width: size.width + singleSidePadding * 2,
                        height: size.height + singleSidePadding * 2
                    )
            }
            .onAppear {
                animateAppearing()
            }
            .onTapGesture {
                let haptic = UIImpactFeedbackGenerator(style: .light)
                haptic.impactOccurred()

                dismissContextMenu(.selected(reaction))
            }
            .onGeometryChange(for: CGRect.self) { proxy in
                proxy.frame(in: .global)
            } action: { newValue in
                guard frame != newValue else { return }
                frame = newValue
            }
            .onGeometryChange(for: CGSize.self) { proxy in
                proxy.size
            } action: { newValue in
                guard size != newValue else { return }
                size = newValue
            }
            .onChange(of: contextMenuVM.dragLocation) {
                calculateShouldPopUp(dragLocation: contextMenuVM.dragLocation)
            }
            .onChange(of: contextMenuVM.reactionSelected) { newValue in
                if newValue == reaction {
                    withAnimation(.linear(duration: 0.1).repeatCount(1, autoreverses: true)) {
                        onChosenShrinkAnimation = true
                    } completion: {
                        onChosenShrinkAnimation = false
                    }
                }
            }
    }

    private func animateAppearing() {
        guard let appearingDelay else { return }
        withAnimation(
            .interpolatingSpring(stiffness: 170, damping: 16)
                .delay(appearingDelay)
        ) {
            appeared = true
        } completion: {
            calculateShouldPopUp(dragLocation: contextMenuVM.dragLocation)
        }
    }

    private func calculateShouldPopUp(dragLocation: CGPoint?) {
        guard appeared else { return }

        let shouldPop = if let dragLocation {
            frame.scaledVertically(by: 4).contains(dragLocation)
        } else {
            false
        }

        if shouldPop, !popUpOnChoose {
            let haptic = UIImpactFeedbackGenerator(style: .light)
            haptic.impactOccurred()
        }

        if !shouldPop, dragLocation == nil, popUpOnChoose {
            dismissContextMenu(.selected(reaction))
        }

        guard popUpOnChoose != shouldPop else { return }

        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
            popUpOnChoose = shouldPop
        }
    }
}
