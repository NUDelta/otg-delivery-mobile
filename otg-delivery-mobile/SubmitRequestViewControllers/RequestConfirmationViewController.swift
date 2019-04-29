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

    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var pickupLocationLabel: UILabel!

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

        itemLabel.text = currentRequest!.item
        pickupLocationLabel.text = currentRequest!.pickupLocation
    }

    @IBAction func cancelButton(_ sender: Any) {
        let mainPage: OrderViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainOrderViewController") as! OrderViewController

        self.present(mainPage, animated: true, completion: nil)
    }

    @IBAction func submitButton(_ sender: Any) {
        currentRequest = setTimeProbabilities(request: currentRequest!)
        currentRequest?.status = "Searching for Helper"
        CoffeeRequest.postCoffeeRequest(coffeeRequest: currentRequest!)

        let requestsPlaced = defaults.object(forKey: "requestsPlaced") as! Int + 1
        defaults.set(requestsPlaced, forKey: "requestsPlaced")

        /*
        // Set up notifications
        let secondsNowToStartTime = (CoffeeRequest.stringToDate(s: currentRequest!.orderStartTime)).timeIntervalSinceNow

        // Set up request acceptance notification
        let seconds1hr15min = 60 * 75
        let secondsNowToAcceptanceTime =
            Int(secondsNowToStartTime) + seconds1hr15min
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(secondsNowToAcceptanceTime), execute: {
            User.sendNotification(deviceId: Constants.myUserId, message: "Send \(String(describing: defaults.object(forKey: "username"))) notification that their request has been accepted. Tell DTR helper to be ready in 15 min and to choose a meeting point. Meeting points: \(CoffeeRequest.prettyParseArray(arr: self.currentRequest!.deliveryLocationOptions))")
        })

        // Set up text user notification
        let seconds1hr23min = 60 * 83
        let secondsNowToTextTime = Int(secondsNowToStartTime) + seconds1hr23min
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(secondsNowToTextTime), execute: {
            User.sendNotification(deviceId: Constants.myUserId, message: "Text user \(String(describing: defaults.object(forKey: "username")))")
        })

        // Set up helper arriving soon notification
        // Set up text user notification
        let seconds1hr25min = 60 * 85
        let secondsNowToArrivalNotification = Int(secondsNowToStartTime) + seconds1hr25min
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(secondsNowToArrivalNotification), execute: {
            #if !targetEnvironment(simulator)
            // Simulators can't receive notifications
            User.sendNotification(deviceId: defaults.object(forKey:"tokenId") as! String, message: "Your helper is arriving soon! Please go meet them at the meeting point now.")
            #endif
            User.sendNotification(deviceId: Constants.myUserId, message: "Tell DTR helper to head to meeting point now to meets.")
        })
 */
    }

    func setTimeProbabilities(request: CoffeeRequest) -> CoffeeRequest {
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
}
