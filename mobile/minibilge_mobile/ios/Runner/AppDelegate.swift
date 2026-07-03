import Flutter
import UIKit
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    // Explicitly request APNS token registration
    application.registerForRemoteNotifications()

    let launched = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    // Badge clearing channel — setup after super so window/rootViewController is ready
    if let controller = window?.rootViewController as? FlutterViewController {
      let badgeChannel = FlutterMethodChannel(
        name: "com.minibilge.app/badge",
        binaryMessenger: controller.binaryMessenger)
      badgeChannel.setMethodCallHandler { (call, result) in
        if call.method == "clearBadge" {
          if #available(iOS 16.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(0) { _ in }
          } else {
            UIApplication.shared.applicationIconBadgeNumber = 0
          }
          result(nil)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return launched
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    clearAppBadge()
    // FCM async badge ayarlamasının üzerine yazmak için kısa gecikmeli tekrar
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      self.clearAppBadge()
    }
  }

  private func clearAppBadge() {
    UIApplication.shared.applicationIconBadgeNumber = 0
    if #available(iOS 16.0, *) {
      UNUserNotificationCenter.current().setBadgeCount(0) { _ in }
    }
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    let tokenHex = deviceToken.map { String(format: "%02x", $0) }.joined()
    NSLog("[APNS] ✅ Got APNS token: \(tokenHex.prefix(20))...")
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    NSLog("[APNS] ❌ Registration FAILED: \(error.localizedDescription)")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
}
