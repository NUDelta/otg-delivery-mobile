import UIKit
import UserNotifications
import CoreLocation
import MessageUI

class OrderViewController: UIViewController {

    public static let sharedManager = OrderViewController()
    @IBOutlet weak var requestTableView: RequestTableView!

    var openRequests = [CoffeeRequest]()

    var currentActionType: OrderActionType?
    var activeEditingRequest: CoffeeRequest?

    var locationManager: CLLocationManager?
    let geofenceRadius: CLLocationDistance = 100 //Radii of geofences around pickup locations
    let desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyNearestTenMeters
    let passiveUpdateDistance: CLLocationDistance = 20 //location update refresh distance not during orders
    let activeUpdateDistance: CLLocationDistance = 5 //location update refresh distance during orders

    var timer: Timer!
    let activeRequestId = defaults.string(forKey: "ActiveRequestId")

    override func viewDidLoad() {
        super.viewDidLoad()

        // initialize location manager
        locationManager = CLLocationManager()
        locationManager?.delegate = self

        // Enable location tracking when app sleeps
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false

        if CLLocationManager.authorizationStatus() == .notDetermined || CLLocationManager.authorizationStatus() == .denied {
            locationManager?.requestAlwaysAuthorization()
            // locationManager?.requestWhenInUseAuthorization()
        }

        // Accuracy of location data
        locationManager?.desiredAccuracy = desiredAccuracy

        requestTableView.register(RequestTableViewCell.self, forCellReuseIdentifier: RequestTableViewCell.reuseIdentifier)
        requestTableView.delegate = self
        requestTableView.dataSource = self

        // Initialize listener for whenever app becomes active
        // To reload request data and update table
        NotificationCenter.default.addObserver(self, selector: #selector(loadData), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        //If user not logged in, transition to login page
        let userID = defaults.object(forKey: "userId")
        if userID == nil {
            timer = nil
            performSegue(withIdentifier: "loginSegue", sender: nil)
        } else {
            print("User with ID ", userID as! String)
        }

        //Move to active request pages if we have an active request
        if (activeRequestId != nil && activeRequestId != "") {
            self.locationManager?.distanceFilter = self.activeUpdateDistance
            locationManager?.startUpdatingLocation()
            locationManager?.startMonitoringSignificantLocationChanges()

            CoffeeRequest.getRequest(with_id: activeRequestId!, completionHandler: {request in
                DispatchQueue.main.async {
                    let userID = defaults.string(forKey: "userId")
                    if request?.status == userID {
                        //nothing
                    } else if request?.status == request?.helper?.userId {
                        self.performSegue(withIdentifier: "BackToFeedback", sender: self)
                    } else {
                        self.performSegue(withIdentifier: "OrderAccepted", sender: self)
                    }
                }
            })
        } else {
            self.locationManager?.distanceFilter = self.passiveUpdateDistance
            locationManager?.startUpdatingLocation()
            locationManager?.startMonitoringSignificantLocationChanges()

            loadData()
        }
    }

    // MARK: UI Management

    //On schedule delivery button pressed
    @IBAction func createNewOrder() {
        if (openRequests.count > 0 && isMyRequest(indexPath: IndexPath(item: 0, section: 0))) {
            let alertController = UIAlertController(title: "You can only have one open request at a time.", message: "", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        } else {
            // if (checkDeliveryAvailabilityTimeframe()) {
                self.currentActionType = .Order
                self.performSegue(withIdentifier: "orderFormSegue", sender: self)
            /* } else {
                let alert = UIAlertController(title: "You can only submit requests between 9AM - 5PM each day.", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                }))
                self.present(alert, animated: true, completion: nil)
            } */
        }
    }

    //set to limit times that app is active for study
    func checkDeliveryAvailabilityTimeframe() -> Bool {
        let now = NSDate()
        let nowDateValue = now as Date
        let todayAt9AM = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: nowDateValue)
        let todayAt5PM = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: nowDateValue)

        return nowDateValue >= todayAt9AM! && nowDateValue <= todayAt5PM!
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

    //getting the requests to be shown in the table
    @objc func loadData() {
        //get current user's requests
        User.getMyRequests(completionHandler: { myRequests in
            DispatchQueue.main.async {
                //get all requests and filter by nearby pickup locations
                CoffeeRequest.getAllOpen(completionHandler: { coffeeRequests in
                    DispatchQueue.main.async {
                        var nearCoffeeRequests: [CoffeeRequest] = []
                        for request in coffeeRequests {
                            for location in pickupLocations {
                                if request.pickupLocation == location.locationName {
                                    let pickupLocationCoordinate = CLLocation(latitude: location.location.latitude, longitude: location.location.longitude)
                                    if self.locationManager!.location != nil {
                                        let distance = pickupLocationCoordinate.distance(from: self.locationManager!.location!)
                                        if distance <= 100.0 {
                                            nearCoffeeRequests.append(request)
                                            break
                                        }
                                    } else {
                                        nearCoffeeRequests.append(request)
                                        break
                                    }
                                }
                            }
                        }
                        self.openRequests = myRequests + nearCoffeeRequests
                        self.requestTableView.reloadData()
                        if self.timer == nil {
                            // self.reloadTimer()
                        }
                    }
                })
            }
        })
    }

    //refresh the page every 15 seconds
    //TODO: maybe cut this because we're sending too many location updates and causing battery drain
    func reloadTimer() {
        timer = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(self.loadData), userInfo: nil, repeats: true)
    }

}

