//
//  LoginViewController.swift
//  otg-delivery-mobile
//
//  Created by Sam Naser on 3/2/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.usernameField?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Return on text field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.usernameField?.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true);
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //save session username as user default
        //TODO in future check for this default before loading view
        //and if found, navigate straight to main view
        let defaults = UserDefaults.standard
        let usernameText: String? = usernameField?.text
        defaults.set(usernameText!, forKey: "username")
        
        print("LOGIN: transitioning to main view")
    }

}
