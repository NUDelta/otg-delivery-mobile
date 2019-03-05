//
//  AppDelegate.swift
//  another_example
//
//  Created by Sam Naser on 1/19/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, CLLocationManagerDelegate {

    var window: UIWindow?

    func registerForNotifications() {
        print("Registering categories for local notifications")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (granted, error) in
            if (granted) {
                
                // setup notification categories
                let acceptAction = UNNotificationAction(identifier: "acceptNotification", title: "I'm interested! Show me the details.", options: [.foreground])
                let rejectActionTime = UNNotificationAction(identifier: "rejectNotification", title: "No - I'm in a hurry.", options: [.destructive])
                let rejectActionInterest = UNNotificationAction(identifier: "rejectNotification", title: "No - I don't feel like it.", options: [.destructive])
                let rejectActionOther = UNNotificationAction(identifier: "rejectNotification", title: "No - other.", options: [.destructive])
                
                let category = UNNotificationCategory(identifier: "requestNotification", actions: [acceptAction, rejectActionTime, rejectActionInterest, rejectActionOther], intentIdentifiers: [], options: [])

                // setup notification categories
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                UNUserNotificationCenter.current().setNotificationCategories([category])
                
                // setup remote notifications
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
                print("Notification setup complete")
            } else {
                print("Error when registering for notifications: \(String(describing: error))")
            }
        })
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        UNUserNotificationCenter.current().delegate = self
        registerForNotifications()
        
        // Restart terminated app if receives a location update
        if let locationValue = launchOptions?[UIApplicationLaunchOptionsKey.location] {
            var locationManager = CLLocationManager()
            
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.delegate = self
            // Accuracy of location data
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            // The minimum distance before an update event is generated
            locationManager.distanceFilter = 50.0
            
            // Enable location tracking when app sleeps
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.startMonitoringSignificantLocationChanges()
            
            if CLLocationManager.authorizationStatus() == .notDetermined {
                locationManager.requestAlwaysAuthorization()
                locationManager.requestWhenInUseAuthorization()
            }
            
            locationManager.startUpdatingLocation()
        }
        
        if #available(iOS 11, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            application.registerForRemoteNotifications()
        }
        
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            application.registerForRemoteNotifications()
        }
            // iOS 9 support
        else if #available(iOS 9, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 8 support
        else if #available(iOS 8, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 7 support
        else {
            application.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
        }
        
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locToSave = locations.last!
        
        let latitude = Double(locToSave.coordinate.latitude)
        let longitude = Double(locToSave.coordinate.longitude)
        let speed = Double(locToSave.speed)
        let direction = Double(locToSave.course)
        let uncertainty = Double(locToSave.horizontalAccuracy)
        let timestamp = Date()
        
        let locUpdate = LocationUpdate(latitude: latitude, longitude: longitude, speed: speed, direction: direction, uncertainty: uncertainty, timestamp: timestamp, userId: "Fake")
        LocationUpdate.post(locUpdate: locUpdate)
    }
	
//    //Handle user response to notification
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        
//        //Switch over user response to our notification
//        switch response.actionIdentifier {
//            
//            case "acceptNotification":
//                showPendingRequest()
//            case "rejectNotification":
//                //Should log this to server for research purposes perhaps??
//                print("NOTIFICATION ACTION: request rejected.")
//            default:
//            
//        }
//        
//        //not sure why this needs to be here
//        completionHandler()
//        
//    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        // Set requests screen as default view controller
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = sb.instantiateViewController(withIdentifier: "mainNavController") as! UINavigationController
        window?.rootViewController = mainVC
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK - Push Notification Setup
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .none {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let defaults = UserDefaults.standard

        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print(deviceTokenString)
        defaults.set(deviceTokenString, forKey: "tokenId")
        
        defaults.set(0, forKey: "lastNotified")
    }
    
    // Handle silent push notifications
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // refresh data when notification is received
        if (userInfo.index(forKey: "updateType") != nil) {
            if let updateType = userInfo["updateType"] as? String {
                if (updateType == "requests") {
                    OrderViewController.sharedManager.loadData()
                }
                completionHandler(UIBackgroundFetchResult.newData)
            }
        } else {
            completionHandler(UIBackgroundFetchResult.noData)
        }
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // The token is not currently available.
        print("Remote notification support is unavailable due to error: \(error.localizedDescription)")
    }

    

}

