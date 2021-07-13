//
//  PushNotificationManager.swift
//  Bhakti_Vikasa
//
//  Created by Harsh Rajput on 02/12/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UIKit
import UserNotifications

class PushNotificationManager: NSObject {
    let application: UIApplication
    let gcmMessageIDKey = "gcm.message_id"
    init(application:UIApplication) {
        self.application = application
        super.init()
        self.fireMessagInitilize()
    }
    

  func fireMessagInitilize(){
      Messaging.messaging().delegate = self
     if #available(iOS 10.0, *) {
        // For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: {_, _ in })
      } else {
        let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
      }
      application.registerForRemoteNotifications()
  }
}

//MARK:- FCM
extension PushNotificationManager: MessagingDelegate{
    func getFCMToken(completion:@escaping(String)->Void){
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token: \(token)")
           // self.fcmRegTokenMessage.text  = "Remote FCM registration token: \(token)"
            completion(token)
          }
        }
    }

   func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
     print("Firebase registration token: \(String(describing: fcmToken))")

    // let dataDict:[String: String] = ["token": fcmToken ?? ""]
   //  NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
     // TODO: If necessary send token to application server.
     // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    func application(application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      Messaging.messaging().apnsToken = deviceToken
    }
    // The method will be called on the delegate only if the application is in the foreground. If the method is not implemented or the handler is not called in a timely manner then the notification will not be presented. The application can choose to have the notification presented as a sound, badge, alert and/or in the notification list. This decision should be based on whether the information in the notification is otherwise visible to the user.
    // This method will be called when app received push notifications in foreground
    
  
}
@available(iOS 10, *)
extension PushNotificationManager : UNUserNotificationCenterDelegate {

  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // Print message ID.
    if let messageDetail = userInfo["aps"] {
      print("messageDetail: \(messageDetail)")
    }

    // Print full message.
    print(userInfo)

    // Change this to your preferred presentation option
    completionHandler([.alert, .badge, .sound])
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo
    // Print message ID.
    if let messageDetail = userInfo["aps"] {
      print("messageDetail: \(messageDetail)")
    }

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // Print full message.
    print(userInfo)

    completionHandler()
  }
}



//MARK:- APNS APPLE PUSH NOTIFICATION
extension PushNotificationManager{


    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }

        print(userInfo)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }

    func application(_ application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { //data -> String in
            return String(format: "%02.2hhx", $0)
        }

        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
//        #if DEBUG
//            Messaging.messaging().setAPNSToken(deviceToken, type: .sandbox)
//        #else
//            Messaging.messaging().setAPNSToken(deviceToken, type: .prod)
//        #endif
        UserDefaults.standard.synchronize()
    }
}
