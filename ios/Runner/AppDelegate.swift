import UIKit
import Firebase
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    print("AppDelegate: Starting didFinishLaunchingWithOptions")

    // Firebase setup with error handling
    do {
      print("AppDelegate: Configuring Firebase")
      try FirebaseApp.configure()
      print("AppDelegate: Firebase configured successfully")
    } catch {
      print("AppDelegate: Firebase configuration failed: \(error.localizedDescription)")
      // Don’t crash; proceed to isolate if Firebase is the issue
      return true
    }

    print("AppDelegate: Registering plugins")
    GeneratedPluginRegistrant.register(with: self)

    print("AppDelegate: Setting notification delegate")
    UNUserNotificationCenter.current().delegate = self

    print("AppDelegate: Registering for remote notifications")
    application.registerForRemoteNotifications()

    print("AppDelegate: Calling super")
    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    print("AppDelegate: Super returned \(result)")

    return result
  }

  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    print("AppDelegate: Registered for notifications with token: \(deviceToken)")
    Messaging.messaging().apnsToken = deviceToken
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("AppDelegate: Failed to register for notifications: \(error.localizedDescription)")
  }
}