extension OrderViewController: CLLocationManagerDelegate {

    //sends a location update whenever user moves
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locToSave = locations.last!

        let loc = manager.location?.coordinate
        print("\nUser is at (\(loc!.latitude), \(loc!.longitude))")
        //print(CLLocation(latitude: loc!.latitude, longitude: loc!.longitude).distance(from: CLLocation(latitude: 42.060271, longitude: -87.675804)), "meters from Lisa's Cafe")

        let latitude = Double(locToSave.coordinate.latitude)
        let longitude = Double(locToSave.coordinate.longitude)
        let speed = Double(locToSave.speed)
        let direction = Double(locToSave.course)
        let uncertainty = Double(locToSave.horizontalAccuracy)

        guard let userId = defaults.string(forKey: "userId") else {
            print("Helper ID not in defaults")
            return
        }

        // TODO: This is being sent too often, causing battery drain
        //if activeRequestId != nil {
            let locUpdate = LocationUpdate(latitude: latitude, longitude: longitude, speed: speed, direction: direction, uncertainty: uncertainty, userId: userId)
            LocationUpdate.post(locUpdate: locUpdate)
        //}
    }

    func removeCachedGeofenceLocation() {
        defaults.removeObject(forKey:"currentGeofenceLocation")
    }

    //set up geofences around the pickup locations
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        for coffeeLocation in (pickupLocations + meetingPointLocations) {
            setUpGeofence(geofenceRegionCenter: coffeeLocation.1, radius: geofenceRadius, identifier: coffeeLocation.0)
        }
    }

    func setUpGeofence(geofenceRegionCenter: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String) {
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
        //print("\nThe user is " + (state.rawValue == 1 ? "inside" : "outside") + " the '" + region.identifier + "' Geofence.")
    }

    // called when user enters a monitored region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered \(region.identifier) Geofence.")

        // Called when helper approaches meeting point
        if (activeRequestId != nil && activeRequestId != "") {
            if region.identifier == activeRequestId {
                User.sendNotification(deviceId: defaults.string(forKey: "RequesterId")!, message: "Your helper is within 100m of the meeting point. Please proceed to the specified location.")
            }
        } else { // Called when a potential helper enters a restaurant geofence with an open request
            for request in openRequests {
                if (request.pickupLocation == region.identifier) {
                    if (defaults.string(forKey: "tokenId") != nil) {
                        User.sendNotification(deviceId: defaults.string(forKey: "tokenId")!, message: "Open requests available at \(region.identifier)")
                        Notification.save(userId: defaults.string(forKey: "userId")!, type: "RequestAvailable")
                        print("Notification sent to \(defaults.string(forKey: "tokenId")!) at \(region.identifier).")
                    }
                    break
                }
            }

            // Mark user as being in region
        }
    }

    // called when user leaves a monitored region
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited \(region.identifier) Geofence")
        /* if (defaults.string(forKey: "tokenId") != nil) {
            User.sendNotification(deviceId: defaults.string(forKey: "tokenId")!, message: "Leaving \(region.identifier)!")
        } */

        // Remove user from being marked in region
        
    }

}

