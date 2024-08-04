// Main !
import SwiftUI
import UserNotifications

@main
struct YourApp: App {
    private let notificationDelegate = NotificationDelegate()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var alarmViewModel = AlarmViewModel()
    var body: some Scene {
        WindowGroup {
            Home()
                .environmentObject(alarmViewModel)
                .onAppear {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        AlarmManager.shared.window = windowScene.windows.first
                        UNUserNotificationCenter.current().delegate = notificationDelegate
                    }
                }
        }
    }
}
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    override init() {
        super.init()
        setupNotificationActions()
    }

    func setupNotificationActions() {
        let alarmAction = UNNotificationAction(identifier: "ALARM_ACTION", title: "Open Camera", options: [.foreground])
        let alarmCategory = UNNotificationCategory(identifier: "ALARM_CATEGORY", actions: [alarmAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([alarmCategory])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == "ALARM_ACTION" || response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            AlarmManager.shared.handleNotificationResponse()
        }
        completionHandler()
    }
}
// For handling notifications
class AppDelegate: NSObject, UIApplicationDelegate {
    private let notificationDelegate = NotificationDelegate()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = notificationDelegate
        return true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            AlarmManager.shared.window = windowScene.windows.first
            AlarmManager.shared.handleNotificationResponse()
        }
        completionHandler(.newData)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            AlarmManager.shared.window = windowScene.windows.first
        }
    }
}
