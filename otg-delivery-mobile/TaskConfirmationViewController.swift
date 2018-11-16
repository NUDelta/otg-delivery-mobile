//
//  TaskConfirmationViewController.swift
//  otg-delivery-mobile
//
//  Created by Maggie Lou on 5/10/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import UIKit

class TaskConfirmationViewController: UIViewController {

    var currentRequest: CoffeeRequest?
    var meetingPoint: String = ""
    
    @IBOutlet weak var requesterLabel: UILabel!
    @IBOutlet weak var expirationLabel: UILabel!
    @IBOutlet weak var orderLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationDetailsLabel: UILabel!
    
    @IBAction func acceptButton(_ sender: UIButton) {
        // Get ID of pending request
        let defaults = UserDefaults.standard
        let latestRequestId = defaults.object(forKey: "latestRequestNotification")!
        
        // Accept order and return to requests page
        User.acceptRequest(requestId: latestRequestId as! String, meetingPoint: meetingPoint, completionHandler: {
            print("REQUEST ACCEPTED: request successfully accepted.")
        })
        
        let alert = UIAlertController(title: "Thank you for your help!", message: "Please text the requester when you are on your way, using the 'Contact Requester' button on your home screen.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            let mainView: UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainNavController") as! UINavigationController
            self.present(mainView, animated: true, completion: nil)
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func declineButton(_ sender: UIButton) {
        // Return to requests page
        let allRequestsView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "allRequestsTableViewControllerID") as! AllRequestsTableViewController
        self.present(allRequestsView, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        self.expirationLabel.text = CoffeeRequest.parseTime(dateAsString: currentRequest!.endTime!)
        self.orderLabel.text = currentRequest!.item?.name ?? "Item name not loading - please contact requester"
        self.locationLabel.text = meetingPoint
        self.locationDetailsLabel.text = currentRequest!.deliveryLocationDetails
        self.requesterLabel.text = currentRequest!.requester?.username ?? "Requester"
        
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
