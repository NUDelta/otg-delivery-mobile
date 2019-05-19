//
//  PotentialLocationViewController.swift
//  otg-delivery-mobile
//
//  Created by Cooper Barth on 5/19/19.
//  Copyright © 2019 Sam Naser. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class PotentialLocationViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!

    var currentRequest: CoffeeRequest?
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        if (currentRequest == nil) {
            initializeRequest()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        checkLocationAuthorizationStatus()
    }

    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            setUpMapView()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func setUpMapView() {
        mapView.showsUserLocation = true
        let userLocation = (locationManager.location?.coordinate)!
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: userLocation, span: span)
        mapView.setRegion(region, animated: true)
    }

    func initializeRequest() {
        currentRequest = CoffeeRequest()
        currentRequest!.requesterId = defaults.object(forKey: "userId") as! String
        currentRequest!.helperId = defaults.object(forKey: "userId") as! String //hacky but whatever
        currentRequest!.status = "Searching for Helper"
        currentRequest!.price = "0.00"
    }

    @IBAction func ConfirmButton(_ sender: Any) {
        let nextPage: RequestConfirmationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RequestConfirmationViewController") as! RequestConfirmationViewController
        nextPage.currentRequest = currentRequest
        self.present(nextPage, animated: true, completion: nil)
    }
}
