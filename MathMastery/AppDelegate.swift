import Firebase
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var serviceContainer: ServiceContainer?

    let storageService = UserDefaultsStorageService()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?
    ) -> Bool {
//        FirebaseApp.configure()

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
              windowScene.windows.forEach {
                  $0.overrideUserInterfaceStyle = .light
              }
          }

          return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        Messaging.messaging().apnsToken = deviceToken
    }

    @MainActor
        func application(
            _ application: UIApplication,
            didReceiveRemoteNotification userInfo: [AnyHashable : Any]
        ) async -> UIBackgroundFetchResult {


            return .newData
        }
}

