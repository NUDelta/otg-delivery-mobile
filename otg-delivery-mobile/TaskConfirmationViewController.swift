//
//  TaskConfirmationViewController.swift
//  otg-delivery-mobile
//
//  Created by Maggie Lou on 5/10/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import UIKit

class TaskConfirmationViewController: UIViewController {

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
        User.acceptRequest(requestId: latestRequestId as! String, completionHandler: {
            print("REQUEST ACCEPTED: request successfully accepted.")
        })
        let mainView: UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainNavController") as! UINavigationController
        self.present(mainView, animated: true, completion: nil)
    }
    @IBAction func declineButton(_ sender: UIButton) {
        // Return to requests page
        let allRequestsView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "allRequestsTableViewControllerID") as! AllRequestsTableViewController// storyboard.instantiateInitialViewControllerwithIdentifier("allRequestsTableViewControllerID") as! AllRequestsTableViewController
            //
        self.present(allRequestsView, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        // Get ID of pending request
        let defaults = UserDefaults.standard
        let latestRequestId = defaults.object(forKey: "latestRequestNotification")!

        CoffeeRequest.getRequest(with_id: latestRequestId as! String, completionHandler: { (request) in
            guard let request = request else {
                print("No request returned after helper clicked on notification.")

                return
            }
            
            DispatchQueue.main.async {
                self.expirationLabel.text = CoffeeRequest.parseTime(dateAsString: request.endTime!)
                self.orderLabel.text = request.item?.name ?? "Item name not loading - please contact requester"
                self.locationLabel.text = request.deliveryLocation
                self.locationDetailsLabel.text = request.deliveryLocationDetails
                self.requesterLabel.text = request.requester?.username ?? "Requester"
            }
        })
            
        super.viewDidLoad()
            
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
