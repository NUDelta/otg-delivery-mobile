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
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var LoginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameField?.delegate = self
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
        guard let usernameText: String = usernameField?.text else {
            print("LOGIN VIEW: username text could not be retrieved.")
            return
        }

        guard let phoneNumber: String = phoneNumberField?.text else {
            print("LOGIN: phone number text could not be retrieved.")
            return
        }

        if (usernameText == "" || phoneNumber == "") {
            let emptyFields = UIAlertController(title: "Empty Field(s)", message: "Please enter both a username and a phone number.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            emptyFields.addAction(cancelAction)
            present(emptyFields, animated: true, completion: nil)
            return
        }

        LoginButton.isEnabled = false //prevent double clicking
        var tokenValue: String = "Default token value"

        //If we're on a real device, this token id should be set
        if let tokenId = defaults.object(forKey: "tokenId") as? String {
            tokenValue = tokenId
        }

        let user = User(userId: nil, deviceId: tokenValue, username: usernameText, phoneNumber: phoneNumber, currentLocation: nil)
        User.create(user: user, completionHandler: { userModel in
            guard let createdUser = userModel else {
                print("LOGIN: user was not fetched from server.")
                return
            }

            guard let userId = createdUser.userId else {
                print("LOGIN: could not retrieve userId from server response.")
                return
            }

            defaults.set(userId, forKey: "userId")
            defaults.set(usernameText, forKey: "username")
            defaults.set(0, forKey: "requestsPlaced")

            print("LOGIN: transitioning to main view")
            //Async so should wrap in this block
            DispatchQueue.main.async {
                self.didLogIn?()
            }
        })
    }
}
