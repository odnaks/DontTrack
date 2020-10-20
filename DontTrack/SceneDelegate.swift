//
//  SceneDelegate.swift
//  testMaps
//
//  Created by Kseniya Lukoshkina on 25.09.2020.
//

import UIKit
import UserNotifications

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        
        self.window?.viewWithTag(2905)?.removeFromSuperview()
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    private func makeNotificationContent() -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "hello"
        content.subtitle = "возвращайся в приложение"
        content.body = "ты еще не успел построить свой маршрут"
        // Цифра в бейдже на иконке
        content.badge = 777
        return content
    }
    
    private func makeIntervalNotificatioTrigger() -> UNNotificationTrigger {
        return UNTimeIntervalNotificationTrigger(
            timeInterval: 30,
            repeats: false
        )
    }
    
    private func sendNotificatioRequest(
            content: UNNotificationContent,
            trigger: UNNotificationTrigger) {
            
        let request = UNNotificationRequest(
            identifier: "hello",
            content: content,
            trigger: trigger
        )
        
        let center = UNUserNotificationCenter.current()
        center.add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        
        //blue view
        let blurredView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        guard let window = window else {return}
        blurredView.frame = window.frame
        blurredView.tag = 2905
        
        self.window?.addSubview(blurredView)
        
        //call notification
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { [unowned self] settings in
            switch settings.authorizationStatus {
                case .authorized:
                    print("Разрешение есть")
                    self.sendNotificatioRequest(content: self.makeNotificationContent(),
                                                 trigger: self.makeIntervalNotificatioTrigger())
                case .denied:
                    print("Разрешения нет")
                default:
                    break
            }
        }
        
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

