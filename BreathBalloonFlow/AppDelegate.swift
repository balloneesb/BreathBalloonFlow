//
//  AppDelegate.swift
//  BreathBalloonFlow
//
//  Created by vo on 08.07.2025.
//

import UIKit
import AppsFlyerLib
import OneSignalFramework

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        prepareAppsFlyer()
        setOneSignal(with: launchOptions)
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    @objc func initializeAppsFlyer() {
        AppsFlyerLib.shared().start()
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let notificationInfo = response.notification.request.content.userInfo
        
        if let customData = notificationInfo["custom"] as? [AnyHashable: Any], let pushContent = customData["u"] as? String {
            notifySystem(pushContent: pushContent)
        }
        
        completionHandler()
    }

    private func notifySystem(pushContent: String) {
        NotificationCenter.default.post(name: .handlePushDelivery, object: nil, userInfo: ["pushContent": pushContent])
    }
}

extension AppDelegate {
    
    func prepareAppsFlyer() {
        AppsFlyerLib.shared().appsFlyerDevKey = AppCoreConfig.appsFlyerSDKKey
        AppsFlyerLib.shared().appleAppID = AppCoreConfig.appStoreID
        AppsFlyerLib.shared().customerUserID = AppsFlyerLib.shared().getAppsFlyerUID()
        
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 90)
        
        NotificationCenter.default.addObserver(self, selector: NSSelectorFromString("initializeAppsFlyer"), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
}

extension AppDelegate {

    func setOneSignal(with options: [UIApplication.LaunchOptionsKey: Any]?) {
        
        OneSignal.initialize(AppCoreConfig.oneSignalAppToken, withLaunchOptions: options)
          OneSignal.Notifications.requestPermission({ userConsent in
            print("Notification consent granted by user: \(userConsent)")
          }, fallbackToSettings: true)
        
    }

}
