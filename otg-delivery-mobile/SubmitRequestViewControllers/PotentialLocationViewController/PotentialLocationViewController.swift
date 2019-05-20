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

class PotentialLocationViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var CircleSlider: UISlider!

    var currentRequest: CoffeeRequest?
    let locationManager = CLLocationManager()
    var mapBottomConstraint: NSLayoutConstraint?
    var recentAnnotation: MKPointAnnotation?
    var recentCircle: MKCircle?

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        if (currentRequest == nil) {
            initializeRequest()
        }
        CircleSlider.isHidden = true
        CircleSlider.isEnabled = false
        addTapRecognizer()
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
        zoomToUser()
    }

    func zoomToUser() {
        let userLocation = (locationManager.location?.coordinate)!
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: userLocation, span: span)
        mapView.setRegion(region, animated: true)
    }

    func addTapRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(addMarker(_:)))
        tapRecognizer.delegate = self
        mapView.addGestureRecognizer(tapRecognizer)
    }

    @objc func addMarker(_ gestureRecognizer: UIGestureRecognizer) {
        if (gestureRecognizer.state != .ended || ConfirmOutlet.titleLabel?.text == "Add Point") {return}
        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)

        ConfirmOutlet.setTitle("Add Point", for: .normal)
        mapView.isZoomEnabled = false

        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: touchMapCoordinate, span: span)
        mapView.setRegion(region, animated: true)

        let annotation = MKPointAnnotation()
        annotation.coordinate = touchMapCoordinate
        mapView.addAnnotation(annotation)
        recentAnnotation = annotation

        let circle = MKCircle(center: touchMapCoordinate, radius: CLLocationDistance(CircleSlider.value * 100.0 + 25.0))
        mapView.addOverlay(circle)
        recentCircle = circle

        CircleSlider.isHidden = false
        CircleSlider.isEnabled = true
    }

    @IBAction func CircleSlide(_ sender: Any) {
        if (recentCircle != nil) {
            mapView.removeOverlay(recentCircle!)
            recentCircle = MKCircle(center: recentCircle!.coordinate, radius: CLLocationDistance((CircleSlider.value * 100.0) + 25.0))
            mapView.addOverlay(recentCircle!)
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if (overlay is MKCircle) {
            let renderer = MKCircleRenderer(circle: overlay as! MKCircle)
            renderer.fillColor = .blue
            renderer.alpha = 0.2
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }

    func initializeRequest() {
        currentRequest = CoffeeRequest()
        currentRequest!.requesterId = defaults.object(forKey: "userId") as! String
        currentRequest!.helperId = defaults.object(forKey: "userId") as! String //hacky but whatever
        currentRequest!.status = "Searching for Helper"
        currentRequest!.price = "0.00"
    }

    @IBOutlet weak var ConfirmOutlet: UIButton!
    @IBAction func ConfirmButton(_ sender: Any) {
        if (ConfirmOutlet.titleLabel?.text == "Add Point") {
            mapView.isZoomEnabled = true
            zoomToUser()
            ConfirmOutlet.setTitle("Confirm", for: .normal)
            recentCircle = nil
            CircleSlider.isEnabled = false
            CircleSlider.isHidden = true
        } else {
            let nextPage: RequestConfirmationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RequestConfirmationViewController") as! RequestConfirmationViewController
            nextPage.currentRequest = currentRequest
            self.present(nextPage, animated: true, completion: nil)
        }
    }
}
