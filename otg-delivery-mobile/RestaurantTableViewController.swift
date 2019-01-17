//
//  RestaurantTableViewController.swift
//  otg-delivery-mobile
//
//  Created by Maggie Lou on 1/13/19.
//  Copyright © 2019 Sam Naser. All rights reserved.
//

import UIKit

class RestaurantTableViewController: UITableViewController {
    
    var restaurants = [Location]()
    var restaurantSelection = ""

    @IBOutlet var restaurantTableView: UITableView!
    
    override func viewDidLoad() {
        loadData()
        super.viewDidLoad()
    }

    @IBAction func cancelButton(_ sender: Any) {
        let mainPage: OrderViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainOrderViewController") as! OrderViewController
        
        self.present(mainPage, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    @objc func loadData() {
        print("Load location data")
        Location.getAll(completionHandler: { locations in
            self.restaurants = locations
            self.restaurantTableView.reloadData()
        })
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurants.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantTableViewCell", for: indexPath) as! RestaurantTableViewCell

        let restaurant = restaurants[indexPath.row]
        cell.restaurantLabel.text = Location.camelCaseToWords(camelCaseString: restaurant.name)
       
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        restaurantSelection = restaurants[indexPath.row].name
        self.performSegue(withIdentifier: "itemSelectionSegue", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "itemSelectionSegue" {
            print(segue.destination)
            let controller = segue.destination as? DrinkPickerTableViewController
            controller?.restaurant = self.restaurantSelection
        }
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
