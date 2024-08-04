//
//  alarmSound.swift
//  bedhead
//
//  Created by Ivan Chiu on 7/25/24.
//

import SwiftUI
import AVFoundation

class SoundViewModel: ObservableObject {
    // All alarm sounds
    @Published var sounds: [AlarmSound] = [
        AlarmSound(name: "Default", filename: "default"),
        AlarmSound(name: "Wake yo a$$ up", filename: "wakeYoAssUP")
    ]
    
    var audioPlayer: AVAudioPlayer?
    
    init() {
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error.localizedDescription)")
        }
    }
    
    func playSound(filename: String) {
        // Sound. MP3 for now
        guard let url = Bundle.main.url(forResource: filename, withExtension: "mp3") else {
            print("Sound file not found: \(filename)")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
}


