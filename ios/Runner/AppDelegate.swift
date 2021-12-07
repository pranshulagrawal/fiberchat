import UIKit
import Flutter
import Firebase
import FirebaseMessaging
import FirebaseAuth


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    if #available(iOS 10.0, *) {
  UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
  }
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
  // application.registerForRemoteNotifications()  
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)

  }
   override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Auth.auth().setAPNSToken(deviceToken, type: .prod)
    }

    override func application(_ application: UIApplication,
        didReceiveRemoteNotification notification: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let center = UNUserNotificationCenter.current()
        let aps = notification["aps"] as? [String: Any]
        let alert = aps?["alert"] as? [String: String]
        // let title = alert?["title"]as? String ?? ""        <-- correct way
        let title = alert?["title"]
        let body = alert?["body"]
        // print(title ?? "nil")
        // print(title=="uh")
        // let string = title??"nil"
        // if string.contains("Swift") {
        //     print("exists")
        // }
        if title=="Call Ended" {
        //  application.applicationIconBadgeNumber = 0 // For Clear Badge Counts
        center.removeAllDeliveredNotifications() // To remove all delivered notifications
        center.removeAllPendingNotificationRequests()
        
        }
       if title=="Missed Call" {
        //  application.applicationIconBadgeNumber = 0 // For Clear Badge Counts
        center.removeAllDeliveredNotifications() // To remove all delivered notifications
         center.removeAllPendingNotificationRequests()
       
       }   
  if Auth.auth().canHandleNotification(notification) {
    completionHandler(.newData)
    return
  }
    completionHandler(.newData)
    //  completionHandler(UIBackgroundFetchResult.newData)
    
}
}




