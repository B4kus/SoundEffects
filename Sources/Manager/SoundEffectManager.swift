//
//  SoundManager.swift
//  MemojiPuzzle
//
//  Created by Szymon Szysz on 05/10/2024.
//

import Foundation
import AudioToolbox

protocol SoundEffectMangerProtocol {
    func perLoadSoundEffects(soundEffects: [SoundEffect], inbundle: Bundle)
    func play(soundEffect: SoundEffect)
    func unload(soundEffect: SoundEffect)
    var onSoundEffectManagerError: ((SoundEffectMangerError) -> Void)? { get }
}


final class SoundEffectManager: SoundEffectMangerProtocol {
    
    // MARK: - Shared
    
    @MainActor static let shared = SoundEffectManager()
    
    // MARK: - Private Properties
    
    private(set) var soundIDs: [String: SystemSoundID] = [:]
    
    // MARK: - Debug Properties
    
    var isDebugMode: Bool = false
    var debugLogger: ((String) -> Void)?
    
    // MARK: - Error Callback
    
    var onSoundEffectManagerError: ((SoundEffectMangerError) -> Void)?
    
    // MARK: - Initialization
    
    private init() { }
    
    // MARK: - Register Sound Effects
    
    func perLoadSoundEffects(soundEffects: [SoundEffect], inbundle: Bundle = .main) {
        for soundEffect in soundEffects {
            logDebug("Registering sound effect: \(soundEffect.fullFileName)")
            if soundIDs[soundEffect.fullFileName] == nil {
                if let soundID = loadSound(named: soundEffect.name, fileExtension: soundEffect.fileExtension) {
                    soundIDs[soundEffect.fullFileName] = soundID
                    logDebug("Successfully loaded sound effect \(soundEffect.fullFileName) with ID \(soundID)")
                } else {
                    logDebug("Failed to load sound effect: \(soundEffect.fullFileName)")
                }
            } else {
                logDebug("Sound effect \(soundEffect.fullFileName) is already registered.")
            }
        }
    }
    
    // MARK: - Play Sound Effects
    
    func play(soundEffect: SoundEffect) {
        logDebug("Attempting to play sound effect: \(soundEffect.fullFileName)")
        if let soundID = soundIDs[soundEffect.fullFileName] {
            AudioServicesPlaySystemSound(soundID)
            logDebug("Played sound effect with ID: \(soundID)")
        } else {
            logDebug("Error: Sound effect \(soundEffect.fullFileName) not registered.")
            onSoundEffectManagerError?(.fileNotFound)
        }
    }
    
    // MARK: - Unload Sound Effects
    
    func unload(soundEffect: SoundEffect) {
        logDebug("Unloading sound effect: \(soundEffect.fullFileName)")
        if let soundID = soundIDs[soundEffect.fullFileName] {
            AudioServicesDisposeSystemSoundID(soundID)
            soundIDs.removeValue(forKey: soundEffect.fullFileName)
            logDebug("Successfully unloaded sound effect with ID: \(soundID)")
        } else {
            logDebug("Sound effect \(soundEffect.fullFileName) not found in cache.")
        }
    }
    
    // MARK: - Load Sound Effects
    
    private func loadSound(named: String, fileExtension: String) -> SystemSoundID? {
        logDebug("Loading sound: \(named).\(fileExtension)")
        guard let soundURL = Bundle.main.url(forResource: named, withExtension: fileExtension) else {
            logDebug("Error: Sound file \(named).\(fileExtension) not found.")
            onSoundEffectManagerError?(.fileNotFound)
            return nil
        }
        
        var soundID: SystemSoundID = 0
        let status = AudioServicesCreateSystemSoundID(soundURL as CFURL, &soundID)
        
        if status == kAudioServicesNoError {
            logDebug("Sound file \(named).\(fileExtension) loaded successfully with ID: \(soundID)")
            return soundID
        } else {
            logDebug("Error: Failed to create sound with error code \(status) for file \(named).\(fileExtension)")
            onSoundEffectManagerError?(.failToInitilizePlayer)
            return nil
        }
    }
    
    // MARK: - Debug Log Function
    
    private func logDebug(_ message: String) {
        if isDebugMode {
            debugLogger?(message) ?? print("Debug: \(message)")
        }
    }
}
