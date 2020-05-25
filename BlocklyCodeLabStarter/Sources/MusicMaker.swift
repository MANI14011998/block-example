
import Foundation
import JavaScriptCore


@objc protocol MusicMakerJSExports: JSExport {
     static func playSound(_ file: String)
}
/**
 Class exposed to a JS context.
 */
@objc class MusicMaker: NSObject, MusicMakerJSExports {
  /// Keeps track of all sounds currently being played.
  private static var audioPlayers = Set<AudioPlayer>()
  private static var conditionLocks = [String: NSConditionLock]()

  /**
     
   Play a specific sound.

   This method is exposed to a JS context as `MusicMaker.playSound(_)`.

   - parameter file: The sound file to play.
     
   */
    // Create a protocol that inherits JSExport, marking methods/variables
    // that should be exposed to a JavaScript VM.
    // NOTE: This protocol must be attributed with @objc.
   
    

 static func playSound(_ file: String) {
     guard let player = AudioPlayer(file: file) else {
       return
     }

     // Create a condition lock for this player so we don't return back to JS code until
     // the player has finished playing.
     let uuid = NSUUID().uuidString
     self.conditionLocks[uuid] = NSConditionLock(condition: 0)

     player.completion = { player, successfully in
       // Now that playback has completed, dispose of the player and change the lock condition to
       // "1" to the code below `player.play()`.
       self.conditionLocks[uuid]?.lock()
       self.audioPlayers.remove(player)
       self.conditionLocks[uuid]?.unlock(withCondition: 1)
     }

     if player.play() {
       // Hold a reference to the audio player so it doesn't go out of memory.
       self.audioPlayers.insert(player)

       // Block this thread by waiting for the condition lock to change to "1", which happens when
       // playback is complete.
       // Once this happens, dispose of the lock and let control return back to the JS code (which
       // was the original caller of `MusicMaker.playSound(...)`).
       self.conditionLocks[uuid]?.lock(whenCondition: 1)
       self.conditionLocks[uuid]?.unlock()
       self.conditionLocks[uuid] = nil
     }
   }
}
