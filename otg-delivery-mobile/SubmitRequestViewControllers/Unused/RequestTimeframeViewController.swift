//
//  RequestTimeframeViewController.swift
//  otg-delivery-mobile
//
//  Created by Maggie Lou on 2/26/19.
//  Copyright © 2019 Sam Naser. All rights reserved.
//

import UIKit

class RequestTimeframeViewController: UIViewController {
    
    var currentRequest: CoffeeRequest?

    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getTimeFromTimePicker()
        
        if currentRequest == nil {
            let alert = UIAlertController(title: "We apologize. There is some error with your order.", message: "", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                let mainPage: OrderViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainOrderViewController") as! OrderViewController
                
                self.present(mainPage, animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func cancelButton(_ sender: Any) {
        let mainPage: OrderViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainOrderViewController") as! OrderViewController
        
        self.present(mainPage, animated: true, completion: nil)
    }

    @IBAction func backButton(_ sender: Any) {
        let prevPage: ItemSelectionViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ItemSelectionTableViewController") as! ItemSelectionViewController
        prevPage.currentRequest = currentRequest
        self.present(prevPage, animated: true, completion: nil)
    }

    @IBAction func nextPageButton(_ sender: Any) {
        setTimeOnRequestObject()
        
        let nextPage: MeetingPointTableViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MeetingPointTableViewController") as! MeetingPointTableViewController
        nextPage.currentRequest = currentRequest
        self.present(nextPage, animated: true, completion: nil)
        
    }

    @IBAction func timeChanged(_ sender: UIDatePicker) {
        getTimeFromTimePicker()
    }

    func getTimeFromTimePicker() {
        timePicker.datePickerMode = UIDatePicker.Mode.time
        let timeSelected = timePicker.date

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.timeZone = NSTimeZone.local
        let startTime = formatter.string(from: timeSelected)

        let calendar = Calendar.current
        let endTimeDate = calendar.date(byAdding: .hour, value: 2, to: timeSelected)
        let endTime = formatter.string(from: endTimeDate!)
        
        
        startTimeLabel.text = startTime
        endTimeLabel.text = endTime
    }
    
    func setTimeOnRequestObject() {
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let requestStartTime = RFC3339DateFormatter.string(from: timePicker.date)
        
        let calendar = Calendar.current
        let requestEndTimeDate = calendar.date(byAdding: .hour, value: 2, to: timePicker.date)
        let requestEndTime = RFC3339DateFormatter.string(from: requestEndTimeDate!)
        
        currentRequest?.orderStartTime = requestStartTime
        currentRequest?.orderEndTime = requestEndTime
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
