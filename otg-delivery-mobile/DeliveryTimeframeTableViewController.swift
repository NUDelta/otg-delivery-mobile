//
//  DeliveryTimeframeTableViewController.swift
//  otg-delivery-mobile
//
//  Created by Maggie Lou on 1/30/19.
//  Copyright © 2019 Sam Naser. All rights reserved.
//

import UIKit

class DeliveryTimeframeTableViewController: UITableViewController {
    var timeEstimates = ["Within 15 Minutes", "Within 30 Minutes", "Within 1 Hour", "Over 1 Hour"]
    var meetingPoint: String = ""
    
    @IBOutlet var deliveryTimeframeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeEstimates.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "DeliveryTimeframeTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DeliveryTimeframeTableViewCell
        
        let timeframe = timeEstimates[indexPath.row]
        
        cell.timeframeLabel.text = timeframe
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get ID of pending request
        let defaults = UserDefaults.standard
        let latestRequestId = defaults.object(forKey: "latestRequestNotification")!
        
        // Accept order and return to requests page
        let timeEstimate = timeEstimates[indexPath.row]
        User.acceptRequest(requestId: latestRequestId as! String, meetingPoint: meetingPoint, timeEstimate: timeEstimate, completionHandler: {
            print("REQUEST ACCEPTED: request successfully accepted.")
        })
        
        let mainView: UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainNavController") as! UINavigationController
        self.present(mainView, animated: true, completion: nil)
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
