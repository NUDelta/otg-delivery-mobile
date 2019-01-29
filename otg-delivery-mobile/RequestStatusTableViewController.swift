//
//  RequestStatusTableViewController.swift
//  otg-delivery-mobile
//
//  Created by Maggie Lou on 4/30/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import UIKit

class RequestStatusTableViewController: UITableViewController {
    
    var myRequests = [CoffeeRequest]()
    @IBOutlet weak var MyRequestsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(RequestStatusTableViewCell.self, forCellReuseIdentifier: RequestStatusTableViewCell.reuseIdentifier)

        User.getMyRequests(completionHandler: { coffeeRequests in
            DispatchQueue.main.async {
                self.myRequests = coffeeRequests
                self.MyRequestsTableView.reloadData()
            }
        })
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RequestStatusTableViewCell.reuseIdentifier, for: indexPath) as? RequestStatusTableViewCell else {
            fatalError("Couldn't dequeue RequestStatusTableViewCell")
        }
        
        let request = myRequests[indexPath.row]

        cell.statusDetailsLabel.text = request.status
        cell.expirationDetailsLabel.text = request.endTime
        cell.deliveryLocationDetailsLabel.text = CoffeeRequest.arrayToJson(arr: request.deliveryLocation)
        cell.specialRequestsDetailsLabel.text = request.deliveryLocationDetails
        
        // Text wraps
        cell.orderLabel.numberOfLines = 0
        cell.statusDetailsLabel.numberOfLines = 0
        cell.expirationDetailsLabel.numberOfLines = 0
        cell.deliveryLocationDetailsLabel.numberOfLines = 0
        cell.specialRequestsDetailsLabel.numberOfLines = 0
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myRequests.count
    }
    
    func completeOrderPressed(sender: UIButton!){
        print("Complete order pressed.")
    }
}
