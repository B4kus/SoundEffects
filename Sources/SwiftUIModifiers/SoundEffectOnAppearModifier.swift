//
//  SoundEffectOnAppearModifier.swift
//  MemojiPuzzle
//
//  Created by Szymon Szysz on 07/10/2024.
//

import SwiftUI

struct SoundEffectOnAppearModifier: ViewModifier {
    
    // MARK: - Properties
    
    let soundEffect: SoundEffect
    let soundEffectOptions: SoundEffectOptions?
    
    // MARK: - Body
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                switch soundEffectOptions {
                case .delay(let delay):
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        SoundEffectManager.shared.play(soundEffect: soundEffect)
                    }
                case .none:
                    SoundEffectManager.shared.play(soundEffect: soundEffect)
                }
                
            }
    }
}

extension View {
    func soundEffect(_ soundEffect: SoundEffect,_ options: SoundEffectOptions? = nil) -> some View {
        self.modifier(SoundEffectOnAppearModifier(soundEffect: soundEffect, soundEffectOptions: options))
    }
}
