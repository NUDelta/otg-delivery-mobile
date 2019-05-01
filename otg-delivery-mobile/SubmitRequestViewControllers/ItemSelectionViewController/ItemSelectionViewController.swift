//
//  ItemSelectionTableViewController.swift
//  otg-delivery-mobile
//
//  Created by Maggie Lou on 3/8/19.
//  Copyright © 2019 Sam Naser. All rights reserved.
//

import UIKit

class ItemSelectionViewController: UITableViewController {
    var currentRequest: CoffeeRequest?
    var items = [Item]()

    @IBOutlet var menuItemTable: UITableView!

    override func viewDidLoad() {
        loadData()
        super.viewDidLoad()

        if currentRequest == nil {
            initializeRequest()
        }
    }

    @IBAction func cancelButton(_ sender: UIButton) {
        let mainPage: OrderViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainOrderViewController") as! OrderViewController

        self.present(mainPage, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemSelectionTableViewCell", for: indexPath) as! ItemSelectionTableViewCell

        //Configure cell
        let item = items[indexPath.row]
        cell.nameLabel.text = item.name

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = items[indexPath.row]
        currentRequest!.item = selectedItem.name

        let nextPage: RequestConfirmationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RequestConfirmationViewController") as! RequestConfirmationViewController
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
        Item.getAll(forLocation: currentRequest!.pickupLocation, completionHandler: { items in
            self.items = items
            DispatchQueue.main.async {
                self.menuItemTable.reloadData()
            }
        })
    }
}
