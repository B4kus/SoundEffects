//
//  SoundEffectButtonModifier.swift
//  MemojiPuzzle
//
//  Created by Szymon Szysz on 07/10/2024.
//

import SwiftUI

public struct SoundEffectButtonModifier: ViewModifier {
    
    // MARK: - Properties
    
    let soundEffect: SoundEffect
    
    // MARK: - Body
    
    public func body(content: Content) -> some View {
        content
            .simultaneousGesture(TapGesture().onEnded {
                SoundEffectManager.shared.play(soundEffect: soundEffect)
            })
    }
}

public extension View {
    public func soundEffectOnAction(_ soundEffect: SoundEffect) -> some View {
        self.modifier(SoundEffectButtonModifier(soundEffect: soundEffect))
    }
}
