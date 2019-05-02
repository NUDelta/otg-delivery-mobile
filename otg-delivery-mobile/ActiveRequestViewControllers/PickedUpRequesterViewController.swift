//
//  PickedUpRequesterViewController.swift
//  otg-delivery-mobile
//
//  Created by Cooper Barth on 5/2/19.
//  Copyright © 2019 Sam Naser. All rights reserved.
//

import UIKit

class PickedUpRequesterViewController: UIViewController {
    @IBOutlet weak var HelperLabel: UILabel!
    @IBOutlet weak var PriceLabel: UILabel!

    let requestId = defaults.string(forKey: "ActiveRequestId")!
    var request: CoffeeRequest?

    override func viewDidLoad() {
        super.viewDidLoad()
        CoffeeRequest.getRequest(with_id: requestId, completionHandler: {coffeeRequest in
            DispatchQueue.main.async {
                self.request = coffeeRequest
                self.HelperLabel.text = "Meet \(self.request?.helper?.username ?? "helper") at Meeting Point."
                self.PriceLabel.text = "Total: $\(self.request?.price ?? "0.00")"
            }
        })
    }

    @IBAction func ConfirmDelivered(_ sender: Any) {
        CoffeeRequest.deleteRequest(with_id: requestId)
        defaults.set("", forKey: "ActiveRequestId")
        backToMain(currentScreen: self)
    }
}
