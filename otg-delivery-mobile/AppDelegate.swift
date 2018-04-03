//
//  AppDelegate.swift
//  another_example
//
//  Created by Sam Naser on 1/19/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func registerForNotifications() {
        print("Registering categories for local notifications")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (granted, error) in
            if (granted) {
                
                // setup notification categories
                let acceptAction = UNNotificationAction(identifier: "acceptNotification", title: "Accept", options: [.foreground])
                let rejectAction = UNNotificationAction(identifier: "rejectNotification", title: "Reject", options: [.destructive])
                
                let category = UNNotificationCategory(identifier: "requestNotification", actions: [acceptAction, rejectAction], intentIdentifiers: [], options: [])

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
        
        return true
    }
	
    //Handle user response to notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        //Switch over user response to our notification
        switch response.actionIdentifier {
            
            case "acceptNotification":
                acceptLatestRequest()
            case "rejectNotification":
                //If rejected, log to console but do nothing
                //Should log this to server for research purposes perhaps??
                print("NOTIFICATION ACTION: request rejected.")
            default:
                acceptLatestRequest()
            
        }
        
        //not sure why this needs to be here
        completionHandler()
        
    }
    
    //Method that accepts the latest request stored in UserDefaults
    //And notifies the user on next steps.
    func acceptLatestRequest() {
        
        //Since we set the latestNotificationID in UserDefaults each time user enters a Geofence
        //If the task is accepted, we can pull it out from there and use it to talk to server
        let defaults = UserDefaults.standard
        let latestNotificationId = defaults.object(forKey: "latestRequestNotification")!
        
        CoffeeRequest.acceptCoffeeRequestForID(requestId: latestNotificationId as! String, completionHandler: {
            print("NOTIFICATION ACTION: request successfully accepted.")
        })
        
        //Create and show alert
        let acceptedAlert = UIAlertView()
        acceptedAlert.title = "Thanks!"
        acceptedAlert.message = "You're awesome for picking up coffee! Please let the requester know through Slack that you're on your way."
        acceptedAlert.addButton(withTitle: "Ok")
        acceptedAlert.show()
    }
    
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
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

