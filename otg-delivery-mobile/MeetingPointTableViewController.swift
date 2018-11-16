//
//  MeetingPointTableViewController.swift
//  otg-delivery-mobile
//
//  Created by Maggie Lou on 11/15/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import UIKit

class MeetingPointTableViewController: UITableViewController {
    
    var currentRequest: CoffeeRequest?
    var meetingPoints = ["Tech Lobby", "Ford Lobby", "Bridge between Tech and Mudd", "DTR Space Mudd", "SPAC Lobby", "Corner of Sheridan and Noyes", "Norris Starbucks", "Main Library Sign-In Desk"]

    @IBOutlet var meetingPointTableView: UITableView!
    
    @IBAction func submitButton(_ sender: Any) {
        var selectedLocations = [] as [String]
        
        // Grab selected locations
        if let selectedRows = meetingPointTableView.indexPathsForSelectedRows {
            for row in selectedRows{
                var cell = meetingPointTableView.cellForRow(at: row) as! MeetingPointTableViewCell
                selectedLocations.append(cell.locationLabel.text!)
            }
        }
        
        if selectedLocations.count == 0 {
            let alert = UIAlertController(title: "No meeting points selected.", message: "You must select at least one location from the list below.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                
            }))
            
            self.present(alert, animated: true, completion: nil)
        } else {
            // Set locations on request object
            currentRequest?.deliveryLocation = selectedLocations
            
            let alert = UIAlertController(title: "Are you sure you want to submit this request?", message: "You will be notified of your meeting point when a helper accepts. You are expected at this meeting point within 5 minutes of when your helper texts that they are on their way.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { _ in
                CoffeeRequest.postCoffeeRequest(coffeeRequest: self.currentRequest!)
                self.dismiss(animated: true, completion: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        meetingPointTableView.setEditing(true, animated: false)
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
    
    func tableView(tableView: UITableView,editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
            
        // Selectable check marks
        return UITableViewCellEditingStyle.init(rawValue: 3)!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedLocation = meetingPoints[indexPath.row]
    }
}
