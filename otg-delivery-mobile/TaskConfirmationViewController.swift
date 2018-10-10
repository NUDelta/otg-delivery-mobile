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
        UserModel.acceptRequest(requestId: latestRequestId as! String, completionHandler: {
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

        let request = CoffeeRequest.getRequest(with_id: latestRequestId as! String, completionHandler: { (request) in
            guard let request = request else {
                print("No request returned after helper clicked on notification.")

                return
            }
            
            DispatchQueue.main.async {
                self.expirationLabel.text = CoffeeRequest.parseTime(dateAsString: request.endTime!)
                self.orderLabel.text = request.orderDescription
                self.locationLabel.text = request.deliveryLocation
                self.locationDetailsLabel.text = request.deliveryLocationDetails
            }
            
            
            UserModel.get(with_id: request.requester, completionHandler: { helperUserModel in

                guard let helperUserModel = helperUserModel else {
                    print("No helper returned when getting user after helper clicked on notiication.")
                    return
                }
                
                DispatchQueue.main.async {
                    self.requesterLabel.text = helperUserModel.username
                }
            })

        })
            
        super.viewDidLoad()
            
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
