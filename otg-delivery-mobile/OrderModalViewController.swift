//
//  OrderModalViewController.swift
//  otg-delivery-mobile
//
//  Created by Sam Naser on 3/2/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import UIKit

class OrderModalViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate {
    
    @IBOutlet weak var picker: UIDatePicker!
    @IBOutlet weak var orderText: UITextField?
 
    var selectedPlace: String?
    var dueDate: Int?
    
    @IBAction func valueChanged(_ sender: UIDatePicker) {
        print(sender.date.timeIntervalSince1970)
        dueDate = Int(sender.date.timeIntervalSince1970)
    }
    
    
    @IBAction func submitPressed(sender: UIButton){
    
        let defaults = UserDefaults.standard
        let requesterName = defaults.object(forKey: "username")
        
        //Grab relevant form data
        let orderDescription = orderText?.text
        
        let requestEndTime = Int(picker!.date.timeIntervalSince1970)
        let currentTime = Int(Date().timeIntervalSince1970)
        let timeDifference = requestEndTime - currentTime;
        
        //Should grab the Date for the request expiration and store in database instead
        //It makes more sense to query over those values
        let requestMinutes = String(timeDifference / 60)
        
        //Create coffee request from data
        let requestFromForm: CoffeeRequest = CoffeeRequest(requester: requesterName as! String, orderDescription: orderDescription!, timeFrame: requestMinutes, requestId: nil)
        CoffeeRequest.postCoffeeRequest(coffeeRequest: requestFromForm)
        
        //Dismiss modal
        dismiss(animated: true, completion: nil)
        
        let submissionAlert = UIAlertView()
        submissionAlert.title = "Order placed!"
        submissionAlert.message = "You will receive a Slack message when the order is accepted."
        submissionAlert.addButton(withTitle: "Ok")
        submissionAlert.show()
    }
    
    @IBAction func cancelPressed(sender: UIButton){
        //Dismiss modal
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Do any additional setup after loading the view.
        self.orderText?.delegate = self
    }
    
    //Return on text field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }

}
