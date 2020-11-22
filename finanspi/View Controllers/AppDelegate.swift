//
//  AppDelegate.swift
//  finanspi
//
//  Created by Abdulsalam Alroas on 9/13/20.
//  Copyright © 2020 Abdulsalam Alroas. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static var standard: AppDelegate {
           return UIApplication.shared.delegate as! AppDelegate
       }

    
    // for ios <  13 to  make StoryBoard Work
    var window: UIWindow?
    var serverURL: String?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UNUserNotificationCenter.current().delegate = self
        var window: UIWindow?
        window = UIWindow(frame: UIScreen.main.bounds)
        
        
        
        // add these lines
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // if user is logged in before
        if let loggedAccessToken = UserDefaults.standard.accessToken {
            print(loggedAccessToken)
            // instantiate the main tab bar controller and set it as root view controller
            // using the storyboard identifier we set earlier
            let home = storyboard.instantiateViewController(withIdentifier: "home")
            self.window?.rootViewController = home
        } else {
            // if user isn't logged in
            // instantiate the navigation controller and set it as root view controller
            // using the storyboard identifier we set earlier
            let login = storyboard.instantiateViewController(withIdentifier: "login")
            self.window?.rootViewController = login
        }
        
        
        // request permission from user to send notification
        registerForPushNotifications()
        
        
        
        
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "finanspi")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    
    
    
    func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard let window = self.window else {
            return
        }
        
        window.rootViewController = vc
        
        // add animation
        UIView.transition(with: window,
                          duration: 0.5,
                          options: [.transitionFlipFromLeft],
                          animations: nil,
                          completion: nil)
        
    }
    
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound,.badge]) {
                [weak self] granted, error in
                UserDefaults.standard.isNotificationPermissionGranted = granted
                print("Permission granted: \(granted)")
                guard granted else { return }
                self?.getNotificationSettings()
            }
        
    }
    
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application( _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        UserDefaults.standard.DeviceToken = token
        print("Device Token: \(token)")
        
        if UserDefaults.standard.isNotificationPermissionGranted {
                let sendDeviceToken = HomeViewController()
                sendDeviceToken.sendDeviceToken(uAccessToken: UserDefaults.standard.accessToken ?? "" , UdeviceToken: UserDefaults.standard.DeviceToken ?? "")
            }
   
       
    }
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        //         reset badge count
        UIApplication.shared.applicationIconBadgeNumber = 0
        UserDefaults.standard.badgeNumber = 0
        if !UserDefaults.standard.isNotificationPermissionGranted {
            if UserDefaults.standard.isNotificationPermissionDdismissed {
                return
            }
            print("burrdan geliyor")
            registerForPushNotifications()
        }
    
        
    }
    
    
    
    func application(_ application: UIApplication,didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let aps = userInfo["aps"] as? [String: AnyObject]
        print("APN recieved")
        
        guard let badge = aps?["badge"] as? Int else { return }
        
        UserDefaults.standard.badgeNumber += badge
        UIApplication.shared.applicationIconBadgeNumber = UserDefaults.standard.badgeNumber
        
        completionHandler(.newData)
    }
    
    
    
    
}



extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

            let userInfo = notification.request.content.userInfo
            print("first")
            print(userInfo)
            completionHandler([.alert,.sound])
         
        
      
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,didReceive response: UNNotificationResponse,withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        print("secend")
        print(userInfo)
     
        //        if let aps = userInfo["link_url"] as? [String: AnyObject],
        if let noUrl = userInfo["link_url"] as? String {
            print(noUrl)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let loggedAccessToken = UserDefaults.standard.accessToken {
                print(loggedAccessToken)
                let home = storyboard.instantiateViewController(withIdentifier: "home")  as! HomeViewController
                home.noUrl = noUrl
                self.window?.rootViewController = home
            } else {
                let login = storyboard.instantiateViewController(withIdentifier: "login")
                self.window?.rootViewController = login
            }
            completionHandler()
        }
        
        
    }
    
    
}
