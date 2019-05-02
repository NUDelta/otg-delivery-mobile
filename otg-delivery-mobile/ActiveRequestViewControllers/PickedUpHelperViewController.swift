//
//  PickedUpHelperViewController.swift
//  otg-delivery-mobile
//
//  Created by Cooper Barth on 5/2/19.
//  Copyright © 2019 Sam Naser. All rights reserved.
//

import UIKit

class PickedUpHelperViewController: UIViewController {
    @IBOutlet weak var RequesterLabel: UILabel!

    let requestId = defaults.string(forKey: "ActiveRequestId")!
    var request: CoffeeRequest?

    override func viewDidLoad() {
        super.viewDidLoad()
        CoffeeRequest.getRequest(with_id: requestId, completionHandler: {coffeeRequest in
            DispatchQueue.main.async {
                self.request = coffeeRequest
                self.RequesterLabel.text = "Meet \(self.request?.requester?.username ?? "requester") at the meeting point."
            }
        })
    }

    @IBAction func ConfirmDelivery(_ sender: Any) {
        CoffeeRequest.deleteRequest(with_id: requestId)
        defaults.set("", forKey: "ActiveRequestId")
        backToMain(currentScreen: self)
    }
}
