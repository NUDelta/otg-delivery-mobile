//
//  ActiveRequestViewControllers.swift
//  otg-delivery-mobile
//
//  Created by Cooper Barth on 5/1/19.
//  Copyright © 2019 Sam Naser. All rights reserved.
//

import UIKit
import MessageUI

class AcceptedHelperViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    @IBOutlet weak var PriceTextField: UITextField!
    @IBOutlet weak var detailsLabel: UILabel!

    let requestId = defaults.string(forKey: "ActiveRequestId")!
    var request: CoffeeRequest?

    override func viewDidLoad() {
        CoffeeRequest.getRequest(with_id: requestId, completionHandler: {coffeeRequest in
            DispatchQueue.main.async {
                self.request = coffeeRequest
                self.detailsLabel.text = "Order: \(self.request?.item ?? "item") from \(self.request?.pickupLocation ?? "location")"
            }
        })
    }

    @IBAction func PickedUpOrder(_ sender: Any) {
        if (PriceTextField != nil && PriceTextField.text! == "") {return}
        CoffeeRequest.updatePrice(requestId: requestId, price: PriceTextField.text!)
        CoffeeRequest.updateStatus(requestId: requestId, status: "Picked Up")
        User.sendNotification(deviceId: (request?.requester?.deviceId)!, message: "Your order has been picked up. Meet \(request?.helper?.username ?? "your helper") at the meeting point.")
        performSegue(withIdentifier: "HelperPickedUp", sender: nil)
    }

    @IBAction func ContactRequester(_ sender: Any) {
        /*let phoneNumber = request!.requester!.phoneNumber
        let messageVC = MFMessageComposeViewController()
        messageVC.body = ""
        messageVC.recipients = [phoneNumber]
        messageVC.messageComposeDelegate = self
        self.present(messageVC, animated: false, completion: nil)*/
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
}
