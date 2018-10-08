//
//  DrinkPickerTableViewController.swift
//  otg-delivery-mobile
//
//  Created by Sam Naser on 4/4/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import UIKit

protocol DrinkPickerModalDelegate {
    func itemPicked(itemChoice: Item)
}

class DrinkPickerTableViewController: UITableViewController {
    
    @IBOutlet var menuItemTable: UITableView!
    
    var items = [Item]()
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Returned to parent
    var delegate: DrinkPickerModalDelegate?
    var selectedDrink: Item?
    
    //Overrides
    override func viewDidLoad() {
        loadData()
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    // Configure cells in table view
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "drinkCell", for: indexPath) as! DrinkPickerTableViewCell
        
        //Configure cell
        let item = items[indexPath.row]
        print(item)
        cell.itemNameLabel?.text = item.name
        cell.descriptionLabel?.text = item.description
        cell.priceLabel?.text = item.getPriceString()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedDrink = items[indexPath.row]
        itemOrderNotification(forItem: selectedDrink!)
    }
    
    
    //Create and show custom notification given chosen drink
    func itemOrderNotification(forItem item: Item) {
        let alert = UIAlertController(title: "Confirm order", message: String.init(format: "Order for %@", item.name), preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            self.delegate?.itemPicked(itemChoice: item)
            self.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            //do nothing
        }))
        
        self.present(alert, animated: true, completion: nil)
    }

    @objc func loadData() {
        print("Load item data")
        Item.getAll(forLocation: "Tomate", completionHandler: { items in
            print(items)
            self.items = items
            self.menuItemTable.reloadData()
        })
    }
}
