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
        User.accept(requestId: request!.requestId, userId: defaults.string(forKey: "userId")!)
        User.sendNotification(deviceId: request!.requester!.deviceId, message: "\(defaults.string(forKey: "username")!) has accepted your order. Prepare to meet your helper at the designated meeting location.")
        backToMain()
    }

    @IBAction func DeclineOutOfWay(_ sender: Any) {
        backToMain()
    }

    @IBAction func DeclineNotEnoughTime(_ sender: Any) {
        backToMain()
    }

    @IBAction func DeclineOther(_ sender: Any) {
        backToMain()
    }

    @IBAction func Cancel(_ sender: Any) {
        backToMain()
    }

    func backToMain() {
        let mainPage: OrderViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainOrderViewController") as! OrderViewController
        self.present(mainPage, animated: true, completion: nil)
    }
}
