// Alarm and alarm sound objects
import Foundation

struct Alarm: Identifiable, Codable {
    var id = UUID()
    var time: Date
    var isEnabled: Bool
    var sound: AlarmSound? 
    // Computed property to get the sound to use
    var effectiveSound: AlarmSound {
        sound ?? AlarmSound.defaultSound
    }
}

struct AlarmSound: Identifiable, Codable {
    var id = UUID()
    var name: String
    var filename: String
    
    // Default sound
    static let defaultSound = AlarmSound(name: "Default", filename: "default")
}


