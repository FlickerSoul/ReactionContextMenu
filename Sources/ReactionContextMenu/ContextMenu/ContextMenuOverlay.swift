//
//  ContextMenuOverlay.swift
//  ReactionOverlay
//
//  Created by Larry Zeng on 11/7/25.
//
import SwiftUI

private struct VisualEffectView: UIViewRepresentable {
    let effect: UIVisualEffect

    func makeUIView(
        context _: UIViewRepresentableContext<Self>
    ) -> UIVisualEffectView {
        let view = UIVisualEffectView()
        view.effect = effect
        return view
    }

    func updateUIView(_: UIVisualEffectView, context _: Context) {}
}

private struct ContextMenuOverlayBlur: View {
    var body: some View {
        VisualEffectView(
            effect: UIBlurEffect(
                style: .systemUltraThinMaterialDark
            )
        )
    }
}

@available(iOS 17, *)
struct ContextMenuOverlay: View {
    let presentedView: ContextMenuViewModel.PresentedView
    private let spacing: CGFloat = 8

    // Appear/Disappear animation
    @State private var popIn = false
    @State private var willPopOut = false
    @State private var reactionRowSize: CGSize = .zero
    @State private var menuSectionSize: CGSize = .zero
    @State private var screenSize: CGSize = .zero
    @State private var safeAreaInsets: EdgeInsets = .init()
    @State private var boundaryOffset: CGFloat = 0

    @EnvironmentObject var contextMenuVM: ContextMenuViewModel

    var body: some View {
        ZStack {
            ContextMenuOverlayBlur()
                .opacity(willPopOut || !contextMenuVM.showMenu ? 0 : 1)
                .animation(.spring.delay(0.15), value: willPopOut || !contextMenuVM.showMenu)
                .onTapGesture {
                    disappearAnimation()
                }
                .ignoresSafeArea(.all, edges: .all)

            presentation
                .ignoresSafeArea(.all, edges: .all)
        }
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { newValue in
            screenSize = newValue
            calculateBoundaryOffset()
        }
        .onGeometryChange(for: EdgeInsets.self) { proxy in
            proxy.safeAreaInsets
        } action: { newValue in
            safeAreaInsets = newValue
            calculateBoundaryOffset()
        }
        .onAppear {
            appearAnimation()
        }
    }

    @ViewBuilder
    private var presentation: some View {
        ZStack {
            presentedView.view
                .frame(
                    width: presentedView.shapeInfo.size.width,
                    height: presentedView.shapeInfo.size.height
                )
                .position(
                    x: presentedView.shapeInfo.position.midX,
                    y: presentedView.shapeInfo.position.midY
                )
                .environment(\.isPresentedInContextMenu, true)
                .animation(willPopOut ? popOutAnimation : popInAnimation, value: popIn)

            VStack(
                alignment: presentedView.appearingSide.horizontalAlignment,
                spacing: spacing
            ) {
                ReactionsRowView(appearingSide: presentedView.appearingSide)
                    .scaleEffect(popIn ? 1 : (willPopOut ? 0.4 : 0))
                    .opacity(popIn ? 1 : 0)
                    .animation(willPopOut ? popOutAnimation : popInAnimation, value: popIn)
                    .onGeometryChange(for: CGSize.self) { proxy in
                        proxy.size
                    } action: { newValue in
                        reactionRowSize = newValue
                        calculateBoundaryOffset()
                    }
                    .environment(\.menuEdgeInsets, safeAreaInsets)
                    .environment(\.dismissContextMenu, dismissOverlay)

                Rectangle()
                    .fill(.clear)
                    .frame(height: presentedView.shapeInfo.size.height, alignment: .center)

                presentedView.menu
                    .scaleEffect(popIn ? 1 : (willPopOut ? 0.4 : 0))
                    .opacity(popIn ? 1 : 0)
                    .offset(y: popIn ? 0 : -50)
                    .animation(willPopOut ? popOutAnimation : popInAnimation, value: popIn)
                    .onGeometryChange(for: CGSize.self) { proxy in
                        proxy.size
                    } action: { newValue in
                        menuSectionSize = newValue
                        calculateBoundaryOffset()
                    }
                    .environment(\.dismissContextMenu, dismissOverlay)
            }
            .padding(presentedView.appearingSide.edgeSet, 8)
            .position(
                x: screenSize.width / 2,
                y: presentedView.shapeInfo.position.midY
                    - (reactionRowSize.height / 2 - menuSectionSize.height / 2)
            )
        }
        .offset(x: 0, y: popIn ? boundaryOffset : 0)
    }

    // MARK: animations

    private var popInAnimation: Animation {
        .spring(response: 0.2, dampingFraction: 0.7, blendDuration: 0.2)
    }

    private var popOutAnimation: Animation {
        .smooth.speed(2)
    }

    // MARK: callbacks

    private func appearAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            popIn = true
        }
    }

    private func dismissOverlay(_ selectedReaction: ReactionChoice) {
        switch selectedReaction {
        case .noChange:
            disappearAnimation()
        case let .selected(reaction):
            contextMenuVM.toggleReaction(reaction)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                disappearAnimation()
            }
        }
    }

    private func disappearAnimation() {
        withAnimation {
            willPopOut = true
            popIn = false
        } completion: {
            contextMenuVM.hideContextMenu()
        }
    }

    // Calculation

    private func calculateBoundaryOffset() {
        guard screenSize != .zero else { return }

        let totalHeight = reactionRowSize.height + spacing + presentedView.shapeInfo.size
            .height + spacing + menuSectionSize.height
        let centerY = presentedView.shapeInfo.position.midY - (reactionRowSize.height / 2 - menuSectionSize.height / 2)

        let topY = centerY - totalHeight / 2
        let bottomY = centerY + totalHeight / 2

        // Define safe area boundaries
        let safeTop = safeAreaInsets.top
        let safeBottom = screenSize.height - safeAreaInsets.bottom - 50 // FIXME: why - 50??

        // Check if goes beyond top safe area
        if topY < safeTop {
            boundaryOffset = safeTop - topY
        } else if bottomY > safeBottom { // Check if goes beyond bottom safe area
            boundaryOffset = safeBottom - bottomY
        } else {
            boundaryOffset = 0
        }
    }
}

@available(iOS 18, *)
#Preview("Overlay Blur") {
    TabView {
        Tab {
            AsyncImage(url: URL(string: "https://picsum.photos/400")!) { image in
                image.image
            }
        }
    }
    .overlay {
        ContextMenuOverlayBlur()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(.all)
    }
}
