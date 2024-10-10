# SoundEffects

## Overview

`SoundEffectManager` is a lightweight and efficient manager for handling system sound effects using Apple's `AudioServices` API. It provides an easy-to-use interface for registering, playing, and unloading sound effects with the ability to enable debug logging for development purposes.

In addition, this repository includes custom SwiftUI `ViewModifiers` to enhance your UI development experience by providing reusable and concise view customizations.

---

## Features

- **Preload Sound Effects**: Easily preload sound effects from any `Bundle`.
- **Play Sound Effects**: Simple API for triggering sound playback with minimal latency.
- **Unload Sound Effects**: Free up memory by unloading sounds that are no longer needed.
- **Debug Mode**: Enable debug mode to track internal operations and log sound-related events.
- **Error Handling**: Callback to handle and respond to errors such as missing sound files or sound initialization failures.
- **SwiftUI View Modifiers**: Custom `ViewModifiers` to simplify common UI customizations in your SwiftUI views.

---

## Installation

### Swift Package Manager

To integrate `SoundEffectManager` and SwiftUI View Modifiers into your Xcode project using Swift Package Manager, follow these steps:

1. In Xcode, select **File** -> **Add Packages**.
2. Enter the repository URL: `https://github.com/B4kus/SoundEffects`.
3. Select the latest version and add the package to your project.

---

## Usage

### SoundEffectManager

#### Preload Sound Effects

You can preload multiple sound effects using the `perLoadSoundEffects` function. This will load sound files from the specified bundle into memory.

```swift
let soundEffects = [
    SoundEffect(name: "buttonClick", fileExtension: "wav"),
    SoundEffect(name: "successTone", fileExtension: "mp3")
]

SoundEffectManager.shared.perLoadSoundEffects(soundEffects: soundEffects, in: .main)
