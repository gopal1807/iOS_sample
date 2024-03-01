//
//  FunnyCowApp.swift
//  FunnyCow
//
//  Created by Gopal Krishan on 04/11/20.
//

import SwiftUI
import IQKeyboardManagerSwift
import GoogleSignIn
import Firebase
//import FBSDKCoreKit
import os

@main
struct FunnyCowApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        return WindowGroup {
            TabbarView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate  {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        IQKeyboardManager.shared.enable = false
//        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        let filePath = Bundle.main.path(forResource: googleServiceFileName, ofType: "plist")!
        let firebaseOptions = FirebaseOptions(contentsOfFile: filePath)!
//        GIDSignIn.sharedInstance().clientID = firebaseOptions.clientID
        FirebaseApp.configure(options: firebaseOptions)
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (allowed, error) in
            //This callback does not trigger on main loop be careful
            if allowed {
                os_log(.debug, "Allowed") //import os
            } else {
                os_log(.debug, "Error")
            }
        }
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        return true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else {return}
        print("Firebase registration token: \(token)")
        UserDefaultsController.shared.fcmToken = token
        saveCustFCMToken()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Successfully registered for notifications!")
        let hexString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print(hexString)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error.localizedDescription)")
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//        ApplicationDelegate.shared.application( app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation]) ||
        GIDSignIn.sharedInstance.handle(url)
    }
    
}

// MARK: - FCMRequest
struct FCMRequest: Codable {
    let tID: String
    let data: FCMRequestData
    
    enum CodingKeys: String, CodingKey {
        case tID = "tId"
        case data
    }
}

// MARK: - DataClass
struct FCMRequestData: Codable {
    let custID, fcmToken, deviceType, deviceID: String
    
    enum CodingKeys: String, CodingKey {
        case custID = "custId"
        case fcmToken = "FCMToken"
        case deviceType = "DeviceType"
        case deviceID = "DeviceId"
    }
}

func saveCustFCMToken() {
    guard !UserDefaultsController.shared.fcmToken.isEmpty,
          let custId = UserDefaultsController.shared.userModel?.id
    else { return }
    
    AppToken.shared.getToken { (token) in
        let request = FCMRequest(tID: token, data: FCMRequestData(custID: "\(custId)", fcmToken: UserDefaultsController.shared.fcmToken, deviceType: "2", deviceID: UIDevice.current.identifierForVendor?.uuidString ?? ""))
        HitApi.shared.postData("SaveCustFCMToken", bodyData: request) { (result: Result<String, HitApiError>) in
            switch result {
                case .success(let response):
                    print(response)
                case .failure(let error):
                    print(error.toString())
            }
        }
    }
}
