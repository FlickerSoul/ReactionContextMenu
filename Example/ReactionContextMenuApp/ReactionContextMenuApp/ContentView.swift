//
//  ContentView.swift
//  ReactionContextMenu
//
//  Created by Larry Zeng on 11/7/25.
//
import Combine
import ReactionContextMenu
import SwiftUI

@available(iOS 18, *)
struct ContentView: View {
    var body: some View {
        ContentTabView()
            .modifier(ContextMenuHost())
    }
}

class MessageViewModel: ObservableObject {
    @Published var reaction: String?
}

@Observable
class TabViewViewModel {
    @ObservationIgnored let messageCount: Int
    var messageVMs: [MessageViewModel]

    init(messageCount: Int = 20) {
        self.messageCount = messageCount
        messageVMs = (0 ..< messageCount).map { _ in MessageViewModel() }
    }
}

@available(iOS 18, *)
private struct ContentTabView: View {
    @State var hapticTouchDuration: HapticTouchDuration = .fast
    @State var vm = TabViewViewModel()
    @EnvironmentObject var contextMenuVM: ContextMenuViewModel

    var body: some View {
        TabView {
            Tab {
                ScrollView {
                    Picker("Haptic Touch Duration", selection: $hapticTouchDuration) {
                        ForEach(HapticTouchDuration.allCases, id: \.self) { duration in
                            Text(duration.description).tag(duration)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.bottom, 36)

                    LazyVStack(spacing: 0) {
                        ForEach(0 ..< vm.messageCount, id: \.self) { index in
                            let sending = index % 2 == 0
                            Message(
                                sending: sending,
                                hapticTouchDuration: hapticTouchDuration
                            )
                            .environmentObject(vm.messageVMs[index])
                        }
                    }
                    .padding(.horizontal)
                }
                .scrollDisabled(contextMenuVM.showMenu)
            } label: {
                Label("Home", systemImage: "house")
            }
        }
    }
}

private struct Message: View {
    let sending: Bool
    let hapticTouchDuration: HapticTouchDuration
    let side: ContextMenuAppearingSide
    let alignment: Alignment
    @EnvironmentObject var messageVM: MessageViewModel

    init(sending: Bool, hapticTouchDuration: HapticTouchDuration) {
        self.sending = sending
        self.hapticTouchDuration = hapticTouchDuration
        side = sending ? .trailing : .leading
        alignment = sending ? .trailing : .leading
    }

    var body: some View {
        CustomContextMenuWrapper(
            hapticTouchDuration: hapticTouchDuration,
            contextMenuAppearingSide: side,
            selectedReaction: $messageVM.reaction
        ) {
            Text("Test Message")
                .padding()
                .background {
                    sending ? Color.gray : .accentColor
                }
                .clipShape(BubbleShape(sending: sending))
                .padding(.horizontal, 8)

        } menu: {
            CustomMenuView {
                CustomMenuButton("Hi") {}

                CustomMenuDivider()

                CustomMenuButton("By", systemImage: "trash", role: .destructive) {}

                CustomMenuDivider()

                CustomMenuButton(
                    "Hi this is a very long text in the menu item and let's see how it handles it"
                ) {}
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if let reaction = messageVM.reaction {
                Text("\(reaction) 1")
                    .font(.caption)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(.gray.opacity(0.6))
                    .clipShape(.capsule)
                    .offset(x: -8, y: 20)
            }
        }
        .containerRelativeFrame(.horizontal, alignment: alignment)
    }
}

// Credit: https://gist.github.com/navsing/21373a82146747e06eef87b5645d8663
private struct BubbleShape: Shape {
    let sending: Bool

    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height

        let bezierPath = UIBezierPath()
        if !sending {
            bezierPath.move(to: CGPoint(x: 20, y: height))
            bezierPath.addLine(to: CGPoint(x: width - 15, y: height))
            bezierPath.addCurve(
                to: CGPoint(x: width, y: height - 15),
                controlPoint1: CGPoint(x: width - 8, y: height),
                controlPoint2: CGPoint(x: width, y: height - 8)
            )
            bezierPath.addLine(to: CGPoint(x: width, y: 15))
            bezierPath.addCurve(
                to: CGPoint(x: width - 15, y: 0),
                controlPoint1: CGPoint(x: width, y: 8),
                controlPoint2: CGPoint(x: width - 8, y: 0)
            )
            bezierPath.addLine(to: CGPoint(x: 20, y: 0))
            bezierPath.addCurve(
                to: CGPoint(x: 5, y: 15),
                controlPoint1: CGPoint(x: 12, y: 0),
                controlPoint2: CGPoint(x: 5, y: 8)
            )
            bezierPath.addLine(to: CGPoint(x: 5, y: height - 10))
            bezierPath.addCurve(
                to: CGPoint(x: 0, y: height),
                controlPoint1: CGPoint(x: 5, y: height - 1),
                controlPoint2: CGPoint(x: 0, y: height)
            )
            bezierPath.addLine(to: CGPoint(x: -1, y: height))
            bezierPath.addCurve(
                to: CGPoint(x: 12, y: height - 4),
                controlPoint1: CGPoint(x: 4, y: height + 1),
                controlPoint2: CGPoint(x: 8, y: height - 1)
            )
            bezierPath.addCurve(
                to: CGPoint(x: 20, y: height),
                controlPoint1: CGPoint(x: 15, y: height),
                controlPoint2: CGPoint(x: 20, y: height)
            )
        } else {
            bezierPath.move(to: CGPoint(x: width - 20, y: height))
            bezierPath.addLine(to: CGPoint(x: 15, y: height))
            bezierPath.addCurve(
                to: CGPoint(x: 0, y: height - 15),
                controlPoint1: CGPoint(x: 8, y: height),
                controlPoint2: CGPoint(x: 0, y: height - 8)
            )
            bezierPath.addLine(to: CGPoint(x: 0, y: 15))
            bezierPath.addCurve(
                to: CGPoint(x: 15, y: 0),
                controlPoint1: CGPoint(x: 0, y: 8),
                controlPoint2: CGPoint(x: 8, y: 0)
            )
            bezierPath.addLine(to: CGPoint(x: width - 20, y: 0))
            bezierPath.addCurve(
                to: CGPoint(x: width - 5, y: 15),
                controlPoint1: CGPoint(x: width - 12, y: 0),
                controlPoint2: CGPoint(x: width - 5, y: 8)
            )
            bezierPath.addLine(to: CGPoint(x: width - 5, y: height - 12))
            bezierPath.addCurve(
                to: CGPoint(x: width, y: height),
                controlPoint1: CGPoint(x: width - 5, y: height - 1),
                controlPoint2: CGPoint(x: width, y: height)
            )
            bezierPath.addLine(to: CGPoint(x: width + 1, y: height))
            bezierPath.addCurve(
                to: CGPoint(x: width - 12, y: height - 4),
                controlPoint1: CGPoint(x: width - 4, y: height + 1),
                controlPoint2: CGPoint(x: width - 8, y: height - 1)
            )
            bezierPath.addCurve(
                to: CGPoint(x: width - 20, y: height),
                controlPoint1: CGPoint(x: width - 15, y: height),
                controlPoint2: CGPoint(x: width - 20, y: height)
            )
        }
        return Path(bezierPath.cgPath)
    }
}

@available(iOS 18, *)
#Preview {
    ContentView()
}
