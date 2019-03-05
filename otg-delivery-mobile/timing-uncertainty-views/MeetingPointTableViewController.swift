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
    var meetingPoints = ["Tech Lobby", "Bridge between Tech and Mudd", "SPAC Entrance", "Kresge Entrance", "Norris Front Entrance", "Main Library Sign-In Desk", "Plex Lobby", "Willard Lobby"]

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
            currentRequest!.deliveryLocationOptions = selectedLocations
            let nextPage: RequestTimeframeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RequestTimeframeViewController") as! RequestTimeframeViewController
            nextPage.currentRequest = currentRequest
            self.present(nextPage, animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        let mainPage: OrderViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainOrderViewController") as! OrderViewController
        
        self.present(mainPage, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        meetingPointTableView.setEditing(true, animated: false)
        
        if currentRequest == nil {
            currentRequest = CoffeeRequest()
            
            let defaults = UserDefaults.standard
            currentRequest!.requesterId = defaults.object(forKey: "userId") as! String
            currentRequest!.status = "Searching for Helper"
        }
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
