//
//  HelperLocationFormViewController.swift
//  otg-delivery-mobile
//
//  Created by Maggie Lou on 11/16/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import UIKit

class HelperLocationFormViewController: UIViewController {

    @IBOutlet weak var locationForm: UITextField!
    @IBAction func continueButton(_ sender: Any) {
        Logging.sendEvent(location: locationForm.text ?? "No location submitted", eventType: Logging.eventTypes.helperIntendedLocation.rawValue, details: "")
        self.performSegue(withIdentifier: "meetingPointSegue", sender: self)
        
    }
    @IBAction func cancelButton(_ sender: Any) {
        let mainView: UINavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainNavController") as! UINavigationController
        self.present(mainView, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
