//
//  DrinkPickerTableViewController.swift
//  otg-delivery-mobile
//
//  Created by Sam Naser on 4/4/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import UIKit


class DrinkPickerTableViewController: UITableViewController {
    
    //Returned to parent
    var chosenDrinkOrder: String?
    
    //Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drinkData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "drinkCell", for: indexPath) as! DrinkPickerTableViewCell
        
        //Configure cell
        cell.drinkLabel?.text = drinkData[indexPath.row].name
        cell.priceLabel?.text = drinkData[indexPath.row].priceRangeString()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDrink = drinkData[indexPath.row]
        drinkOrderNotification(forDrink: selectedDrink)
    }
    
    
    //Create and show custom notification given chosen drink
    func drinkOrderNotification(forDrink drink: Drink) {
        let alert = UIAlertController(title: "Finalize order", message: "Choose drink size", preferredStyle: .alert)
        
        for price in drink.prices {
            let currentTitle = String.init(format: "%@: $%.2f", price.0.asString(), price.1)
            
            alert.addAction(UIAlertAction(title: currentTitle, style: .default, handler: { _ in
                self.chosenDrinkOrder = currentTitle
            }))
            
        }
        
        self.present(alert, animated: true, completion: nil)
    }

}
