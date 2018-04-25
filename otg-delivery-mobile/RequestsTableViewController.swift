//
//  RequestsTableViewController.swift
//  otg-delivery-mobile
//
//  Created by Sam Naser on 4/25/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import UIKit

class RequestsTableViewController: UITableViewController {

    
    var requests = [CoffeeRequest]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.topItem?.title = "Requests"
        loadRequests()
        
        // Initialize listener for whenever app becoming active
        // To reload request data and update table
        NotificationCenter.default.addObserver(self, selector: #selector(loadRequests), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)

    }


    
    @objc func loadRequests() {
        CoffeeRequest.getMyRequest(completionHandler: { coffeeRequests in
            DispatchQueue.main.async {
                self.requests = coffeeRequests
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
        return self.requests.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyRequestTableViewCell", for: indexPath) as? MyRequestTableViewCell else {
            fatalError("The dequeued cell is not an instance of MyRequestTableViewCell")
        }
        
        
        // Grab request to render
        let request = self.requests[indexPath.row]
            
        // Configure display cell
        cell.orderLabel.text = request.orderDescription
        cell.statusLabel.text = request.status
        
        return cell
        
    }


    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "loginSegue",
            let navController = segue.destination as? UINavigationController,
            let controller = navController.viewControllers.first as? LoginViewController else {
                return
        }
        
        controller.didLogIn = { [weak self] in
            DispatchQueue.main.async {
                self?.dismiss(animated: true, completion: nil)
            }
        }
        
    }

}
