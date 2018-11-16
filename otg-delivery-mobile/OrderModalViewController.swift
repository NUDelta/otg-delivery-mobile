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
    @IBOutlet weak var deliveryDetailsForm: UITextView!
    
    //ACTION TYPE
    var actionType: OrderActionType?
    var activeEditingRequest: CoffeeRequest?
    
    var selectedPlace: String?
    var dueDate: Int?
    var orderChoice: Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup keyboard view translations
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        self.deliveryDetailsForm.layer.borderWidth = 0.5
        self.deliveryDetailsForm.layer.cornerRadius = 8.0
        self.deliveryDetailsForm.layer.borderColor = UIColor.lightGray.cgColor
        
        self.deliveryDetailsForm.delegate = self
        
        guard let actionType = self.actionType else { return }
        
        switch(actionType) {
            case .Edit:
                
                guard let editingRequest = activeEditingRequest else { return }
                orderChoice = editingRequest.item
                
                self.navigationItem.title = "Edit order"
                self.itemOrderLabel.text = orderChoice?.name ?? "Item not loading"
                deliveryDetailsForm.text = editingRequest.deliveryLocationDetails
                itemPriceLabel.text = String.init(format: "$%.2f", orderChoice?.price ?? 0)
                
                let RFC3339DateFormatter = DateFormatter()
                RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
                RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
                RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                let date = RFC3339DateFormatter.date(from: editingRequest.endTime!)
                self.picker.setDate(date!, animated: true)
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
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Button press segue defined in story board
        if segue.identifier == "meetingPointSegue" {
            let defaults = UserDefaults.standard
            let requesterId = defaults.object(forKey: "userId")
            
            // Create request from form
            guard let currentRequestItem = orderChoice else {
                print("No item currently selected from drink picker modal")
                return
            }
            let itemId = currentRequestItem.id
            let requestEndTime = picker!.date
            let deliveryDetails = deliveryDetailsForm.text ?? ""
            
            let RFC3339DateFormatter = DateFormatter()
            RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
            RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            
            let responseDate = RFC3339DateFormatter.string(from: requestEndTime)
            
            //Create coffee request from data
            let requestFromForm: CoffeeRequest = CoffeeRequest(requester: requesterId as! String, itemId: itemId, status: "Pending", deliveryLocation: [""], deliveryLocationDetails: deliveryDetails, endTime: responseDate)
            
            // Go to meeting point selection screen
            let navController = segue.destination as? MeetingPointTableViewController
            // Pass current request to next screen
            navController?.currentRequest = requestFromForm
        }
    }
   
    @IBAction func selectDeliveryButton(_ sender: Any) {
        
        if (orderChoice == nil) {
            let alert = UIAlertController(title: "What would you like to order?", message: "Please select an item before choosing your delivery location.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            }))
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        performSegue(withIdentifier: "meetingPointSegue", sender: nil)
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
    // Returned from Drink Picker Controller, when user selects an item to order
    func itemPicked(itemChoice: Item) {
        orderChoice = itemChoice
        itemOrderLabel.text = ("\(itemChoice.name)")
        itemPriceLabel.text = itemChoice.getPriceString()
    }
    
    //-=-=-=-=-=-=-=-=-=-=-
    //Return on text field
    //-=-=-=-=-=-=-=-=-=-=-
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
