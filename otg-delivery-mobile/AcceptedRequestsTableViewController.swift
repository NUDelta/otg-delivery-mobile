//
//  AcceptedRequestsTableViewController.swift
//  otg-delivery-mobile
//
//  Created by Sam Naser on 4/25/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import UIKit

class AcceptedRequestsTableViewController: UITableViewController {

    var acceptedRequests = [CoffeeRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.topItem?.title = "Accepted"
        loadAcceptedRequests()
        
        // Initialize listener for whenever app becoming active
        // To reload request data and update table
        NotificationCenter.default.addObserver(self, selector: #selector(loadAcceptedRequests), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
    }

    @objc func loadAcceptedRequests() {
        CoffeeRequest.getMyAcceptedRequests(completionHandler: { coffeeRequests in
            DispatchQueue.main.async {
                self.acceptedRequests = coffeeRequests
                self.tableView.reloadData()
            }
        })
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.acceptedRequests.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyRequestTableViewCell", for: indexPath) as? MyRequestTableViewCell else {
            fatalError("The dequeued cell is not an instance of MyRequestTableViewCell")
        }
        
        // Grab request to render
        let request = self.acceptedRequests[indexPath.row]
            
        // Configure display cell
        cell.orderLabel.text = request.orderDescription
        cell.statusLabel.text = "Accepted"
    
    
        return cell
        
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
