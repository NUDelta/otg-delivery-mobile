//
//  RequestConfirmationViewController.swift
//  otg-delivery-mobile
//
//  Created by Cooper Barth on 4/28/19.
//  Copyright © 2019 Sam Naser. All rights reserved.
//

import UIKit

class AcceptConfirmationViewController: UIViewController {
    @IBOutlet weak var ItemLabel: UILabel!
    @IBOutlet weak var PickupLabel: UILabel!
    @IBOutlet weak var RequesterLabel: UILabel!

    var request: CoffeeRequest? = nil

    override func viewDidLoad() {
        ItemLabel.text = request?.item
        PickupLabel.text = request?.pickupLocation
        RequesterLabel.text = request?.requester?.username
    }

    @IBAction func AcceptOrder(_ sender: Any) {
        
    }

    @IBAction func DeclineOutOfWay(_ sender: Any) {
        
    }

    @IBAction func DeclineNotEnoughTime(_ sender: Any) {
        
    }

    @IBAction func DeclineOther(_ sender: Any) {
        
    }

    @IBAction func Cancel(_ sender: Any) {
        let mainPage: OrderViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainOrderViewController") as! OrderViewController
        self.present(mainPage, animated: true, completion: nil)
    }
}
