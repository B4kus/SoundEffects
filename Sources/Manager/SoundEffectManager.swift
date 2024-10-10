//
//  SoundManager.swift
//  MemojiPuzzle
//
//  Created by Szymon Szysz on 05/10/2024.
//

import Foundation
import AudioToolbox

protocol SoundEffectMangerProtocol {
    func perLoadSoundEffects(soundEffects: [SoundEffect],in bundle: Bundle)
    func play(soundEffect: SoundEffect)
    func unload(soundEffect: SoundEffect)
    var onSoundEffectManagerError: ((SoundEffectMangerError) -> Void)? { get }
}

/// `SoundEffectManager` is a singleton class that manages the registration, playback,
/// and unloading of sound effects using the `AudioServices` system sound API.
/// It supports debugging with logging functionality and error handling.
///
/// - Note: The sound effects are cached using a dictionary to store `SystemSoundID`
///   for quick access.
final class SoundEffectManager: SoundEffectMangerProtocol {
    
    // MARK: - Shared Instance
    
    /// The shared instance of `SoundEffectManager` to be used globally.
    ///
    /// - Important: Access this instance on the main thread, since the `@MainActor`
    ///   annotation ensures that operations are performed safely on the main queue.
    @MainActor static let shared = SoundEffectManager()

    // MARK: - Properties
    
    /// A dictionary that maps sound file names to their corresponding `SystemSoundID`.
    /// This serves as the cache for the sound effects that have been registered.
    ///
    /// - Note: The key is the full filename (`name.extension`) of the sound file.
    private(set) var soundIDs: [String: SystemSoundID] = [:]
    
    /// Enables or disables debug logging for the `SoundEffectManager`. When `true`,
    /// debug logs will be printed or sent to a custom `debugLogger` if provided.
    ///
    /// - Default: `false`
    var isDebugMode: Bool = false
    
    /// A custom logging function to be used for debug messages. If no logger is provided,
    /// the debug messages will be printed to the console.
    var debugLogger: ((String) -> Void)?
    
    /// A closure that is triggered when an error occurs in the manager. The closure
    /// provides a `SoundEffectMangerError` object indicating the type of error encountered.
    ///
    /// - SeeAlso: `SoundEffectMangerError`
    var onSoundEffectManagerError: ((SoundEffectMangerError) -> Void)?
    
    // MARK: - Initialization
    
    /// Private initializer to ensure the singleton pattern.
    private init() { }

    // MARK: - Public Methods
    
    /// Preloads an array of sound effects, loading them from the specified bundle into memory.
    /// If the sound effect is already registered, it will be skipped.
    ///
    /// - Parameters:
    ///   - soundEffects: An array of `SoundEffect` objects to be preloaded.
    ///   - bundle: The bundle from which to load the sound files. Defaults to the main bundle.
    ///
    /// - Important: Ensure that the sound files are correctly named and available
    ///   in the bundle, otherwise an error will be thrown.
    func perLoadSoundEffects(soundEffects: [SoundEffect], in bundle: Bundle = .main) {
        for soundEffect in soundEffects {
            logDebug("Registering sound effect: \(soundEffect.fullFileName)")
            if soundIDs[soundEffect.fullFileName] == nil {
                if let soundID = loadSound(named: soundEffect.name, fileExtension: soundEffect.fileExtension, bundle: bundle) {
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
    
    /// Plays the specified sound effect. The sound effect must be registered (preloaded) first.
    ///
    /// - Parameter soundEffect: The `SoundEffect` object representing the sound to be played.
    ///
    /// - Note: If the sound effect is not registered, an error is triggered, and the
    ///   `onSoundEffectManagerError` closure is called with `.fileNotFound`.
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
    
    /// Unloads the specified sound effect from memory, freeing up system resources.
    ///
    /// - Parameter soundEffect: The `SoundEffect` object representing the sound to be unloaded.
    ///
    /// - Note: If the sound effect is not found in the cache, an error is logged but no
    ///   exception is thrown.
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

    // MARK: - Private Methods
    
    /// Loads a sound effect from the specified bundle and returns the corresponding `SystemSoundID`.
    ///
    /// - Parameters:
    ///   - named: The name of the sound file without the file extension.
    ///   - fileExtension: The file extension (e.g., "wav" or "mp3").
    ///   - bundle: The bundle from which to load the sound file.
    ///
    /// - Returns: A `SystemSoundID` if the sound was loaded successfully, otherwise `nil`.
    private func loadSound(named: String, fileExtension: String, bundle: Bundle) -> SystemSoundID? {
        logDebug("Loading sound: \(named).\(fileExtension)")
        guard let soundURL = bundle.url(forResource: named, withExtension: fileExtension) else {
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
    
    /// Logs debug messages if `isDebugMode` is enabled. If a custom logger is provided,
    /// it will be used to log messages, otherwise, messages will be printed to the console.
    ///
    /// - Parameter message: The message to be logged.
    private func logDebug(_ message: String) {
        if isDebugMode {
            debugLogger?(message) ?? print("Debug: \(message)")
        }
    }
}
