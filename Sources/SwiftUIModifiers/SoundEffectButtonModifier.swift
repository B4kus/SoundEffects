//
//  SoundEffectButtonModifier.swift
//  MemojiPuzzle
//
//  Created by Szymon Szysz on 07/10/2024.
//

import SwiftUI

struct SoundEffectButtonModifier: ViewModifier {
    
    // MARK: - Properties
    
    let soundEffect: SoundEffect
    
    // MARK: - Body
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(TapGesture().onEnded {
                SoundEffectManager.shared.play(soundEffect: soundEffect)
            })
    }
}

extension View {
    func soundEffectOnAction(_ soundEffect: SoundEffect) -> some View {
        self.modifier(SoundEffectButtonModifier(soundEffect: soundEffect))
    }
}
