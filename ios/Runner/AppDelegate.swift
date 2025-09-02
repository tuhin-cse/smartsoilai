import Flutter
import UIKit
import flutter_local_notifications
import FirebaseCore
import FirebaseMessaging

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    
    // Set messaging delegate
    Messaging.messaging().delegate = self
    
    // Request permission for notifications
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,
        completionHandler: { _, _ in }
      )
    }
    
    application.registerForRemoteNotifications()
    
    // Flutter Local Notifications Plugin setup
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

// Add Messaging delegate extension
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("Firebase registration token: \(String(describing: fcmToken))")
    
    let dataDict: [String: String] = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: dataDict
    )
  }
}
