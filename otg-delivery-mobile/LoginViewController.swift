//
//  LoginViewController.swift
//  otg-delivery-mobile
//
//  Created by Sam Naser on 3/2/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    var didLogIn: (() -> Void)?
    
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
    
    @IBAction func createLogIn() {
        //Save session username as user default
        //TODO in future check for this default before loading view
        //and if found, navigate straight to main view
        guard let usernameText: String = usernameField?.text else {
            print("LOGIN VIEW: username text could not be retrieved.")
            return
        }
        
        var tokenValue: String = "Default token value"
        
        //If we're on a real device, this token id should be set
        var defaults = UserDefaults.standard
        if let tokenId = defaults.object(forKey: "tokenId") as? String {
            tokenValue = tokenId
        }
        
        defaults.set(usernameText, forKey: "username")
        
        let user = UserModel(userId: nil, deviceId: tokenValue, username: usernameText)
        UserModel.createUser(user: user)
        
        print("LOGIN: transitioning to main view")
        didLogIn?()
    }

}
