//
//  SoundEffect.swift
//  MemojiPuzzle
//
//  Created by Szymon Szysz on 07/10/2024.
//

import Foundation

public struct SoundEffect {
    public let name: String
    public let fileExtension: String
    
    public init(name: String, fileExtension: String) {
        self.name = name
        self.fileExtension = fileExtension
    }
    
    var fullFileName: String {
        "\(name).\(fileExtension)"
    }
}
