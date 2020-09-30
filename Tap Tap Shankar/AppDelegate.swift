//
//  AppDelegate.swift
//  Tap Tap Shankar
//
//  Created by Brian Arias Cano on 6/14/20.
//  Copyright © 2020 Brian Arias Cano. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //need to clear the notification badge
        
        application.applicationIconBadgeNumber = 0
        
        //firebase
        FirebaseApp.configure()
        
        //notifications
        
        registerForPushNotifications()
        
        Messaging.messaging().delegate = self as? MessagingDelegate

        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
     
        //if the player is in a lobby and the app terminates, leave the lobby
        if let lobbyInformation = LocalStorageService.retrieveLobbyInformation() {
            
            MultiplayerHandler.leaveLobby(playerID: lobbyInformation["playerID"]!, lobbyID: lobbyInformation["lobbyID"]!)
            
            LocalStorageService.clearLobbyInformation() //clear local copy of information from the device
            
        }
        
    }
    
    ///get notification settings
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        
    }
    
    ///ask  the user for permission for notifications
    func registerForPushNotifications() {
        UNUserNotificationCenter.current() // 1
            .requestAuthorization(options: [.alert, .sound, .badge]) { // 2
                [weak self] granted, error in
                
                print("Permission granted: \(granted)")
                guard granted else { return }
                self?.getNotificationSettings()
                
        }
    }
    
    
    ///user has approved notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        
        //need to save device token
        
        print("Device Token: \(token)") //debugging
        
        LocalStorageService.saveDeviceToken(token: token) //save device token
        
        //get the token up as a topic for remote notifications
        Messaging.messaging().subscribe(toTopic: token) { error in
            
            if error != nil {
                print(error!)
            }
            
        }
        
    }
    
    ///user did not approve notifications
    func application(_ application: UIApplication,didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
}

