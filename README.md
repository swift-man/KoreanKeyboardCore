# KoreanKeyboardCore

`KoreanKeyboardCore` is a small Swift package for building Korean custom keyboard extensions. It provides:

- Hangul composition and backspace edits
- Hangul, English, and number keyboard layouts
- Semantic key models for mode switching, system keyboard switching, space, return, shift, and backspace
- Extension-safe Foundation-only code

## Installation

Add this repository in Xcode with **File > Add Package Dependencies...** and link the `KoreanKeyboardCore` product to your keyboard extension target.

```swift
dependencies: [
    .package(url: "https://github.com/swift-man/KoreanKeyboardCore.git", from: "1.0.0")
]
```

## Usage

```swift
import KoreanKeyboardCore

var state = KeyboardState()
let layoutProvider = KoreanKeyboardLayoutProvider()
let rows = layoutProvider.rows(for: state)

var composer = HangulComposer()
let edit = composer.input("ㅎ")
```

Apply a `ComposerEdit` to the host text input by deleting `deleteCount` characters, then inserting `insertedText`. When `shouldDeleteFromDocument` is `true`, call the host input's delete action instead.

Use `.modeSwitch(...)` keys for Hangul, English, and number layout changes inside your keyboard. Use `.keyboardSwitch` for the iOS globe key and call `advanceToNextInputMode()` from your `UIInputViewController` when it is tapped.

When a mode switch key is tapped, reset the composer before changing layout state:

```swift
if let mode = key.modeSwitchTarget {
    composer.reset()
    state.switchMode(to: mode)
}
```
