//
//  AppDelegate.swift
//  QuickBloxSwiftUIVideoChat
//
//  Created by slava bily on 08.09.2021.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

struct CredentialsConstant {
    static let applicationID:UInt = 93728
    static let authKey = "NxwcTMK3dzMkYmA"
    static let authSecret = "8Vwd42GuTXkcubq"
    static let accountKey = "hiaW8XawsCJrHarjYmpz"
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        QBSettings.applicationID = CredentialsConstant.applicationID
        QBSettings.authKey = CredentialsConstant.authKey
        QBSettings.authSecret = CredentialsConstant.authSecret
        QBSettings.accountKey = CredentialsConstant.accountKey
        
        // enabling carbons for chat
        QBSettings.carbonsEnabled = true
        // Enables Quickblox REST API calls debug console output.
        QBSettings.logLevel = .debug
        // Enables detailed XMPP logging in console output.
        QBSettings.enableXMPPLogging()
        QBSettings.disableFileLogging()
        QBSettings.autoReconnectEnabled = true
        
        QBRTCConfig.setLogLevel(QBRTCLogLevel.verbose)
        
        
        return true
    }
    
    // MARK: Managing chat connections
    
        func applicationWillTerminate(_ application: UIApplication) {
            QBChat.instance.disconnect { (error) in
            }
        }
        func applicationDidEnterBackground(_ application: UIApplication) {
            QBChat.instance.disconnect { (error) in
            }
        }
        func applicationWillEnterForeground(_ application: UIApplication) {
//            QBChat.instance.connect(withUserID: currentUser.ID, password: currentUser.password) { (error) in
//            }
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


}

