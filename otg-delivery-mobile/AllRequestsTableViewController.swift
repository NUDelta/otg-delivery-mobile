//
//  AllRequestsTableViewController.swift
//  otg-delivery-mobile
//
//  Created by Maggie Lou on 10/8/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import UIKit

class AllRequestsTableViewController: UITableViewController {

    @IBOutlet weak var allRequestsTableView: UITableView!
    
    var requests = [CoffeeRequest]()
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()

        
        // Initialize table
        self.tableView.register(AllRequestsTableViewCell.self, forCellReuseIdentifier: AllRequestsTableViewCell.reuseIdentifier)
        self.allRequestsTableView.delegate = self
        self.allRequestsTableView.dataSource = self
    
        loadData()
        
        // Initialize listener for whenever app becoming active
        // To reload request data and update table
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    // Initializes view for the very first time
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadData()
    }

    
    
    // MARK: - Table view data source

    // Configure cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = AllRequestsTableViewCell()
        let request = requests[indexPath.row]
        
        // Set labels with request data
        cell.pickupDetailsLabel.text = "Tomate"
        cell.dropoffDetailsLabel.text = request.deliveryLocation
        cell.expirationDetailsLabel.text = CoffeeRequest.parseTime(dateAsString: request.endTime!)
        cell.requesterDetailsLabel.text = request.requester?.username ?? "Requester name cannot load"
        cell.priceDetailsLabel.text = String(request.item?.price ?? 0)
        cell.itemDetailsLabel.text = request.item?.description


        // Text wrapping
        cell.pickupDetailsLabel.numberOfLines = 0
        cell.dropoffDetailsLabel.numberOfLines = 0
        cell.expirationDetailsLabel.numberOfLines = 0
        cell.requesterDetailsLabel.numberOfLines = 0
        cell.priceDetailsLabel.numberOfLines = 0
        cell.itemDetailsLabel.numberOfLines = 0

        return cell
    }
    
    //Return number of sections in table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    // Return number of rows in table view
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Number rows \(self.requests.count)")
        return self.requests.count
    }
    
    // Height dynamically responds to size of content
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50 // also UITableViewAutomaticDimension can be used
    }

 
    @objc func loadData() {
        CoffeeRequest.getAllOpen(completionHandler:  { requests in
                self.requests = requests
                DispatchQueue.main.async {
                    self.allRequestsTableView.reloadData()
                }
            }
        )
    }
}
