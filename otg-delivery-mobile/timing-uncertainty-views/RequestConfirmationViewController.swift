//
//  RequestConfirmationViewController.swift
//  otg-delivery-mobile
//
//  Created by Maggie Lou on 2/26/19.
//  Copyright © 2019 Sam Naser. All rights reserved.
//

import UIKit

class RequestConfirmationViewController: UIViewController {
    
    var currentRequest: CoffeeRequest?

    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var meetingPointsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentRequest == nil {
            let alert = UIAlertController(title: "We apologize. There is some error with your order.", message: "", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                let mainPage: OrderViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainOrderViewController") as! OrderViewController
                
                self.present(mainPage, animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        
        startTimeLabel.text = CoffeeRequest.parseTime(dateAsString: currentRequest!.orderStartTime)
        endTimeLabel.text = CoffeeRequest.parseTime(dateAsString: currentRequest!.orderEndTime)
        
        meetingPointsLabel.text = CoffeeRequest.prettyParseArray(arr: (currentRequest?.deliveryLocationOptions)!)
        

    }
    
    @IBAction func backButton(_ sender: Any) {
        let prevPage: RequestTimeframeViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RequestTimeframeViewController") as! RequestTimeframeViewController
        prevPage.currentRequest = currentRequest
        self.present(prevPage, animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        let mainPage: OrderViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainOrderViewController") as! OrderViewController
        
        self.present(mainPage, animated: true, completion: nil)
    }
    
    @IBAction func submitButton(_ sender: Any) {
        currentRequest = setTimeProbabilities(request: currentRequest!)
        CoffeeRequest.postCoffeeRequest(coffeeRequest: currentRequest!)
        
        let defaults = UserDefaults.standard
        var requestsPlaced = defaults.object(forKey: "requestsPlaced") as! Int + 1
        defaults.set(requestsPlaced, forKey: "requestsPlaced")
    }
    
    func setTimeProbabilities(request: CoffeeRequest) -> CoffeeRequest {
        let defaults = UserDefaults.standard
        let requestsPlaced = defaults.object(forKey: "requestsPlaced") as! Int
        
        if (requestsPlaced <= 1) {
            request.timeProbabilities[1] = "10%"
            request.timeProbabilities[3] = "30%"
        } else {
            request.timeProbabilities[1] = "30%"
            request.timeProbabilities[3] = "10%"
        }
        
        return request
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
