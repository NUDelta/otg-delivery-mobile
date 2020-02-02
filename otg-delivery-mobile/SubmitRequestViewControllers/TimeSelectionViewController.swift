//
//  TimeSelectionViewController.swift
//  otg-delivery-mobile
//
//  Created by Cooper Barth on 2/2/20.
//  Copyright © 2020 Cooper Barth. All rights reserved.
//

import UIKit

class TimeSelectionViewController: UIViewController {

    @IBOutlet weak var DatePicker: UIDatePicker!
    var currentRequest: CoffeeRequest?

    override func viewDidLoad() {
        super.viewDidLoad()

        if (currentRequest == nil) {
            backToMain(currentScreen: self)
            print("Yikes")
        }

        DatePicker.backgroundColor = .white
        DatePicker.clipsToBounds = true
        DatePicker.layer.cornerRadius = 5.0
        DatePicker.locale = NSLocale(localeIdentifier: "en_US") as Locale

        setMaximumTime()
    }

    @IBAction func Confirm(_ sender: UIButton) {
        let nextPage: PotentialLocationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PotentialLocation") as! PotentialLocationViewController
        nextPage.currentRequest = currentRequest
        nextPage.endDate = DatePicker.date
        self.present(nextPage, animated: true, completion: nil)
    }

    // sets time selection to have a minimum/maximum time
    func setMaximumTime() {
        if currentRequest == nil {return}
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let currentDateString = LocationUpdate.dateToString(d: DatePicker.date)
        let maxDate = currentDateString.components(separatedBy: " ")[0] + " 19:00"
        let maxDateTime = formatter.date(from: maxDate)
        DatePicker.maximumDate = maxDateTime
        DatePicker.minimumDate = Date()
    }

}
