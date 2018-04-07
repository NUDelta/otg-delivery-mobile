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
    @IBOutlet weak var pickDrinkButton: UIButton!
    @IBOutlet weak var drinkOrderLabel: UILabel!
    @IBOutlet weak var drinkPriceLabel: UILabel!
    @IBOutlet weak var orderText: UITextField?
    
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
        let orderDescription = drinkOrderLabel.text
        
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
    //Handle drink choice
    //-=-=-=-=-=-=-=-=-=-=-
    func drinkPicked(drinkChoice: Drink, sizeIndex: Int) {
        let priceString = String.init(format: "$%@", drinkChoice.prices)
        
        drinkOrderLabel.text = String.init(format: "[%@] %@", drinkChoice.prices[sizeIndex].0.asString(), drinkChoice.name)
        drinkPriceLabel.text = String.init(format: "$%.2f", drinkChoice.prices[sizeIndex].1)
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
        self.orderText?.delegate = self
    }

}
