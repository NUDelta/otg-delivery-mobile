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
    @IBOutlet weak var myRequestTableView: UITableView!
    
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
        
        // Initialize My Requests table
        self.myRequestTableView.delegate = self
        self.myRequestTableView.dataSource = self
        
        CoffeeRequest.getMyRequest(completionHandler: { coffeeRequests in
            DispatchQueue.main.async {
                self.myRequests += coffeeRequests;
                self.myRequestTableView.reloadData()
            }
           /*
            guard let existingRequest = coffeeRequest else {
                print("Current user does not have any requests")
                return
            }
            
            DispatchQueue.main.async {
                self.myRequests += [existingRequest]
                self.myRequestTableView.reloadData()
            }
 */
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //If user logged in, peace
        if UserDefaults.standard.object(forKey: "username") == nil {
            performSegue(withIdentifier: "loginSegue", sender: nil)
        }
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
    
    // MARK: Table View Configuration
    
    //Return number of sections in table view
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Return number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myRequests.count
    }
    
    // Configure and display cells in table view
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyRequestTableViewCell", for: indexPath) as? MyRequestTableViewCell else {
            fatalError("The dequeued cell is not an instance of MyRequestTableViewCell")
        }
        
        // Grab request to render
        let request = myRequests[indexPath.row]
        
        // Configure display cell
        cell.orderLabel.text = request.orderDescription
        cell.statusLabel.text = "Open"
        
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
           // CoffeeRequest.updateRequest(with_id: currentRequest.requestId!, to_order: "TEST", to_timeframe: currentRequest.timeFrame!)
            CoffeeRequest.updateRequest(with_id: currentRequest.requestId!, to_order: descriptionUpdater.text!, to_timeframe: "10000000")
            
            // Update view
            let updatedRequest = CoffeeRequest.getRequest(with_id: currentRequest.requestId!, completionHandler: { (coffeeRequest) in
                // TODO : Error handling
                self.myRequests[indexPath.row] = coffeeRequest!
                self.myRequestTableView.reloadData()
            })
        }
        
        // Do nothing on 'Cancel'
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Add actions to editor
        editController.addAction(updateAction)
        editController.addAction(cancelAction)
        
        present(editController, animated: true, completion: nil)
        
    }
    


}

