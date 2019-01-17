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
    var restaurant: String?
    
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        let restaurantSelectionModal: RestaurantTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RestaurantTableViewController") as! RestaurantTableViewController
        
        self.present(restaurantSelectionModal, animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        openMainView()
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
        
        let orderPage: OrderModalViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OrderModalViewController") as! OrderModalViewController
        orderPage.itemPicked(itemChoice: selectedDrink!)
        self.present(orderPage, animated: true, completion: nil)
    }

    func loadData() {
        print("Load item data")
        if restaurant != nil {
            Item.getAll(forLocation: restaurant!, completionHandler: { items in
                print(items)
                self.items = items
                self.menuItemTable.reloadData()
            })
        }
    }
    
    func openMainView() {
        let mainPage: OrderViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainOrderViewController") as! OrderViewController
        
        self.present(mainPage, animated: true, completion: nil)
    }
}
