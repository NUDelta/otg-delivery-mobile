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

class OrderViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager: CLLocationManager?
    let coffeeLocations: [(locationName: String, location: CLLocationCoordinate2D)] = [
        ("Norbucks", CLLocationCoordinate2D(latitude: 42.053343, longitude: -87.672956)),
        ("Sherbucks", CLLocationCoordinate2D(latitude: 42.04971, longitude: -87.682014)),
        ("Kresge Starbucks", CLLocationCoordinate2D(latitude: 42.051725, longitude: -87.675103)),
        ("Fran's", CLLocationCoordinate2D(latitude: 42.051717, longitude: -87.681063)),
        ("Coffee Lab", CLLocationCoordinate2D(latitude: 42.058518, longitude: -87.683645)),
        ("Kaffein", CLLocationCoordinate2D(latitude: 42.046968, longitude: -87.679088))
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize location manager
        locationManager = CLLocationManager()
        
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager?.requestAlwaysAuthorization()
            locationManager?.requestWhenInUseAuthorization()
        }
        
        locationManager?.startUpdatingLocation()
        
        // use our predefined locations to setup the geo-fences
        for coffeeLocation in coffeeLocations {
            let region = CLCircularRegion(center: coffeeLocation.1, radius: 100, identifier: coffeeLocation.0)
            region.notifyOnEntry = true
            region.notifyOnExit = false
        
            locationManager?.startMonitoring(for: region)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.last!)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("User entered within coffee region.")

        CoffeeRequest.getCoffeeRequest(completionHandler: { coffeeRequest in
            print("Should be printing request...")
            print(coffeeRequest ?? "Request not set...")
            
            if let coffeeReq = coffeeRequest {
                
                //set most recent request in user defaults
                let defaults = UserDefaults.standard
                defaults.set(coffeeReq.requestId!, forKey: "latestRequestNotification")
                
                self.sendNotification(locationName: region.identifier, coffeeRequest: coffeeReq)
            }
            
        })
        
    }
    
    
    func sendNotification(locationName: String, coffeeRequest: CoffeeRequest){

        print("VIEW CONTROLLER: sending coffee pickup notification")
        
        let content = UNMutableNotificationContent()
        content.title = coffeeRequest.requester + " needs coffee!"
        content.body = "Please pick up a " + coffeeRequest.orderDescription + " from " + locationName;
        content.categoryIdentifier = "requestNotification"
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 5, repeats: false)
        let notificationRequest = UNNotificationRequest(identifier: "identifier", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(notificationRequest, withCompletionHandler: { (error) in
            if let error = error {
                print("Error in notifying from Pre-Tracker: \(error)")
            }
        })
    }


}

