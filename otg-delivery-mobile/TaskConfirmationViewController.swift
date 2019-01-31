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
    @IBOutlet weak var pickupLocationLabel: UILabel!
    
    @IBAction func acceptButton(_ sender: UIButton) {
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
        self.pickupLocationLabel.text = currentRequest!.pickupLocation
        
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "deliveryTimeframeSegue" {
            let navController = segue.destination as? DeliveryTimeframeTableViewController
            // Pass current request to next screen
            navController?.meetingPoint = meetingPoint
        }
    }
}
