//
//  InitialRequesterViewControllwe.swift
//  otg-delivery-mobile
//
//  Created by Cooper Barth on 5/1/19.
//  Copyright © 2019 Sam Naser. All rights reserved.
//

import UIKit
import MessageUI

class InitialRequesterViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    let requestId = defaults.string(forKey: "ActiveRequestId")!
    var request: CoffeeRequest?

    override func viewDidLoad() {
        super.viewDidLoad()
        CoffeeRequest.getRequest(with_id: requestId, completionHandler: {coffeeRequest in
            DispatchQueue.main.async {
                self.request = coffeeRequest
                if (self.request?.requester?.deviceId == self.request?.helper?.deviceId) {
                    self.backToMain()
                }
            }
        })
        //transition if picked up
    }

    @IBAction func ContactHelper(_ sender: Any) {
        let phoneNumber = request!.helper!.phoneNumber
        let messageVC = MFMessageComposeViewController()
        messageVC.body = ""
        messageVC.recipients = [phoneNumber]
        messageVC.messageComposeDelegate = self
        self.present(messageVC, animated: false, completion: nil)
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResult.cancelled.rawValue:
            //            print("Message was cancelled")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed.rawValue:
            //            print("Message failed")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent.rawValue:
            //            print("Message was sent")
            self.dismiss(animated: true, completion: nil)
        default:
            break;
        }
    }

    func backToMain() {
        let mainPage: OrderViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainOrderViewController") as! OrderViewController
        self.present(mainPage, animated: true, completion: nil)
        defaults.set("", forKey: "ActiveRequestId")
    }
}
