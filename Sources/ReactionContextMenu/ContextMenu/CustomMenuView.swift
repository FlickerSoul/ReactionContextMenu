//
//  CustomMenuView.swift
//  ReactionOverlay
//
//  Created by Larry Zeng on 11/7/25.
//
import SwiftUI

public struct CustomMenuView<Content: View>: View {
    @ViewBuilder let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: 0) {
            content
        }
        .frame(width: 250)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 13))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 4)
    }
}

public struct CustomMenuDivider: View {
    public init() {}

    public var body: some View {
        Divider()
            .padding(.horizontal, 12)
    }
}

public struct CustomMenuButton<Label: View>: View {
    @ViewBuilder let label: () -> Label
    let role: ButtonRole?
    let action: () -> Void

    public init(
        _ title: LocalizedStringKey,
        systemImage icon: String,
        role: ButtonRole? = nil,
        action: @escaping () -> Void = {}
    ) where Label == SwiftUI.Label<Text, Image> {
        label = { Label(title, systemImage: icon) }
        self.role = role
        self.action = action
    }

    public init(
        _ title: some StringProtocol,
        role: ButtonRole? = nil,
        action: @escaping () -> Void = {}
    ) where Label == SwiftUI.Text {
        label = { Text(title) }
        self.role = role
        self.action = action
    }

    public init(
        role: ButtonRole? = nil,
        action: @escaping () -> Void = {},
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.label = label
        self.role = role
        self.action = action
    }

    @Environment(\.dismissContextMenu) private var dismissContextMenu

    public var body: some View {
        Button {
            action()
            dismissContextMenu(.noChange)
        } label: {
            label()
                .labelStyle(CustomMenuButtonLabelStyle(role: role))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
                .lineLimit(1)
                .multilineTextAlignment(.leading)
                .truncationMode(.tail)
        }
        .buttonStyle(.plain)
    }

    struct CustomMenuButtonLabelStyle: LabelStyle {
        let role: ButtonRole?

        func makeBody(configuration: LabelStyleConfiguration) -> some View {
            HStack {
                configuration.title
                    .font(.body)
                    .foregroundStyle(role == .destructive ? .red : .primary)

                Spacer()

                configuration.icon
                    .font(.body)
                    .foregroundStyle(role == .destructive ? .red : .secondary)
            }
        }
    }
}
