//
//  OrderModalViewController.swift
//  otg-delivery-mobile
//
//  Created by Sam Naser on 3/2/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import UIKit

protocol OrderPickerDelegate {
    func orderSubmitted(order: CoffeeRequest)
}

enum OrderActionType {
    case Order
    case Edit
}

class OrderModalViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, DrinkPickerModalDelegate {
    
    @IBOutlet weak var picker: UIDatePicker!
    @IBOutlet weak var itemOrderLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    @IBOutlet weak var deliveryLocationForm: UITextField!
    @IBOutlet weak var deliveryDetailsForm: UITextView!
    
    //ACTION TYPE
    var actionType: OrderActionType?
    var activeEditingRequest: CoffeeRequest?
    
    var selectedPlace: String?
    var dueDate: Int?
    var orderChoice: Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("BLYAT complexity up and for what")
        print(self.actionType)
        print(self.activeEditingRequest)

        
        //Setup keyboard view translations
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        self.deliveryDetailsForm.layer.borderWidth = 0.5
        self.deliveryDetailsForm.layer.cornerRadius = 8.0
        self.deliveryDetailsForm.layer.borderColor = UIColor.lightGray.cgColor
        
        self.deliveryDetailsForm.delegate = self
        self.deliveryLocationForm.delegate = self
        
        
        guard let actionType = self.actionType else { return }
        
        switch(actionType) {
            case .Edit:
                
                guard let editingRequest = activeEditingRequest else { return }
                
                self.navigationItem.title = "Edit order"
                itemOrderLabel.text = editingRequest.orderDescription
                deliveryLocationForm.text = editingRequest.deliveryLocation
                deliveryDetailsForm.text = editingRequest.deliveryLocationDetails
                
                let drinkMatch = drinkData.filter { $0.name == editingRequest.orderDescription }
                itemPriceLabel.text = String.init(format: "$%.2f", drinkMatch[0].price)
                
                let RFC3339DateFormatter = DateFormatter()
                RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
                RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
                RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                let date = RFC3339DateFormatter.date(from: editingRequest.endTime!)
                picker.setDate(date!, animated: true)
                
                break
            
            case .Order:
                self.navigationItem.title = "Place order"
                //Create an instance of the drink picker
                let drinkPickerModal: DrinkPickerTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DrinkPickerController") as! DrinkPickerTableViewController
                drinkPickerModal.delegate = self
                self.present(drinkPickerModal, animated: true, completion: nil)
                break
        }
    }
    
    //Respond to keyboard stuff
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y = 0
            }
        }
    }
    
    //When date picker value changes
    @IBAction func valueChanged(_ sender: UIDatePicker) {
        print(sender.date.timeIntervalSince1970)
        dueDate = Int(sender.date.timeIntervalSince1970)
    }
    
    //When the submissions is entered
    @IBAction func submitPressed(sender: UIButton){
    
        let defaults = UserDefaults.standard
        let requesterId = defaults.object(forKey: "userId")
        
        //Grab relevant form data
        let orderDescription = itemOrderLabel.text
        let requestEndTime = picker!.date
        let deliveryLocation = deliveryLocationForm.text!
        let deliveryDetails = deliveryDetailsForm.text ?? ""
        
        
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let responseDate = RFC3339DateFormatter.string(from: requestEndTime)
                
        //Create coffee request from data
        let requestFromForm: CoffeeRequest = CoffeeRequest(requester: requesterId as! String, orderDescription: orderDescription!, status: "Pending", deliveryLocation: deliveryLocation, deliveryLocationDetails: deliveryDetails, helper: nil, endTime: responseDate, requestId: nil)
        
        guard let actionType = self.actionType else { return }
        
        switch(actionType){
            case .Edit:
                print("SUBMITTING EDITING REQUEST FOR \(self.activeEditingRequest)")
                CoffeeRequest.updateRequest(with_id: self.activeEditingRequest!.requestId!, withRequest: requestFromForm, completionHandler: {})
                break
            case .Order:
                CoffeeRequest.postCoffeeRequest(coffeeRequest: requestFromForm)
                break
        }
            
        //Dismiss modal
        dismiss(animated: true, completion: nil)
        
        let submissionAlert = UIAlertView()
        submissionAlert.title = "Order placed!"
        submissionAlert.message = "You will receive a Slack message when the order is accepted."
        submissionAlert.addButton(withTitle: "Ok")
        submissionAlert.show()
    }
   
    //When the cancel button on the toolbar is pressed
    @IBAction func cancelPressed(sender: UIBarButtonItem){
        //Dismiss modal
        dismiss(animated: true, completion: nil)
    }
    
    //Present modal
    @IBAction func drinkSelectionButtonPressed(sender: UIButton){
        //Create an instance of the drink picker
        let drinkPickerModal: DrinkPickerTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DrinkPickerController") as! DrinkPickerTableViewController
        drinkPickerModal.delegate = self
        
        self.present(drinkPickerModal, animated: true, completion: nil)
    }
    
    //-=-=-=-=-=-=-=-=-=-=-
    //Handle item choice
    //-=-=-=-=-=-=-=-=-=-=-
    func itemPicked(itemChoice: Item) {
        orderChoice = itemChoice
        itemOrderLabel.text = ("\(itemChoice.name)")
        itemPriceLabel.text = itemChoice.getPriceString()
    }
    
    //-=-=-=-=-=-=-=-=-=-=-
    //Return on text field
    //-=-=-=-=-=-=-=-=-=-=-
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        self.view.endEditing(true)
//        return false
        textField.resignFirstResponder()
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }


}
