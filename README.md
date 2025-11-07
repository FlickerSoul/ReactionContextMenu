# ReactionContextMenu

A SwiftUI library that provides an interactive context menu with emoji reactions, similar to messaging apps like iMessage and Telegram. Features smooth animations, haptic feedback, and customizable options.

## Features

- **Interactive Reaction Menu**: Long-press any view to reveal a scrollable row of emoji reactions
- **Smooth Animations**: Spring-based animations with staggered appearance effects
- **Haptic Feedback**: Built-in haptic feedback for better user experience
- **Drag-to-Select**: Drag your finger over reactions to select them
- **Custom Context Menu**: Add custom menu items alongside reactions
- **Flexible Configuration**: Customize haptic touch duration and menu positioning
- **Custom Reactions**: Provide your own set of reactions via the `ReactionProvider` protocol

## Requirements

- iOS 17.0+

## Usage

### Basic Setup

1. Add the `ContextMenuHost` modifier to your root view:

    ```swift
    import ReactionContextMenu
    import SwiftUI

    struct ContentView: View {
        var body: some View {
            YourContentView()
                .modifier(ContextMenuHost())
        }
    }
    ```

2. Wrap any view with `CustomContextMenuWrapper` to add reactions:

    ```swift
    CustomContextMenuWrapper(
        hapticTouchDuration: .default,
        contextMenuAppearingSide: .trailing
    ) {
        Text("Long press me!")
            .padding()
            .background(Color.blue)
            .cornerRadius(8)
    } menu: {
        CustomMenuView {
            CustomMenuButton("Copy") {
                // Handle copy action
            }

            CustomMenuDivider()

            CustomMenuButton("Delete", systemImage: "trash", role: .destructive) {
                // Handle delete action
            }
        }
    }
    ```

### Custom Menu Items

Build custom menus with the provided components:

```swift
CustomMenuView {
    // Text-only button
    CustomMenuButton("Edit") {
        print("Edit tapped")
    }

    // Button with icon
    CustomMenuButton("Share", systemImage: "square.and.arrow.up") {
        print("Share tapped")
    }

    // Destructive button
    CustomMenuButton("Delete", systemImage: "trash", role: .destructive) {
        print("Delete tapped")
    }

    // Add dividers
    CustomMenuDivider()
}
```

### Custom Reactions

Provide your own set of reactions by implementing the `ReactionProvider` protocol:

```swift
struct MyReactionProvider: ReactionProvider {
    func reactions() -> [String] {
        ["👍", "❤️", "😂", "😮", "😢", "👏"]
    }
}

// then use `.environment(\.reactionProvider, MyReactionProvider())`
```

## Example

Check out the `Example` directory for a complete working example showing:

- Chat-like message bubbles with reactions
- Different appearing sides based on message alignment
- Custom menu items
- Haptic touch duration picker
