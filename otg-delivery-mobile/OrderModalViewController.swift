//
//  OrderModalViewController.swift
//  otg-delivery-mobile
//
//  Created by Sam Naser on 3/2/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import UIKit

class OrderModalViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, DrinkPickerModalDelegate {
    
    @IBOutlet weak var picker: UIDatePicker!
    @IBOutlet weak var itemOrderLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    
    var selectedPlace: String?
    var dueDate: Int?
    var coffeeOrder: String?

    
    //When date picker value changes
    @IBAction func valueChanged(_ sender: UIDatePicker) {
        print(sender.date.timeIntervalSince1970)
        dueDate = Int(sender.date.timeIntervalSince1970)
    }
    
    //When the submissions is entered
    @IBAction func submitPressed(sender: UIButton){
    
        let defaults = UserDefaults.standard
        let requesterName = defaults.object(forKey: "username")
        
        //Grab relevant form data
        let orderDescription = itemOrderLabel.text
        let requestEndTime = picker!.date
        
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let responseDate = RFC3339DateFormatter.string(from: requestEndTime)
                
        //Create coffee request from data
        let requestFromForm: CoffeeRequest = CoffeeRequest(requester: requesterName as! String, orderDescription: orderDescription!, endTime: responseDate, requestId: nil)
        CoffeeRequest.postCoffeeRequest(coffeeRequest: requestFromForm)
        
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
        itemOrderLabel.text = String.init(format: "%@", itemChoice.price, itemChoice.name)
        itemPriceLabel.text = itemChoice.getPriceString()
    }
    
    //-=-=-=-=-=-=-=-=-=-=-
    //Return on text field
    //-=-=-=-=-=-=-=-=-=-=-
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //Do any additional setup after loading the view.
    }

}
