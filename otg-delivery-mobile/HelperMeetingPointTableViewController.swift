//
//  HelperMeetingPointTableViewController.swift
//  otg-delivery-mobile
//
//  Created by Maggie Lou on 11/15/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import UIKit

class HelperMeetingPointTableViewController: UITableViewController {
    
    var meetingPoints = [] as [String]
    var currentRequest: CoffeeRequest?
    var selectedLocation: String = ""
    
    @IBOutlet var meetingPointTableView: UITableView!

    @IBAction func cancelButton(_ sender: Any) {
        let mainView: UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainNavController") as! UINavigationController
        self.present(mainView, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        // Grab eligible meeting points from request object
        let defaults = UserDefaults.standard
        let requestId = defaults.object(forKey: "latestRequestNotification")!
        
        CoffeeRequest.getRequest(with_id: requestId as! String, completionHandler: { (request) in
            guard let request = request else {
                print("No request returned after helper clicked on notification.")
                
                return
            }
            
            self.currentRequest = request
            DispatchQueue.main.async {
                self.meetingPoints = request.deliveryLocation
                self.meetingPointTableView.reloadData()
            }
        });
            
            // Parse JSON string into string array
            
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meetingPoints.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MeetingPointTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MeetingPointTableViewCell
        
        let location = meetingPoints[indexPath.row]
        
        cell.locationLabel.text = location
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedLocation = meetingPoints[indexPath.row]
        
        self.performSegue(withIdentifier: "taskConfirmationSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Button press segue defined in story board
        if segue.identifier == "taskConfirmationSegue" {
            let navController = segue.destination as? TaskConfirmationViewController
            
            // Pass task and meeting point to next screen
            navController?.currentRequest = currentRequest
            navController?.meetingPoint = selectedLocation
        }
    }

}
