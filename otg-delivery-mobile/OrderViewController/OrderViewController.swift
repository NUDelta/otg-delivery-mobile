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

    public static let sharedManager = OrderViewController()
    @IBOutlet weak var myRequestTableView: RequesterTableView!
    @IBOutlet weak var helperTableView: HelperTableView!

    var myRequests = [CoffeeRequest]()
    var openRequests = [CoffeeRequest]()

    var currentActionType: OrderActionType?
    var activeEditingRequest: CoffeeRequest?

    var locationManager: CLLocationManager?
    let geofenceRadius: CLLocationDistance = 100
    let desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyNearestTenMeters
    let updateDistance: CLLocationDistance = 10

    override func viewDidLoad() {
        super.viewDidLoad()

        // initialize location manager
        locationManager = CLLocationManager()
        locationManager?.delegate = self

        // Enable location tracking when app sleeps
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false

        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager?.requestAlwaysAuthorization()
            locationManager?.requestWhenInUseAuthorization()
        }

        // Accuracy of location data
        locationManager?.desiredAccuracy = desiredAccuracy

        // The minimum distance before an update event is generated
        locationManager?.distanceFilter = updateDistance
        locationManager?.startUpdatingLocation()
        locationManager?.startMonitoringSignificantLocationChanges()

        // Initialize My Requests table
        myRequestTableView.register(RequesterTableViewCell.self, forCellReuseIdentifier: RequesterTableViewCell.reuseIdentifier)
        myRequestTableView.delegate = self
        myRequestTableView.dataSource = self

        helperTableView.register(HelperTableViewCell.self, forCellReuseIdentifier: HelperTableViewCell.reuseIdentifier)
        helperTableView.delegate = self
        helperTableView.dataSource = self

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








    //On schedule delivery button pressed
    @IBAction func createNewOrder() {
        self.currentActionType = .Order
        self.performSegue(withIdentifier: "orderFormSegue", sender: self)

        /*// Check time - only open 11AM - 5PM
        if (checkDeliveryAvailabilityTimeframe()) {
            self.currentActionType = .Order
            self.performSegue(withIdentifier: "orderFormSegue", sender: self)
        } else {
            let alert = UIAlertController(title: "You can only submit requests between 11AM - 5PM each day.", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            }))
            self.present(alert, animated: true, completion: nil)
        }*/
    }

    func checkDeliveryAvailabilityTimeframe() -> Bool {
        let now = NSDate()
        let nowDateValue = now as Date
        let todayAt11AM = Calendar.current.date(bySettingHour: 11, minute: 0, second: 0, of: nowDateValue)
        let todayAt5PM = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: nowDateValue)

        return nowDateValue >= todayAt11AM! && nowDateValue <= todayAt5PM!
    }










    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locToSave = locations.last!

        let loc = manager.location?.coordinate
        print("\nUser is at (\(loc!.latitude), \(loc!.longitude))")
        print(CLLocation(latitude: loc!.latitude, longitude: loc!.longitude).distance(from: CLLocation(latitude: 42.060271, longitude: -87.675804)), "meters from Lisa's Cafe")

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

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.authorizedAlways) {
            for coffeeLocation in (pickupLocations + meetingPointLocations) {
                setUpGeofence(geofenceRegionCenter: coffeeLocation.1, radius: geofenceRadius, identifier: coffeeLocation.0)
            }
        }
    }

    func setUpGeofence(geofenceRegionCenter: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String) {
        //CLLocationCoordinate2D(latitude: 42.060171, longitude: -87.675804) -> Lisa's
        let geofenceRegion = CLCircularRegion(center: geofenceRegionCenter,
                                              radius: radius,
                                              identifier: identifier)
        geofenceRegion.notifyOnEntry = true
        geofenceRegion.notifyOnExit = true

        locationManager?.startMonitoring(for: geofenceRegion)
    }

    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion){
        locationManager?.requestState(for: region)
    }

    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if (region.identifier == "Lisa's") {
            print("\nThe user is " + (state.rawValue == 1 ? "inside" : "outside") + " the " + region.identifier + " Geofence.")
            print(region)
        }
    }

    // called when user enters a monitored region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered Geofence")
        if (region.identifier == "Lisa's") {
            User.sendNotification(deviceId: defaults.string(forKey: "tokenId")!, message: "Welcome to Lisa's Cafe!")
        }
    }

    // called when user leaves a monitored region
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited Geofence")
        if (region.identifier == "Lisa's") {
            User.sendNotification(deviceId: defaults.string(forKey: "tokenId")!, message: "So long, Lisa's")
        }
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
        
        CoffeeRequest.getAllOpen(completionHandler: { coffeeRequests in
            DispatchQueue.main.async {
                self.openRequests = coffeeRequests
                self.helperTableView.reloadData()
            }
        })

