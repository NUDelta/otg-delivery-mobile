//
//  ViewController.swift
//  another_example
//
//  Created by Sam Naser on 1/19/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation
import MessageUI

class OrderViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate {
    
    var myRequests = [CoffeeRequest]()
    
    @IBOutlet weak var myRequestTableView: UITableView!
    
    var currentActionType: OrderActionType?
    var activeEditingRequest: CoffeeRequest?
    
    //On plus sign pressed
    @IBAction func createNewOrder() {
        self.currentActionType = .Order
        self.performSegue(withIdentifier: "orderFormSegue", sender: self)
    }
    
    public static let sharedManager = OrderViewController()

    var locationManager: CLLocationManager?
    let pickupLocations: [(locationName: String, location: CLLocationCoordinate2D)] = [
//        ("Norbucks", CLLocationCoordinate2D(latitude: 42.053343, longitude: -87.672956)),
//        ("Sherbucks", CLLocationCoordinate2D(latitude: 42.04971, longitude: -87.682014)),
//        ("Kresge Starbucks", CLLocationCoordinate2D(latitude: 42.051725, longitude: -87.675103)),
//        ("Fran's", CLLocationCoordinate2D(latitude: 42.051717, longitude: -87.681063)),
//        ("Coffee Lab", CLLocationCoordinate2D(latitude: 42.058518, longitude: -87.683645)),
//        ("Kaffein", CLLocationCoordinate2D(latitude: 42.046968, longitude: -87.679088)),
        ("Noyes", CLLocationCoordinate2D(latitude: 42.058345, longitude: -87.683724)),
        ("Tech Express", CLLocationCoordinate2D(latitude: 42.057816, longitude: -87.677123)), // On Sheridan
        ("Tech Express", CLLocationCoordinate2D(latitude: 42.057958, longitude: -87.674735)), // By Mudd
        ("Downtown Evanston", CLLocationCoordinate2D(latitude: 42.048555, longitude: -87.681854)),
    ]
    
    let meetingPointLocations: [(locationName: String, location: CLLocationCoordinate2D)] = [
        ("Tech Lobby", CLLocationCoordinate2D(latitude: 42.057816, longitude: -87.677123)), // On Sheridan
        ("Tech Lobby", CLLocationCoordinate2D(latitude: 42.057958, longitude: -87.674735)), // By Mudd
        ("Bridge between Tech and Mudd", CLLocationCoordinate2D(latitude: 42.057958, longitude: -87.674735)),
        ("Main Library Sign-In Desk", CLLocationCoordinate2D(latitude: 42.053166, longitude: -87.674774)),
        ("Kresge, By Entrance", CLLocationCoordinate2D(latitude: 42.051352, longitude: -87.675254)),
        ("SPAC, By Entrance", CLLocationCoordinate2D(latitude: 42.059135, longitude: -87.672755)),
        ("Norris, By Front Entrance", CLLocationCoordinate2D(latitude: 42.053328,  longitude: -87.673141)),
        ("Plex Lobby", CLLocationCoordinate2D(latitude: 42.053822, longitude: -87.678237)),
        ("Willard Lobby", CLLocationCoordinate2D(latitude: 42.051655,
        longitude:  -87.681316)),
        ]
        

    override func viewDidLoad() {
        super.viewDidLoad()
        // initialize location manager
        locationManager = CLLocationManager()
        
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.delegate = self
        // Accuracy of location data
        locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        // The minimum distance before an update event is generated
        locationManager?.distanceFilter = 50.0
        
        // Enable location tracking when app sleeps
        locationManager!.pausesLocationUpdatesAutomatically = false
        locationManager!.startMonitoringSignificantLocationChanges()
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager?.requestAlwaysAuthorization()
            locationManager?.requestWhenInUseAuthorization()
        }
        
        locationManager?.startUpdatingLocation()
        // use our predefined locations to setup the geo-fences
        for coffeeLocation in (pickupLocations + meetingPointLocations) {
            let region = CLCircularRegion(center: coffeeLocation.1, radius: 200, identifier: coffeeLocation.0)
            region.notifyOnEntry = true
            region.notifyOnExit = true
        
            locationManager?.startMonitoring(for: region)
        }
        
