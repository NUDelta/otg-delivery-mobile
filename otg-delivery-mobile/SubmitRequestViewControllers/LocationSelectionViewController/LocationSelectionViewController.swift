//
//  LocationSelectionViewController.swift
//  otg-delivery-mobile
//
//  Created by Cooper Barth on 4/28/19.
//  Copyright © 2019 Sam Naser. All rights reserved.
//

import UIKit

class LocationSelectionViewController: UITableViewController {
    var currentRequest: CoffeeRequest?
    var locations = [Location]()

    @IBOutlet var locationTable: UITableView!

    override func viewDidLoad() {
        loadData()
        super.viewDidLoad()

        if currentRequest == nil {
            initializeRequest()
        }
    }

    @IBAction func cancelButton(_ sender: Any) {
        let mainPage: OrderViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainOrderViewController") as! OrderViewController

        self.present(mainPage, animated: true, completion: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationSelectionTableViewCell", for: indexPath) as! LocationSelectionTableViewCell

        //Configure cell
        let location = locations[indexPath.row]
        cell.LocationLabel.text = location.name

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedLocation = locations[indexPath.row]
        currentRequest!.pickupLocation = selectedLocation.name

        let nextPage: ItemSelectionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ItemSelectionTableViewController") as! ItemSelectionViewController
        nextPage.currentRequest = currentRequest
        self.present(nextPage, animated: true, completion: nil)
    }

    func initializeRequest() {
        currentRequest = CoffeeRequest()
        currentRequest!.requesterId = defaults.object(forKey: "userId") as! String
        currentRequest!.helperId = defaults.object(forKey: "userId") as! String //hacky but whatever
        currentRequest!.status = "Searching for Helper"
        currentRequest!.price = "0.00"
    }

    func loadData() {
        Location.getAll(completionHandler: {locations in self.locations = locations
            DispatchQueue.main.async {
                self.locationTable.reloadData()
            }
        })
    }
}
