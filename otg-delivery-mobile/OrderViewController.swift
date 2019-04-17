//
//  OrderViewController.swift
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

    //On schedule delivery button pressed
    @IBAction func createNewOrder() {
        self.currentActionType = .Order
        self.performSegue(withIdentifier: "orderFormSegue", sender: self)

        //TODO: REIMPLEMENT THIS WHILE TESTING
        /*
        // Check time - only open 11AM - 5PM
        if (checkDeliveryAvailabilityTimeframe()) {
            self.currentActionType = .Order
            self.performSegue(withIdentifier: "orderFormSegue", sender: self)
        } else {
            let alert = UIAlertController(title: "You can only submit requests between 11AM - 5PM each day.", message: "", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            }))

            self.present(alert, animated: true, completion: nil)
        }
        */
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

        //testing send notification to user
        sendToSelf(message: "Hello, human. I am a simulator.")

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
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        //If user not logged in, transition to login page
        let userID = defaults.object(forKey: "userId")
        if userID == nil {
            performSegue(withIdentifier: "loginSegue", sender: nil)
        } else {
            print("User with ID ", userID as! String)
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

        guard let requesterId = defaults.object(forKey: "userId") as? String else {
            print("Helper ID not in defaults")
            return
        }

        let locUpdate = LocationUpdate(latitude: latitude, longitude: longitude, speed: speed, direction: direction, uncertainty: uncertainty, timestamp: timestamp, userId: requesterId)
        LocationUpdate.post(locUpdate: locUpdate)
    }

    func removeCachedGeofenceLocation() {
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
        return myRequests.count
    }

    // Configure and display cells in table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Render label data
        if tableView == myRequestTableView {
            let cell = RequestStatusTableViewCell()

            // Grab request to render
            let request = myRequests[indexPath.row]

            cell.statusDetailsLabel.text = request.status
            cell.itemDetailsLabel.text = request.item
            cell.contactHelperButton.tag = 0

            // Populate time probabilities
            let calendar = Calendar.current
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            formatter.timeZone = NSTimeZone.local

            let startTime = CoffeeRequest.stringToDate(s: request.orderStartTime)

            let timeframe1 = CoffeeRequest.dateToString(d: calendar.date(byAdding: .minute, value: 30, to: startTime)!)
            let timeframe2 = CoffeeRequest.dateToString(d: calendar.date(byAdding: .minute, value: 60, to: startTime)!)
            let timeframe3 = CoffeeRequest.dateToString(d: calendar.date(byAdding: .minute, value: 90, to: startTime)!)

            cell.timeFrame1Label.text = "\(CoffeeRequest.generateTimeframeString(startTime: request.orderStartTime, timeframeMins: 30))"
            cell.timeFrame2Label.text = "\(CoffeeRequest.generateTimeframeString(startTime: timeframe1, timeframeMins: 30))"
            cell.timeFrame3Label.text = "\(CoffeeRequest.generateTimeframeString(startTime: timeframe2, timeframeMins: 30))"
            cell.timeFrame4Label.text = "\(CoffeeRequest.generateTimeframeString(startTime: timeframe3, timeframeMins: 30))"

            cell.probability1Label.text = request.timeProbabilities[0]
            cell.probability2Label.text = request.timeProbabilities[1]
            cell.probability3Label.text = request.timeProbabilities[2]
            cell.probability4Label.text = request.timeProbabilities[3]

            if (request.status != "Searching for Helper") {
                // Delivery minute estimate
                let splitStatus = request.status.components(separatedBy: "(")
                cell.statusDetailsLabel.text = splitStatus[0]
                cell.expirationDetailsLabel.text = String(splitStatus[1].dropLast())

                // Meeting point label
                cell.deliveryLocationTitleLabel.text = "Meet Helper At:"
                cell.deliveryLocationDetailsLabel.text = request.deliveryLocation
            } else {
                cell.expirationDetailsLabel.text = CoffeeRequest.generateTimeframeString(startTime: request.orderStartTime, timeframeMins: 120)
                cell.deliveryLocationTitleLabel.text = "Potential Meeting Points:"
                cell.deliveryLocationDetailsLabel.text = CoffeeRequest.prettyParseArray(arr: request.deliveryLocationOptions)
            }

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
        //let phoneNumber = "7324563380"
        let messageVC = MFMessageComposeViewController()

        // Request has not been accepted
//        if (Int(phoneNumber) == 0 || !MFMessageComposeViewController.canSendText()) {
//            let alert = UIAlertController(title: "Your request has not been accepted yet.", message: "", preferredStyle: .alert)
//            let cancel = UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
//            })
//
//            alert.addAction(cancel)
//            present(alert, animated: true, completion: nil)
//        } else { // Request has been accepted, message helper
            messageVC.body = "";
            messageVC.recipients = [phoneNumber]
            messageVC.messageComposeDelegate = self

            self.present(messageVC, animated: false, completion: nil)
        //}
    }

     // Support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
         // Return false if you do not want the specified item to be editable.
         return true
     }

     // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
                    CoffeeRequest.deleteRequest(with_id: deleteID)
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

            let action = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                self.currentActionType = .Edit
                self.activeEditingRequest = self.myRequests[indexPath.row]
                self.performSegue(withIdentifier: "orderFormSegue", sender: self)
            })

            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

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

        //let apiUrl: String = "https://otg-delivery.herokuapp.com/feedback"
        let apiUrl: String = "http://localhost:8080/feedback"
        
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

    func checkDeliveryAvailabilityTimeframe() -> Bool {
        let now = NSDate()
        let nowDateValue = now as Date
        let todayAt11AM = Calendar.current.date(bySettingHour: 11, minute: 0, second: 0, of: nowDateValue)
        let todayAt5PM = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: nowDateValue)
        
        return nowDateValue >= todayAt11AM! && nowDateValue <= todayAt5PM!
    }

    func sendToSelf(message: String) {
        let apiUrl: String = "http://localhost:8080/users/sendToMe"

        let url = URL(string: apiUrl)
        let session: URLSession = URLSession.shared
        var requestURL = URLRequest(url: url!)

        requestURL.httpMethod = "POST"
        requestURL.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        requestURL.httpBody = "message=\(message)".data(using: .utf8)

        let task = session.dataTask(with: requestURL){ data, response, error in
            print("Feedback post: Data post successful.")
        }

        task.resume()
    }
}

