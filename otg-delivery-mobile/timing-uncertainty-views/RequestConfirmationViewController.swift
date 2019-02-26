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
    }
    
    @IBAction func backButton(_ sender: Any) {
        let prevPage: SpecialRequestsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SpecialRequestsViewController") as! SpecialRequestsViewController
        prevPage.currentRequest = currentRequest
        self.present(prevPage, animated: true, completion: nil)
    }
    @IBAction func cancelButton(_ sender: Any) {
        let mainPage: OrderViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainOrderViewController") as! OrderViewController
        
        self.present(mainPage, animated: true, completion: nil)
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
