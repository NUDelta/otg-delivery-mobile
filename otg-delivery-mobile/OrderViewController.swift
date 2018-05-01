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
    
    var locationManager: CLLocationManager?
    let coffeeLocations: [(locationName: String, location: CLLocationCoordinate2D)] = [
        ("Norbucks", CLLocationCoordinate2D(latitude: 42.053343, longitude: -87.672956)),
        ("Sherbucks", CLLocationCoordinate2D(latitude: 42.04971, longitude: -87.682014)),
        ("Kresge Starbucks", CLLocationCoordinate2D(latitude: 42.051725, longitude: -87.675103)),
        ("Fran's", CLLocationCoordinate2D(latitude: 42.051717, longitude: -87.681063)),
        ("Coffee Lab", CLLocationCoordinate2D(latitude: 42.058518, longitude: -87.683645)),
        ("Kaffein", CLLocationCoordinate2D(latitude: 42.046968, longitude: -87.679088))
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
        self.acceptedRequestTableView.delegate = self
        self.acceptedRequestTableView.dataSource = self
        
        // Initialize My Requests table
        self.myRequestTableView.delegate = self
        self.myRequestTableView.dataSource = self
        
        loadMyRequests()
        
        // Initialize listener for whenever app becoming active
        // To reload request data and update table
        NotificationCenter.default.addObserver(self, selector: #selector(loadMyRequests), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //If user logged in, peace
        if UserDefaults.standard.object(forKey: "username") == nil {
            performSegue(withIdentifier: "loginSegue", sender: nil)
        }
        
        loadMyRequests()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.last!)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("User entered within coffee region.")

        CoffeeRequest.getUnfilledCoffeeRequest(completionHandler: { coffeeRequest in
            print("Printing request...")
            print(coffeeRequest ?? "Request not set...")
            
            if let coffeeReq = coffeeRequest {
                
                //Set most recent request in user defaults
                let defaults = UserDefaults.standard
                defaults.set(coffeeReq.requestId!, forKey: "latestRequestNotification")
                
                self.sendNotification(locationName: region.identifier, coffeeRequest: coffeeReq)
            }
            
        })
        
    }
    
    
    func sendNotification(locationName: String, coffeeRequest: CoffeeRequest){

        print("VIEW CONTROLLER: sending coffee pickup notification")

        //Log to server that user is being notified
        sendLoggingEvent(forLocation: locationName, forRequest: coffeeRequest)
        
        let content = UNMutableNotificationContent()
        content.title = coffeeRequest.requester + " needs coffee!"
        content.body = "Please pick up a " + coffeeRequest.orderDescription + " from " + locationName;
        content.categoryIdentifier = "requestNotification"
        content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 5, repeats: false)
        let notificationRequest = UNNotificationRequest(identifier: "identifier", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(notificationRequest, withCompletionHandler: { (error) in
            if let error = error {
                print("Error in notifying from Pre-Tracker: \(error)")
            }
        })
    }
    
    func sendLoggingEvent(forLocation locationName: String, forRequest request: CoffeeRequest){
        
        //private static let apiUrl: String = "https://otg-delivery-backend.herokuapp.com/logging"
        let apiUrl: String = "http://localhost:8080/logging"
        
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
        guard segue.identifier == "loginSegue",
            let navController = segue.destination as? UINavigationController,
            let controller = navController.viewControllers.first as? LoginViewController else {
                return
        }
        
        controller.didLogIn = { [weak self] in
            DispatchQueue.main.async {
                self?.dismiss(animated: true, completion: nil)
            }
        }
    
    }
    
    @objc func loadMyRequests() {
        CoffeeRequest.getMyRequest(completionHandler: { coffeeRequests in
            DispatchQueue.main.async {
                self.myRequests = coffeeRequests
                self.myRequestTableView.reloadData()
            }
        })
        
        CoffeeRequest.getMyAcceptedRequests(completionHandler: { coffeeRequests in
            DispatchQueue.main.async {
                self.acceptedRequests = coffeeRequests
                self.acceptedRequestTableView.reloadData()
            }
        })
    }
    
    func loadAcceptedRequests() {
        
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyRequestTableViewCell", for: indexPath) as? MyRequestTableViewCell else {
            fatalError("The dequeued cell is not an instance of MyRequestTableViewCell")
        }
        
        
        if tableView == myRequestTableView {
            
            // Grab request to render
            let request = myRequests[indexPath.row]
        
            // Configure display cell
            cell.orderLabel.text = request.orderDescription
            cell.statusLabel.text = request.status
        

           
            print("MAKE IT HERE")
            
            // If we don't have an end time, something else is very wrong, but let's exit gracefully nonetheless
            // (seems like an issue with optionals is that you have no idea which optional chain breaks the program,
            // Pretty much turning compile time errors into runtime errors? Hm.
            guard let date = request.endTime else {
                return cell;
            }
            
            cell.dateLabel.text = date;
            
        }
        
        
        if tableView == acceptedRequestTableView {
            
            // Grab request to render
            let request = acceptedRequests[indexPath.row]
            
            // Configure display cell
            cell.orderLabel.text = request.orderDescription
            cell.statusLabel.text = "Accepted"
         
            
        }
        
        return cell
    }
 
     // Support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
         // Return false if you do not want the specified item to be editable.
         return true
     }
    
    
     // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
             // Delete the row from the data source
            let deletedRequest = myRequests.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // Delete request from database
            let deleteID = deletedRequest.requestId
            CoffeeRequest.deleteRequest(with_id: deleteID!)
            self.myRequestTableView.reloadData()
         }
     }
    
    // Support editing of rows in the table view when you click on a row
    // Updates corresponding request in database
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == myRequestTableView {
        
            // Launch request editor on click
            let editController = UIAlertController(title: "Edit Request Description", message: "", preferredStyle: .alert)
            let currentRequest = self.myRequests[indexPath.row]

            // Update table view and database on 'Update'
            editController.addTextField { (descriptionUpdater) in
                descriptionUpdater.text = currentRequest.orderDescription
                descriptionUpdater.placeholder = "Updated Order Description"
                // have current text be the current name of the request
            }
        
            let updateAction = UIAlertAction(title: "Update", style: .default) { (alertAction) in
                let descriptionUpdater = editController.textFields![0] as UITextField
                
                // Update database
                CoffeeRequest.updateRequest(with_id: currentRequest.requestId!, to_order: descriptionUpdater.text!, completionHandler: {
                
                    // Update view
                    let updatedRequest = CoffeeRequest.getRequest(with_id: currentRequest.requestId!, completionHandler: { (coffeeRequest) in
                        self.myRequests[indexPath.row] = coffeeRequest!
                        
                        //Since this is UI related, must perform in main thread
                        DispatchQueue.main.async {
                            self.myRequestTableView.reloadData()
                        }
                        
                    })
                    
                })
                
            }
        
            // Do nothing on 'Cancel'
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
            // Add actions to editor
            editController.addAction(updateAction)
            editController.addAction(cancelAction)
        
            present(editController, animated: true, completion: nil)
            
        }
        
        if tableView == acceptedRequestTableView {
          
            // Launch request editor on click
            let completedAlert = UIAlertController(title: "Request Completed!", message: "Please leave a brief comment on the convenience of the interaction below!", preferredStyle: .alert)
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
            
        }
    }
    
    func sendFeedback(feedbackText: String?){
        
        //In case the input doesn't exist
        guard let feedbackText = feedbackText else {
            print("FEEDBACK: Nil found as feedback value, exiting gracefully.")
            return
        }
        
        //private static let apiUrl: String = "https://otg-delivery-backend.herokuapp.com/feedback"
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