extension OrderViewController: UITableViewDelegate, UITableViewDataSource {

    //Return number of sections in table view
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Return number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return openRequests.count
    }

    // Configure and display cells in table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let request = openRequests[indexPath.row]
        let cell = RequestTableViewCell()

        if request.status == defaults.string(forKey: "userId") {
            return cell
        }

        cell.contentView.isUserInteractionEnabled = true

        cell.itemDetailsLabel.text = "Item: \(request.item)"
        cell.locationDetailsLabel.text = "From: \(Location.camelCaseToWords(camelCaseString: request.pickupLocation))"

        if (isMyRequest(indexPath: indexPath)) { //user made request
            if (request.status == "Accepted" || request.status == "Picked Up") {
                defaults.set(request.requestId, forKey: "ActiveRequestId")
                timer = nil
                performSegue(withIdentifier: "OrderAccepted", sender: nil)
            } else {
                cell.statusLabel.text = "Your request is pending acceptance."
                cell.statusLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
                cell.itemDetailsLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
                cell.locationDetailsLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
            }
        } else if (request.helper?.username == defaults.string(forKey: "username")) { //user is helper
            defaults.set(request.requestId, forKey: "ActiveRequestId")
            timer = nil
            performSegue(withIdentifier: "OrderAccepted", sender: nil)
        } else { //user not involved
            if (request.status == "Accepted") {
                cell.statusLabel.text = "Accepted by someone else."
            } else {
                cell.statusLabel.text = ""
            }
        }
        return cell
    }

     // Support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
         // Return false if you do not want the specified item to be deletable.
         return isMyRequest(indexPath: indexPath)
    }

     // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete && isMyRequest(indexPath: indexPath)) {
            let deleteConfirmation = UIAlertController(title: "Are you sure you would like to delete this request?", message: "", preferredStyle: .alert)

            let confirmAction = UIAlertAction(title: "Confirm", style: .destructive, handler: {(action: UIAlertAction!) in
                // Delete the row from the table view
                let deletedRequest = self.openRequests.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)

                // Delete request from database
                let deleteID = deletedRequest.requestId
                CoffeeRequest.deleteRequest(with_id: deleteID)
                self.requestTableView.reloadData()
            })
            // Do nothing on 'Cancel'
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

            // Add actions to editor
            deleteConfirmation.addAction(cancelAction)
            deleteConfirmation.addAction(confirmAction)

            present(deleteConfirmation, animated: true, completion: nil)
        }
     }

    // Support editing of rows in the table view when you click on a row
    // Updates corresponding request in database
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (isMyRequest(indexPath: indexPath)) {
            // Launch request editor on click
            let editAlert = UIAlertController(title: "Would you like to edit your request?", message: "You will have to reselect all fields of request", preferredStyle: .alert)

            let action = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                self.currentActionType = .Edit
                self.activeEditingRequest = self.openRequests[indexPath.row]
                self.performSegue(withIdentifier: "orderFormSegue", sender: self)
            })

            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

            editAlert.addAction(action)
            editAlert.addAction(cancel)
            present(editAlert, animated: true, completion: nil)
        } else {
            let acceptPage: AcceptConfirmationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "acceptConfirmationViewController") as! AcceptConfirmationViewController
            acceptPage.request = self.openRequests[indexPath.row]
            self.present(acceptPage, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    func isMyRequest(indexPath: IndexPath) -> Bool {
        return openRequests[indexPath.row].requester?.userId == defaults.string(forKey: "userId")
    }

}

extension OrderViewController: MFMessageComposeViewControllerDelegate {

    @objc func contactUser(sender: UIButton) {
        print("In contact user")
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
