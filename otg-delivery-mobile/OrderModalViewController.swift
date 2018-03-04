//
//  OrderModalViewController.swift
//  otg-delivery-mobile
//
//  Created by Sam Naser on 3/2/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import UIKit

class OrderModalViewController: UIViewController {

    @IBOutlet weak var orderText: UITextField?
    @IBOutlet weak var timeframeText: UITextField?

    @IBAction func submitPressed(sender: UIButton){
    
        let defaults = UserDefaults.standard
        let requesterName = defaults.object(forKey: "username")
        
        //grab relevant form data
        let orderDescription = orderText?.text
        let timeFrame = timeframeText?.text
        
        //create coffee request from data
        let requestFromForm: CoffeeRequest = CoffeeRequest(requester: requesterName as! String, orderDescription: orderDescription!, timeFrame: timeFrame, requestId: nil)
        CoffeeRequest.postCoffeeRequest(coffeeRequest: requestFromForm)
        
        //dismiss modal
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
