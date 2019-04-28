//
//  MeetingPointTableViewController.swift
//  otg-delivery-mobile
//
//  Created by Maggie Lou on 11/15/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import UIKit

class MeetingPointTableViewController: UITableViewController {
    /*
    var currentRequest: CoffeeRequest?
    var meetingPoints = [MeetingPoint]()

    @IBOutlet var meetingPointTableView: UITableView!
    
    @IBAction func submitButton(_ sender: Any) {
        var selectedLocations = [] as [String]
        
        // Grab selected locations
        if let selectedRows = meetingPointTableView.indexPathsForSelectedRows {
            for row in selectedRows{
                let cell = meetingPointTableView.cellForRow(at: row) as! MeetingPointTableViewCell
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
            let nextPage: RequestConfirmationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RequestConfirmationViewController") as! RequestConfirmationViewController
            nextPage.currentRequest = currentRequest
            self.present(nextPage, animated: true, completion: nil)
        }
    }
    @IBAction func backButton(_ sender: UIButton) {
        let prevPage: RequestTimeframeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RequestTimeframeViewController") as! RequestTimeframeViewController
        prevPage.currentRequest = currentRequest
        self.present(prevPage, animated: true, completion: nil)
    }
    
    
    @IBAction func cancelButton(_ sender: Any) {
        let mainPage: OrderViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainOrderViewController") as! OrderViewController
        
        self.present(mainPage, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        loadData()
        super.viewDidLoad()
        meetingPointTableView.setEditing(true, animated: false)
        
        if currentRequest == nil {
            let alert = UIAlertController(title: "We apologize. There is some error with your order.", message: "", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                let mainPage: OrderViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainOrderViewController") as! OrderViewController
                
                self.present(mainPage, animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
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
        
        let meetingPoint = meetingPoints[indexPath.row]

        cell.locationLabel.text = meetingPoint.name

        return cell
    }
    
    func tableView(tableView: UITableView,editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell.EditingStyle {
            
        // Selectable check marks
        return UITableViewCell.EditingStyle.init(rawValue: 3)!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //var selectedLocation = meetingPoints[indexPath.row]
    }

    func loadData() {
        MeetingPoint.getAll(completionHandler: { meetingPoints in
            print(meetingPoints)
            self.meetingPoints = meetingPoints
            DispatchQueue.main.async {
                self.meetingPointTableView.reloadData()
            }
        })
    }
 */
}
