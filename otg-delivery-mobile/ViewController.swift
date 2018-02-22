//
//  ViewController.swift
//  another_example
//
//  Created by Sam Naser on 1/19/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager: CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        
        
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        //locationManager!.allowsBackgroundLocationUpdates = true
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager?.requestAlwaysAuthorization()
            locationManager?.requestWhenInUseAuthorization()
        }
        
        locationManager?.startUpdatingLocation()
        
    

        let center1 = CLLocationCoordinate2D(latitude: 42.048157, longitude: -87.680825)
        let region1 = CLCircularRegion(center: center1, radius: 100, identifier: "noyes1")
        region1.notifyOnEntry = true
        region1.notifyOnExit = false
        
        
        locationManager?.startMonitoring(for: region1)
        print(locationManager!.monitoredRegions)
        
        sendNotification()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.last!)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Did enter region")
        sendNotification()
    }
    
    
    func sendNotification(){
        print("Sending notification")
        
        let content = UNMutableNotificationContent()
        content.body = "YAY FOR IOS"
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = ""
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 5, repeats: false)
        let notificationRequest = UNNotificationRequest(identifier: "identifier", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(notificationRequest, withCompletionHandler: { (error) in
            if let error = error {
                print("Error in notifying from Pre-Tracker: \(error)")
            }
        })
    }


}

