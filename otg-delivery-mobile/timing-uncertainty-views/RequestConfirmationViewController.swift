//
//  RequestConfirmationViewController.swift
//  otg-delivery-mobile
//
//  Created by Maggie Lou on 2/26/19.
//  Copyright © 2019 Sam Naser. All rights reserved.
//

import UIKit
import UserNotifications

class RequestConfirmationViewController: UIViewController {
    
    var currentRequest: CoffeeRequest?

    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var meetingPointsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentRequest == nil {
            let alert = UIAlertController(title: "We apologize. There is some error with your order.", message: "", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                let mainPage: OrderViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainOrderViewController") as! OrderViewController
                
                self.present(mainPage, animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        startTimeLabel.text = CoffeeRequest.parseTime(dateAsString: currentRequest!.orderStartTime)
        endTimeLabel.text = CoffeeRequest.parseTime(dateAsString: currentRequest!.orderEndTime)
        
        meetingPointsLabel.text = CoffeeRequest.prettyParseArray(arr: (currentRequest?.deliveryLocationOptions)!)
        

    }
    
    @IBAction func backButton(_ sender: Any) {
        let prevPage: RequestTimeframeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RequestTimeframeViewController") as! RequestTimeframeViewController
        prevPage.currentRequest = currentRequest
        self.present(prevPage, animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        let mainPage: OrderViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainOrderViewController") as! OrderViewController
        
        self.present(mainPage, animated: true, completion: nil)
    }
    
    @IBAction func submitButton(_ sender: Any) {
        currentRequest = setTimeProbabilities(request: currentRequest!)
        CoffeeRequest.postCoffeeRequest(coffeeRequest: currentRequest!)
        
        let defaults = UserDefaults.standard
        var requestsPlaced = defaults.object(forKey: "requestsPlaced") as! Int + 1
        defaults.set(requestsPlaced, forKey: "requestsPlaced")
        
        // Set up notifications
        let secondsNowToStartTime = (CoffeeRequest.stringToDate(s: currentRequest!.orderStartTime)).timeIntervalSinceNow
        
        // Set up request acceptance notification
        let seconds1hr15min = 60 * 5//60 * 75
        let secondsNowToAcceptanceTime =
            Int(secondsNowToStartTime) + seconds1hr15min
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(secondsNowToAcceptanceTime), execute: {
            User.sendNotification(deviceId: Constants.myUserId, message: "Send \(defaults.object(forKey: "username")) notification that their request has been accepted. Tell DTR helper to be ready in 15 min and to choose a meeting point.")
        })
        
        // Set up text user notification
        let seconds1hr23min = 60 * 3//60 * 83
        let secondsNowToTextTime = Int(secondsNowToStartTime) + seconds1hr23min
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(secondsNowToTextTime), execute: {
            User.sendNotification(deviceId: Constants.myUserId, message: "Text user \(String(describing: defaults.object(forKey: "username")))")
        })
        
        // Set up helper arriving soon notification
        // Set up text user notification
        let seconds1hr25min = 60 * 1//60 * 85
        let secondsNowToArrivalNotification = Int(secondsNowToStartTime) + seconds1hr25min
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(secondsNowToArrivalNotification), execute: {
            User.sendNotification(deviceId: defaults.object(forKey:"tokenId") as! String, message: "Your helper is arriving soon! Please go meet them at the meeting point now.")
            User.sendNotification(deviceId: Constants.myUserId, message: "Tell DTR helper to head to meeting point now to meets.")
        })
    }
    
    func sendTaskAcceptanceNotification() {
//        let content = UNMutableNotificationContent()
//        content.title = "Your meeting has been accepted!"
//        content.body = "Your meeting point is:
//
//        Do you have time to deliver food from \(Location.camelCaseToWords(camelCaseString: request.pickupLocation)) before \(CoffeeRequest.parseTime(dateAsString: request.endTime!))? Click here for the delivery location."
//
//        content.categoryIdentifier = "requestNotification"
//        content.sound = UNNotificationSound.default()
//
//        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 5, repeats: false)
//        let notificationRequest = UNNotificationRequest(identifier: "identifier", content: content, trigger: trigger)
//
//        UNUserNotificationCenter.current().add(notificationRequest, withCompletionHandler: { (error) in
//            if let error = error {
//                print("Error in notifying from Pre-Tracker: \(error)")
//            }
//        })
    }
    
    func setTimeProbabilities(request: CoffeeRequest) -> CoffeeRequest {
        let defaults = UserDefaults.standard
        let requestsPlaced = defaults.object(forKey: "requestsPlaced") as! Int
        
        if (requestsPlaced < 1) {
            request.timeProbabilities[1] = "30%"
            request.timeProbabilities[3] = "60%"
        } else {
            request.timeProbabilities[1] = "60%"
            request.timeProbabilities[3] = "30%"
        }
        
        return request
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
