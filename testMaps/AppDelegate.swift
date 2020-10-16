//
//  AppDelegate.swift
//  testMaps
//
//  Created by Kseniya Lukoshkina on 25.09.2020.
//

import UIKit
import GoogleMaps
//import RxSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyAIfvW3lAcGTSNn3z_WHTA58KctfEr4HrU")

        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
                case .authorized:
                   print("Разрешение есть")
                case .denied:
                   print("Разрешения нет")
                default:
                    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                        if granted {
                            print("Разрешение получено")
                        } else {
                            print("Разрешение не получено")
                        }
                    }
            }
        }
        
        return true
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

