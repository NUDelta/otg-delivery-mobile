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
    
    
    @IBAction func cancelButton(_ sender: Any) {
        let mainView: UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainNavController") as! UINavigationController
        self.present(mainView, animated: true, completion: nil)
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
        cell.pickupDetailsLabel.text = Location.camelCaseToWords(camelCaseString: request.pickupLocation)
        cell.dropoffDetailsLabel.text = CoffeeRequest.prettyParseArray(arr: request.deliveryLocation)
        cell.expirationDetailsLabel.text = CoffeeRequest.parseTime(dateAsString: request.endTime!)
        cell.requesterDetailsLabel.text = request.requester?.username ?? "Requester name cannot load"
        cell.priceDetailsLabel.text = String(request.item?.price ?? 0)
        cell.itemDetailsLabel.text = request.item?.name


        // Text wrapping
        cell.pickupDetailsLabel.numberOfLines = 0
        cell.dropoffDetailsLabel.numberOfLines = 0
        cell.expirationDetailsLabel.numberOfLines = 0
        cell.requesterDetailsLabel.numberOfLines = 0
        cell.priceDetailsLabel.numberOfLines = 0
        cell.itemDetailsLabel.numberOfLines = 0

        return cell
    }
    
    // MARK: - Editing, Selecting Cells
    
    // Allow editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Support clicking on a row to trigger functionality (accepting a request)
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let acceptAlert = UIAlertController(title: "Would you like to accept this task?", message: "", preferredStyle: .alert)
        
        let accept = UIAlertAction(title: "OK", style: .default, handler: { (_) in
            // Save ID in defaults so can access later
            let acceptedRequest = self.requests[indexPath.row]
            
            let defaults = UserDefaults.standard
            defaults.set(acceptedRequest.requestId!, forKey: "latestRequestNotification")
            
    
            // Go to meeting point selection
            self.performSegue(withIdentifier: "helperLocationFormSegue", sender: self)
            
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            
        })
        
        acceptAlert.addAction(accept)
        acceptAlert.addAction(cancel)
        present(acceptAlert, animated: true, completion: nil)
        
        allRequestsTableView.deselectRow(at: indexPath as IndexPath, animated: true)
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
