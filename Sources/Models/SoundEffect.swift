//
//  SoundEffect.swift
//  MemojiPuzzle
//
//  Created by Szymon Szysz on 07/10/2024.
//

import Foundation

struct SoundEffect {
    let name: String
    let fileExtension: String
    
    var fullFileName: String {
        "\(name).\(fileExtension)"
    }
}