        // Initialize My Requests table
        myRequestTableView.register(RequestStatusTableViewCell.self, forCellReuseIdentifier: RequestStatusTableViewCell.reuseIdentifier)
        self.myRequestTableView.delegate = self
        self.myRequestTableView.dataSource = self
        
        loadData()
        
        // Initialize listener for whenever app becoming active
        // To reload request data and update table
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("SHOULD BE PRINTING USER ID")
        print(UserDefaults.standard.object(forKey: "userId") as Any)
        //If user not logged in, transition to login page
        if UserDefaults.standard.object(forKey: "userId") == nil {
            performSegue(withIdentifier: "loginSegue", sender: nil)
        }
        
        loadData()
    }
    

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locToSave = locations.last!
        
        let latitude = Double(locToSave.coordinate.latitude)
        let longitude = Double(locToSave.coordinate.longitude)
        let speed = Double(locToSave.speed)
        let direction = Double(locToSave.course)
        let uncertainty = Double(locToSave.horizontalAccuracy)
        let timestamp = Date()
        
        let defaults = UserDefaults.standard
        guard let requesterId = defaults.object(forKey: "userId") as? String else {
            print("Helper ID not in defaults")
            return
        }
        
        let locUpdate = LocationUpdate(latitude: latitude, longitude: longitude, speed: speed, direction: direction, uncertainty: uncertainty, timestamp: timestamp, userId: requesterId)
        LocationUpdate.post(locUpdate: locUpdate)
    }
    
    func removeCachedGeofenceLocation() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey:"currentGeofenceLocation")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginSegue" {
            let navController = segue.destination as? UINavigationController
            let controller = navController?.viewControllers.first as? LoginViewController
        
            controller?.didLogIn = { [weak self] in
                DispatchQueue.main.async {
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func loadData() {
        User.getMyRequests(completionHandler: { coffeeRequests in
            DispatchQueue.main.async {
                self.myRequests = coffeeRequests
                self.myRequestTableView.reloadData()
            }
        })
    }

    // MARK: Table View Configuration
    
    //Return number of sections in table view
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Return number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
//        var rowCount = 0
//
//        if(tableView == myRequestTableView){
//            rowCount = self.myRequests.count
//        }
//
//        return rowCount
    }
    
    // Configure and display cells in table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Render label data
        if tableView == myRequestTableView {
            let cell = RequestStatusTableViewCell()
            
            // Grab request to render
            
            //TODO: Revert
            //let request = myRequests[indexPath.row]
            let request = CoffeeRequest(requester: "M", itemId: "M", status: "M", deliveryLocation: ["M"], deliveryLocationDetails: "M", endTime: "M", pickupLocation: "M")

            if (request.status != "Pending") {
                // Meeting point label
                cell.deliveryLocationTitleLabel.text = "Meet Helper At:"
                
                // Estimated delivery label
                cell.expirationTitleLabel.text = "Estimated Delivery Time:"
                let splitStatus = request.status.components(separatedBy: "(")
                cell.statusDetailsLabel.text = splitStatus[0]
                
                //TODO: Revert
                //cell.expirationDetailsLabel.text = String(splitStatus[1].dropLast())
                
                cell.timeFrame1Label.text = "timeFrame1Label"
                cell.timeFrame2Label.text = "timeFrame2Label"
                cell.timeFrame3Label.text = "timeFrame3Label"
                //cell.timeFrame4Label.text = "timeFrame4Label"
                
                // Contact helper button
                User.get(with_id: request.helper!, completionHandler: { helperUserModel in
                    guard let helperUserModel = helperUserModel else {
                        print("No helper returned when trying to get helper name for a request.")
                        return
                    }
                    let phoneNumber = helperUserModel.phoneNumber
                    
                    DispatchQueue.main.async {
                        // So phone number can be accessed when pressing button
                        cell.contactHelperButton.tag = Int(phoneNumber) ?? 0
                    }
                })
            } else {
                cell.deliveryLocationTitleLabel.text = "Potential Meeting Points:"
                
                cell.expirationTitleLabel.text = "Expiration:"
                let endTime = CoffeeRequest.parseTime(dateAsString: request.endTime!)
                cell.expirationDetailsLabel.text = endTime
                
                cell.statusDetailsLabel.text = request.status
            }

            cell.deliveryLocationDetailsLabel.text = CoffeeRequest.prettyParseArray(arr: request.deliveryLocation)

            // Text wraps
            cell.statusDetailsLabel.numberOfLines = 0
            cell.expirationDetailsLabel.numberOfLines = 0
            cell.deliveryLocationDetailsLabel.numberOfLines = 0

            // Contact helper button
            cell.contentView.isUserInteractionEnabled = true;
            cell.contactHelperButton.tag = indexPath.row
            cell.contactHelperButton.addTarget(self, action: #selector(contactUser),
                                                  for: .touchUpInside)
            return cell

        }
        
        return UITableViewCell()
    }
    
    @objc func contactUser(sender: UIButton) {
        print("In contact requester")
        let phoneNumber = String(sender.tag)
        let messageVC = MFMessageComposeViewController()

        // Request has not been accepted
        if (Int(phoneNumber) == 0 || !MFMessageComposeViewController.canSendText()) {
            let alert = UIAlertController(title: "Your request has not been accepted yet.", message: "", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
            })
            
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        } else { // Request has been accepted, message helper
            messageVC.body = "";
            messageVC.recipients = [phoneNumber]
            messageVC.messageComposeDelegate = self
            
            self.present(messageVC, animated: false, completion: nil)
        }
    }

     // Support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
         // Return false if you do not want the specified item to be editable.
         return true
     }
    

     // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
            
            if tableView == myRequestTableView {
                // Launch request editor on click
                let deleteConfirmation = UIAlertController(title: "Are you sure you would like to delete this request?", message: "", preferredStyle: .alert)
                
                let confirmAction = UIAlertAction(title: "Confirm", style: .destructive, handler: {(action: UIAlertAction!) in
                    // Delete the row from the table view
                    let deletedRequest = self.myRequests.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    // Delete request from database
                    let deleteID = deletedRequest.requestId
                    CoffeeRequest.deleteRequest(with_id: deleteID!)
                    self.myRequestTableView.reloadData()
                } )
                
                // Do nothing on 'Cancel'
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                // Add actions to editor
                deleteConfirmation.addAction(cancelAction)
                deleteConfirmation.addAction(confirmAction)
                
                present(deleteConfirmation, animated: true, completion: nil)
            }
         }
     }


    // Support editing of rows in the table view when you click on a row
    // Updates corresponding request in database
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == myRequestTableView {
            
            // Launch request editor on click
            let editAlert = UIAlertController(title: "Would you like to edit your request?", message: "You will have to reselect all fields of request", preferredStyle: .alert)

            
            let action = UIAlertAction(title: "OK", style: .default, handler: { [weak editAlert] (_) in
                self.currentActionType = .Edit
                self.activeEditingRequest = self.myRequests[indexPath.row]
                self.performSegue(withIdentifier: "orderFormSegue", sender: self)
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                
            })
            
            editAlert.addAction(action)
            editAlert.addAction(cancel)
            present(editAlert, animated: true, completion: nil)
            
        }
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    
    func sendFeedback(feedbackText: String?){
        
        //In case the input doesn't exist
        guard let feedbackText = feedbackText else {
            print("FEEDBACK: Nil found as feedback value, exiting gracefully.")
            return
        }
        
         let apiUrl: String = "https://otg-delivery.herokuapp.com/feedback"
        //let apiUrl: String = "http://localhost:8080/feedback"
        
        let url = URL(string: apiUrl)
        let session: URLSession = URLSession.shared
        var requestURL = URLRequest(url: url!)
        
        requestURL.httpMethod = "POST"
        requestURL.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        requestURL.httpBody = "feedbackText=\(feedbackText)".data(using: .utf8)
        
        let task = session.dataTask(with: requestURL){ data, response, error in
            print("Feedback post: Data post successful.")
        }
        
        task.resume()
        
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        print("in message compose view controller")
        switch (result.rawValue) {
        case MessageComposeResult.cancelled.rawValue:
            //            print("Message was cancelled")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed.rawValue:
            //            print("Message failed")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent.rawValue:
            //            print("Message was sent")
            self.dismiss(animated: true, completion: nil)
        default:
            break;
        }
    }
}

