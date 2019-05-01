//
//  ActiveRequestViewControllers.swift
//  otg-delivery-mobile
//
//  Created by Cooper Barth on 5/1/19.
//  Copyright © 2019 Sam Naser. All rights reserved.
//

import UIKit

class InitialHelperViewController: UIViewController {
    @IBOutlet weak var PriceTextField: UITextField!
    var coffeeRequest: CoffeeRequest?

    @IBAction func PickedUpOrder(_ sender: Any) {
        if (PriceTextField != nil && PriceTextField.text! == "") {return}
        CoffeeRequest.updatePrice(requestId: defaults.string(forKey: "ActiveRequestId")!, price: PriceTextField.text!)
    }

    @IBAction func ContactRequester(_ sender: Any) {
    }

    @IBAction func CancelAcceptance(_ sender: Any) {
    }
}
