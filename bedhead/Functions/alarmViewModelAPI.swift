// Alarm View Model API
// All the functions that make up the alarm clock
import SwiftUI
import AVFoundation
// View Model object
class AlarmViewModel: ObservableObject {
    @Published var alarms: [Alarm] = [] { // List of alarms the user has saved
        didSet {
            saveAlarms()
        }
    }
    @Published var activeAlarm: Alarm? = nil { // The active alarm
        didSet {
            updateActiveAlarm()
        }
    }

    private var timer: Timer?
    private let soundViewModel = SoundViewModel() // Alarm sound view model
    @Published var isAlarmTriggered: Bool = false // Used for camera screen to show up
    
    init() {
        loadAlarms()
    }
    
    deinit {
        timer?.invalidate()
    }
    // Function to start the timer to check the alarm every second
    private func startTimer() {
        timer?.invalidate() // Invalidate any existing timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.checkAlarm()
        }
    }

    // Function to stop/turn off the non-active timer(s)
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // Function to check if the current time matches the active alarm time
    private func checkAlarm() {
        guard var activeAlarm = activeAlarm else { return }
        let currentTime = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let alarmTime = Calendar.current.dateComponents([.hour, .minute], from: activeAlarm.time)
        if currentTime.hour == alarmTime.hour && currentTime.minute == alarmTime.minute {
            activeAlarm.isEnabled = false // Turn off active alarm
            playSound()
            stopTimer()
            AlarmManager.shared.triggerAlarm()
        }
    }

    // Function to play the alarm sound
    private func playSound() {
        guard let activeAlarm = activeAlarm else { return }
        soundViewModel.playSound(filename: activeAlarm.effectiveSound.filename)
    }

    // Function for the new active alarm
    private func updateActiveAlarm() {
        if activeAlarm == nil {
            stopTimer() // Stop the timer if there's no active alarm
        } else {
            startTimer() // Start the timer when there's an active alarm
        }
        for index in alarms.indices {
            if alarms[index].id == activeAlarm?.id {
                alarms[index].isEnabled = true
                scheduleNotification(for: alarms[index])
            } else {
                alarms[index].isEnabled = false
                cancelNotification(for: alarms[index])
            }
        }
        saveAlarms()
    }
    // New alarm
    func addAlarm(alarm: Alarm) {
        alarms.append(alarm)
        activeAlarm = alarm
        scheduleNotification(for: alarm)
    }
    // Delete alarm
    func removeAlarm(alarm: Alarm) {
        alarms.removeAll { $0.id == alarm.id }
        cancelNotification(for: alarm)
        if activeAlarm?.id == alarm.id {
            activeAlarm = nil
        }
    }

    // Schedule notification
    // Make it so the notification opens to the camera taking place.
    func scheduleNotification(for alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = "ALARM"
        content.body = "WAKE UP BEDHEAD"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "\(alarm.effectiveSound.filename).mp3"))
        content.categoryIdentifier = "ALARM_CATEGORY"
        let triggerDate = Calendar.current.dateComponents([.hour, .minute], from: alarm.time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: alarm.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    // Remove notification
    func cancelNotification(for alarm: Alarm) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [alarm.id.uuidString])
    }

    // Save alarms
    func saveAlarms() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(alarms) {
            UserDefaults.standard.set(encoded, forKey: "alarms")
        }
    }
    // Load alarms
    func loadAlarms() {
        if let savedAlarms = UserDefaults.standard.data(forKey: "alarms") {
            let decoder = JSONDecoder()
            if let loadedAlarms = try? decoder.decode([Alarm].self, from: savedAlarms) {
                self.alarms = loadedAlarms
            }
        }
    }
    // Test alarm (Not in use)
    func testAlarm() {
        guard var activeAlarm = activeAlarm else { return }
        activeAlarm.isEnabled = false
        playSound()
        stopTimer()
    }
}
