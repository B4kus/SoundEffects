import Testing
import AudioToolbox
@testable import SoundEffects

struct SoundEffectManagerTests {

    // Test registering a sound effect
    @MainActor @Test("Register a sound effect")
    func testRegisterSoundEffect() {
        let soundEffect = SoundEffect(name: "testSound", fileExtension: "wav")
        SoundEffectManager.shared.perLoadSoundEffects(soundEffects: [soundEffect], in: .module)
        
        #expect(SoundEffectManager.shared.soundIDs[soundEffect.fullFileName] != nil)
    }
    
    // Test unloading a sound effect
    @MainActor @Test("Unload a sound effect")
    func testUnloadSoundEffect() {
        let soundEffect = SoundEffect(name: "testSound", fileExtension: "wav")
        SoundEffectManager.shared.perLoadSoundEffects(soundEffects: [soundEffect], in: .module)
        SoundEffectManager.shared.unload(soundEffect: soundEffect)
        
        #expect(SoundEffectManager.shared.soundIDs[soundEffect.fullFileName] == nil)
    }

    // Test error handling when playing a sound that is not registered
    @MainActor @Test("Play unregistered sound error handling")
    func testPlayUnregisteredSoundError() {
        let soundEffect = SoundEffect(name: "unregisteredSound", fileExtension: "wav")
        var errorOccurred = false
        
        SoundEffectManager.shared.onSoundEffectManagerError = { error in
            if error == .fileNotFound {
                errorOccurred = true
            }
        }
        
        SoundEffectManager.shared.play(soundEffect: soundEffect)
        #expect(errorOccurred)
    }
}