/*
        User.getMyTasks(completionHandler: { coffeeRequests in
            DispatchQueue.main.async {
                self.openRequests = coffeeRequests
                self.helperTableView.reloadData()
            }
        })
 */
    }



















    // MARK: Table View Configuration

    //Return number of sections in table view
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Return number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0

        if(tableView == myRequestTableView){
            rowCount = myRequests.count
        }

        if (tableView == helperTableView){
            rowCount = openRequests.count
        }

        return rowCount
    }

    // Configure and display cells in table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Render label data
        if tableView == myRequestTableView {
            // Grab request to render
            let request = myRequests[indexPath.row]

            let cell = RequesterTableViewCell()
            cell.statusLabel.text = "Status: \(request.status)"
            cell.itemDetailsLabel.text = "Item: \(request.item)"
            cell.locationDetailsLabel.text = "From: \(request.pickupLocation)"
            cell.contactHelperButton.tag = 0

            // Contact helper button
            cell.contentView.isUserInteractionEnabled = true
            cell.contactHelperButton.tag = indexPath.row
            cell.contactHelperButton.addTarget(self, action: #selector(contactUser),
                                                  for: .touchUpInside)
            return cell
        } else if tableView == helperTableView {
            // Grab request to render
            let request = openRequests[indexPath.row]

            let cell = HelperTableViewCell()
            if (request.status == "Accepted") {
                cell.statusLabel.text = "Accepted"
                cell.contentView.isUserInteractionEnabled = false
            } else {
                cell.statusLabel.text = "Requested by \(String(describing: request.requester!.username))"
                cell.contentView.isUserInteractionEnabled = true
            }
            cell.itemDetailsLabel.text = "Item: \(request.item)"
            cell.locationDetailsLabel.text = "From: \(Location.camelCaseToWords(camelCaseString: request.pickupLocation))"

            cell.contentView.isUserInteractionEnabled = true
            let phoneNumber = request.requester?.phoneNumber ?? "0"
            cell.contactRequesterButton.tag = Int(phoneNumber) ?? 0
            cell.contactRequesterButton.addTarget(self, action: #selector(contactUser), for: .touchUpInside)

/*
            // Alert user if task is expired
            let currentTime = NSDate()
            if (currentTime.compare(CoffeeRequest.stringToDate(s:request.orderEndTime)) == .orderedDescending) {
                let alert = UIAlertController(title: "One of your tasks has expired.", message: "Please mark it as complete or delete it from your table by swiping left if you weren't able to complete it.", preferredStyle: .alert)
                let cancel = UIAlertAction(title: "OK", style: .cancel, handler: { (_) in
                })

                alert.addAction(cancel)
                present(alert, animated: true, completion: nil)
            }
 */

            return cell
        }
        return UITableViewCell()
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
        } else if tableView == helperTableView {
            let acceptPage: AcceptConfirmationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "acceptConfirmationViewController") as! AcceptConfirmationViewController
            acceptPage.request = self.openRequests[indexPath.row]
            self.present(acceptPage, animated: true, completion: nil)
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
        let apiUrl: String = "\(Constants.apiUrl)feedback"

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












    @objc func contactUser(sender: UIButton) {
        print("In contact requester")
        //let phoneNumber = String(sender.tag)
        let phoneNumber = Constants.researcherNumber
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
