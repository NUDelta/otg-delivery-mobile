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

class OrderViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    
    var myRequests = [CoffeeRequest]()
    var acceptedRequests = [CoffeeRequest]()
    
    @IBOutlet weak var myRequestTableView: UITableView!
    @IBOutlet weak var acceptedRequestTableView: UITableView!
    
    //Current request type
    var currentActionType: OrderActionType?
    var activeEditingRequest: CoffeeRequest?
    
    //On plus sign pressed
    @IBAction func createNewOrder() {
        self.currentActionType = .Order
        self.performSegue(withIdentifier: "orderFormSegue", sender: self)
    }
    
    public static let sharedManager = OrderViewController()

    var locationManager: CLLocationManager?
    let coffeeLocations: [(locationName: String, location: CLLocationCoordinate2D)] = [
//        ("Norbucks", CLLocationCoordinate2D(latitude: 42.053343, longitude: -87.672956)),
//        ("Sherbucks", CLLocationCoordinate2D(latitude: 42.04971, longitude: -87.682014)),
//        ("Kresge Starbucks", CLLocationCoordinate2D(latitude: 42.051725, longitude: -87.675103)),
//        ("Fran's", CLLocationCoordinate2D(latitude: 42.051717, longitude: -87.681063)),
//        ("Coffee Lab", CLLocationCoordinate2D(latitude: 42.058518, longitude: -87.683645)),
//        ("Kaffein", CLLocationCoordinate2D(latitude: 42.046968, longitude: -87.679088)),
        ("Tomate", CLLocationCoordinate2D(latitude: 42.058345, longitude: -87.683724))
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(defaultsChanged),
                                               name: UserDefaults.didChangeNotification,
                                               object: nil)
        */
        
        // initialize location manager
        locationManager = CLLocationManager()
        
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager?.requestAlwaysAuthorization()
            locationManager?.requestWhenInUseAuthorization()
        }
        
        locationManager?.startUpdatingLocation()
        // use our predefined locations to setup the geo-fences
        for coffeeLocation in coffeeLocations {
            let region = CLCircularRegion(center: coffeeLocation.1, radius: 100, identifier: coffeeLocation.0)
            region.notifyOnEntry = true
            region.notifyOnExit = false
        
            locationManager?.startMonitoring(for: region)
        }
        
        // Initialize Accepted Requests table
        acceptedRequestTableView.register(RequestStatusTableViewCell.self, forCellReuseIdentifier: RequestStatusTableViewCell.reuseIdentifier)
        self.acceptedRequestTableView.delegate = self
        self.acceptedRequestTableView.dataSource = self
        
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
        print(UserDefaults.standard.object(forKey: "userId"))
        //If user logged in, peace
        if UserDefaults.standard.object(forKey: "userId") == nil {
            performSegue(withIdentifier: "loginSegue", sender: nil)
        }
        
        loadData()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.last!)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("User entered within coffee region.")

        CoffeeRequest.getOpenTask(completionHandler: { coffeeRequest in
            print("Printing request...")
            print(coffeeRequest ?? "Request not set...")
            
            if let coffeeReq = coffeeRequest {
                
                //Set most recent request in user defaults
                let defaults = UserDefaults.standard
                defaults.set(coffeeReq.requestId!, forKey: "latestRequestNotification")
                
                // instead of sending the name of the region, grab the name of the location from the coffee request
                // because tomate and coffee lab are in the same region - don't know which request
                self.sendNotification(locationName: region.identifier, request: coffeeReq)
            }
            
        })
        
    }
    
    
    func sendNotification(locationName: String, request: CoffeeRequest){

        print("VIEW CONTROLLER: sending coffee pickup notification")

        //Log to server that user is being notified
        sendLoggingEvent(forLocation: locationName, forRequest: request)
        
        UserModel.get(with_id: request.requester, completionHandler: { helperUserModel in
        
            guard let helperUserModel = helperUserModel else {
                print("NO HELPER RETURNED WHEN GETTING THEIR MODEL DURING NOTIFICATION!!!!!!!")
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = helperUserModel.username + " is hungry!"
            content.body = "Please pick up a " + request.orderDescription + " from " + locationName + ", and deliver to \(helperUserModel.username) at " + request.deliveryLocation + " by \(CoffeeRequest.parseTime(dateAsString: request.endTime!)).";

            
            content.categoryIdentifier = "requestNotification"
            content.sound = UNNotificationSound.default()
        
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 5, repeats: false)
            let notificationRequest = UNNotificationRequest(identifier: "identifier", content: content, trigger: trigger)
        
            UNUserNotificationCenter.current().add(notificationRequest, withCompletionHandler: { (error) in
                if let error = error {
                    print("Error in notifying from Pre-Tracker: \(error)")
                }
            })
            
        })
    }
    
    func sendLoggingEvent(forLocation locationName: String, forRequest request: CoffeeRequest){
        
        let apiUrl: String = "https://otg-delivery-backend.herokuapp.com/logging"
        //let apiUrl: String = "http://localhost:8080/logging"
        
        let defaults = UserDefaults.standard
        let requesterName = defaults.object(forKey: "username")
        
        var components = URLComponents(string: "")
        components?.queryItems = [
            URLQueryItem(name: "username", value: requesterName as? String),
            URLQueryItem(name: "locationEntered", value: locationName),
            URLQueryItem(name: "eventType", value: "NOTIFIED"),
            URLQueryItem(name: "requestId", value: request.requestId),
        ]
        
        let url = URL(string: apiUrl)
        let session: URLSession = URLSession.shared
        var requestURL = URLRequest(url: url!)
        
        requestURL.httpMethod = "POST"
        requestURL.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        //These two lines are cancerous :: something severly wrong with my hack with URLComponents
        let httpBodyString: String? = components?.url?.absoluteString
        requestURL.httpBody = httpBodyString?.dropFirst(1).data(using: .utf8)
        
        let task = session.dataTask(with: requestURL){ data, response, error in
            print("LOGGING: Logged notification to server.")
        }
        
        task.resume()
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
        
        if segue.identifier == "orderFormSegue" {
            let navController = segue.destination as? UINavigationController
            let controller = navController?.viewControllers.first as? OrderModalViewController
            controller?.activeEditingRequest = self.activeEditingRequest
            controller?.actionType = self.currentActionType
            
            print("Sending action type \(currentActionType)")
        }
    }
    
    @objc func loadData() {
        UserModel.getMyRequests(completionHandler: { coffeeRequests in
            DispatchQueue.main.async {
                self.myRequests = coffeeRequests
                self.myRequestTableView.reloadData()
            }
        })
        
        UserModel.getMyTasks(completionHandler: { coffeeRequests in
            DispatchQueue.main.async {
                self.acceptedRequests = coffeeRequests
                self.acceptedRequestTableView.reloadData()
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
        
        var rowCount = 0
        
        if(tableView == myRequestTableView){
            rowCount = self.myRequests.count
        }
        
        else if(tableView == acceptedRequestTableView){
            rowCount = self.acceptedRequests.count
        }
        
        return rowCount
    }
    
    // Configure and display cells in table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        // Render label data
        if tableView == myRequestTableView {
            
            /*guard let cell = tableView.dequeueReusableCell(withIdentifier: RequestStatusTableViewCell.reuseIdentifier, for: indexPath) as? RequestStatusTableViewCell else {
                fatalError("Couldn't dequeue RequestStatusTableViewCell")
            }*/
            let cell = RequestStatusTableViewCell()
            
            // Grab request to render
            let request = myRequests[indexPath.row]
            
            cell.orderLabel.text = request.orderDescription
            if (request.status == "Accepted") {
                var status = "Accepted"
                UserModel.get(with_id: request.helper!, completionHandler: { helperUserModel in
                    guard let helperUserModel = helperUserModel else {
                        print("No helper returned when trying to get helper name for a request.")
                        return
                    }
                    let helperName = helperUserModel.username
                    status = "Accepted by \(helperName)"
                    DispatchQueue.main.async {
                        cell.statusDetailsLabel.text = status
                    }
                })
            } else {
                cell.statusDetailsLabel.text = request.status
            }
            
            let endTime = CoffeeRequest.parseTime(dateAsString: request.endTime!)
            cell.expirationDetailsLabel.text = endTime
            cell.deliveryLocationDetailsLabel.text = request.deliveryLocation
            cell.deliveryDetailsDetailsLabel.text = request.deliveryLocationDetails
            
            // Text wraps
            cell.orderLabel.numberOfLines = 0
            cell.statusDetailsLabel.numberOfLines = 0
            cell.expirationDetailsLabel.numberOfLines = 0
            cell.deliveryLocationDetailsLabel.numberOfLines = 0
            cell.deliveryDetailsDetailsLabel.numberOfLines = 0
            
            return cell

        } else if tableView == acceptedRequestTableView {
            
            /*guard let cell = tableView.dequeueReusableCell(withIdentifier: AcceptedRequestTableViewCell.reuseIdentifier, for: indexPath) as? AcceptedRequestTableViewCell else {
                fatalError("Couldn't dequeue AcceptedRequestTableViewCell")
            }*/
            let cell = AcceptedRequestTableViewCell()
 
            // Grab request to render
            let request = acceptedRequests[indexPath.row]
            
            cell.orderLabel.text = request.orderDescription
            if (request.status == "Accepted") {
                var status = "Accepted"
                UserModel.get(with_id: request.requester, completionHandler: { requesterUserModel in
                    guard let requesterUserModel = requesterUserModel else {
                        print("No helper returned when trying to get helper name for a request.")
                        return
                    }
                    let requesterName = requesterUserModel.username
                    status = "Requested by \(requesterName)"
                    DispatchQueue.main.async {
                        cell.statusDetailsLabel.text = status
                    }
                })
            } else {
                cell.statusDetailsLabel.text = request.status
            }
            let endTime = CoffeeRequest.parseTime(dateAsString: request.endTime!)
            cell.expirationDetailsLabel.text = endTime
            cell.deliveryLocationDetailsLabel.text = request.deliveryLocation
            cell.deliveryDetailsDetailsLabel.text = request.deliveryLocationDetails
            
            // Text wraps
            cell.orderLabel.numberOfLines = 0
            cell.statusDetailsLabel.numberOfLines = 0
            cell.expirationDetailsLabel.numberOfLines = 0
            cell.deliveryLocationDetailsLabel.numberOfLines = 0
            cell.deliveryDetailsDetailsLabel.numberOfLines = 0
         
            // Initialize buttons
            cell.contentView.isUserInteractionEnabled = true;
            cell.completeOrderButton.tag = indexPath.row
            cell.completeOrderButton.addTarget(self, action: #selector(completeOrder), for: .touchUpInside)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    @objc func completeOrder(sender: UIButton) {
        
        let row_number = sender.tag
        
        // Launch request editor on click
        let completedAlert = UIAlertController(title: "Would you like to confirm the completion of this request?", message: "If so, please leave a brief comment on what made this interaction convenient and/or inconvenient and confirm below!", preferredStyle: .alert)
        let currentRequest = self.acceptedRequests[row_number]
        
        completedAlert.addTextField(configurationHandler: { (textField) in
            textField.text = ""
        })
        
        let action = UIAlertAction(title: "OK", style: .default, handler: { [weak completedAlert] (_) in
            let textField = completedAlert!.textFields![0]
            let responseText = textField.text
            
            self.sendFeedback(feedbackText: responseText)
            
            // Delete the row from the data source
            let deletedRequest = self.acceptedRequests.remove(at: row_number)
            let indexPath = IndexPath(row: row_number, section: 0)
            self.acceptedRequestTableView.deleteRows(at: [indexPath], with: .fade)
            //TODO tell server to mark the given request as completed
            CoffeeRequest.updateStatus(requestId: currentRequest.requestId as! String, status: "Completed", completionHandler: {
                print("NOTIFICATION ACTION: request successfully completed.")
            })
            
            self.acceptedRequestTableView.reloadData()
            
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            
        })
        
        completedAlert.addAction(action)
        completedAlert.addAction(cancel)
        present(completedAlert, animated: true, completion: nil)
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
            
            if tableView == acceptedRequestTableView {
                let deleteConfirmation = UIAlertController(title: "Are you sure you would like to remove yourself as a helper for this request?", message: "", preferredStyle: .alert)
                
                let confirmAction = UIAlertAction(title: "Confirm", style: .destructive, handler: {(action: UIAlertAction!) in
                    // Delete the row from the table view
                    let canceledRequest = self.acceptedRequests.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    // Remove helper from request in the database
                    let requestID = canceledRequest.requestId
                    UserModel.removeHelperFromTask(withId: requestID!)
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
        
        if tableView == acceptedRequestTableView {
          /*
            // Launch request editor on click
            let completedAlert = UIAlertController(title: "Would you like to confirm the completion of this request?", message: "If so, please leave a brief comment on what made this interaction convenient and/or inconvenient and confirm below!", preferredStyle: .alert)
            let currentRequest = self.acceptedRequests[indexPath.row]
            
            completedAlert.addTextField(configurationHandler: { (textField) in
                textField.text = ""
            })
         
            let action = UIAlertAction(title: "OK", style: .default, handler: { [weak completedAlert] (_) in
                let textField = completedAlert!.textFields![0]
                let responseText = textField.text

                self.sendFeedback(feedbackText: responseText)
           
                // Delete the row from the data source
                let deletedRequest = self.acceptedRequests.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                //TODO tell server to mark the given request as completed
                CoffeeRequest.updateStatusCoffeeRequestForID(requestId: currentRequest.requestId as! String, status: "Completed", completionHandler: {
                    print("NOTIFICATION ACTION: request successfully accepted.")
                })
                
                self.acceptedRequestTableView.reloadData()
                
            })
           
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in

            })
            
            completedAlert.addAction(action)
            completedAlert.addAction(cancel)
            present(completedAlert, animated: true, completion: nil)
          */
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }

    
    func sendFeedback(feedbackText: String?){
        
        //In case the input doesn't exist
        guard let feedbackText = feedbackText else {
            print("FEEDBACK: Nil found as feedback value, exiting gracefully.")
            return
        }
        
         let apiUrl: String = "https://otg-delivery-backend.herokuapp.com/feedback"
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
    

    // MARK Respond to notifications
    
    //Handle user response to notification
    @objc func defaultsChanged() {
        
        print("View Controller Receiving Notification that NOTIFICATION WAS ACCEPTED")

        let defaults = UserDefaults.standard
        if let latestNotificationId = defaults.object(forKey: "acceptedNotifications") {
            
            print(latestNotificationId)
            
            CoffeeRequest.getRequest(with_id: latestNotificationId as! String, completionHandler: {coffeeRequest in
                print(coffeeRequest)
                if let coffeeReq = coffeeRequest{
                    self.acceptedRequests = [coffeeReq]
                }
            })

            DispatchQueue.main.async {
                self.acceptedRequestTableView.reloadData()
            }
        
        }
    }
    
    

}

