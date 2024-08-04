import SwiftUI

class AlarmManager: ObservableObject {
    static let shared = AlarmManager()
    @Published var isAlarmTriggered: Bool = false
    var window: UIWindow?

    private init() {}

    func triggerAlarm() {
        DispatchQueue.main.async {
            self.isAlarmTriggered = true
            self.presentCameraScreen()
        }
    }

    func presentCameraScreen() {
        guard let window = self.window else { return }

        let viewController = UIHostingController(rootView: CameraScreen(isPresented: .constant(true), cameraViewModel: CameraViewModel()))
        viewController.modalPresentationStyle = .fullScreen
        window.rootViewController?.present(viewController, animated: true, completion: nil)
    }

    func handleNotificationResponse() {
        triggerAlarm()
    }
}

