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
    @IBOutlet weak var DescriptionText: UILabel!
    @IBOutlet weak var DatePicker: UIDatePicker!

    var currentRequest: CoffeeRequest?
    let locationManager = CLLocationManager()
    var mapBottomConstraint: NSLayoutConstraint?
    var recentAnnotation: MKPointAnnotation?
    var recentCircle: MKCircle?

    var currentPoint: MeetingPoint?
    var meetingPoints: [MeetingPoint] = []
    var currentStartDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        if (currentRequest == nil) {
            initializeRequest()
        }
        setUpHiddenFields()
        addTapRecognizer()
    }

    func setUpHiddenFields() {
        CircleSlider.isHidden = true
        CircleSlider.isEnabled = false
        DescriptionText.isHidden = true
        DescriptionText.layer.cornerRadius = 5.0
        DescriptionText.clipsToBounds = true
        DatePicker.backgroundColor = .white
        DatePicker.clipsToBounds = true
        DatePicker.layer.cornerRadius = 5.0
        DatePicker.locale = NSLocale(localeIdentifier: "en_US") as Locale
        DatePicker.isHidden = true
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
        if (gestureRecognizer.state != .ended || ConfirmOutlet.titleLabel?.text == "Select Timeframe") {return}
        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)

        for annotation in mapView.annotations {
            self.mapView.deselectAnnotation(annotation, animated: false)
        }

        ConfirmOutlet.setTitle("Select Timeframe", for: .normal)
        DescriptionText.text = "Select Radius"
        DescriptionText.isHidden = false

        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: touchMapCoordinate, span: span)
        mapView.setRegion(region, animated: true)

        let annotation = MKPointAnnotation()
        annotation.coordinate = touchMapCoordinate
        mapView.addAnnotation(annotation)
        recentAnnotation = annotation

        let circle = MKCircle(center: touchMapCoordinate, radius: CLLocationDistance(CircleSlider.value * 200.0 + 50.0))
        mapView.addOverlay(circle)
        recentCircle = circle

        CircleSlider.isHidden = false
        CircleSlider.isEnabled = true

        currentPoint = MeetingPoint(latitude: touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude, requestId: currentRequest!.requestId)
    }

    @IBAction func CircleSlide(_ sender: Any) {
        if (recentCircle != nil) {
            mapView.removeOverlay(recentCircle!)
            recentCircle = MKCircle(center: recentCircle!.coordinate, radius: CLLocationDistance((CircleSlider.value * 200.0) + 50.0))
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

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation.isEqual(mapView.userLocation)) {return nil}
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        annotationView.canShowCallout = true
        annotationView.pinTintColor = .purple

        //hacky but it works :P
        let tapRecognizer = UITapGestureRecognizer(target: self, action: nil)
        tapRecognizer.delegate = self
        annotationView.addGestureRecognizer(tapRecognizer)

        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(deleteMarker(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.delegate = self
        annotationView.addGestureRecognizer(doubleTapRecognizer)

        return annotationView
    }

    @objc func deleteMarker(_ gestureRecognizer: UIGestureRecognizer) {
        //delete the tapped marker
    }

    func initializeRequest() {
        currentRequest = CoffeeRequest()
        currentRequest!.requesterId = defaults.object(forKey: "userId") as! String
        currentRequest!.helperId = defaults.object(forKey: "userId") as! String //hacky but whatever
        currentRequest!.status = "Searching for Helper"
        currentRequest!.price = "0.00"
    }

    @IBOutlet weak var ConfirmOutlet: UIButton!
    @IBAction func ConfirmButton(_ sender: Any) { //god this is awful
        if (ConfirmOutlet.titleLabel?.text == "Select Timeframe") {
            ConfirmOutlet.setTitle("Select End Time", for: .normal)
            DescriptionText.text = "Select Start Time"
            CircleSlider.isEnabled = false
            CircleSlider.isHidden = true
            mapView.isUserInteractionEnabled = false
            DatePicker.isHidden = false
        } else if (ConfirmOutlet.titleLabel?.text == "Select End Time") {
            currentStartDate = DatePicker.date
            DatePicker.setDate(DatePicker.date.addingTimeInterval(TimeInterval(3600.0)), animated: true)
            DescriptionText.text = "Select End Time"
            ConfirmOutlet.setTitle("Add Point", for: .normal)
        } else if (ConfirmOutlet.titleLabel?.text == "Add Point") {
            if (DatePicker.date <= currentStartDate!) {return}
            currentPoint?.startTime = LocationUpdate.dateToString(d: currentStartDate!)
            currentPoint?.endTime = LocationUpdate.dateToString(d: DatePicker.date)
            recentAnnotation?.title = "\(currentPoint?.startTime ?? "00:00") -"
            recentAnnotation?.subtitle = currentPoint?.endTime
            zoomToUser()
            ConfirmOutlet.setTitle("Confirm", for: .normal)
            DescriptionText.isHidden = true
            mapView.isUserInteractionEnabled = true
            DatePicker.isHidden = true
            meetingPoints.append(currentPoint!)
            recentCircle = nil
            currentPoint = nil
        } else if (ConfirmOutlet.titleLabel?.text == "Confirm") {
            if (meetingPoints.count == 0) {
                let alert = UIAlertController(title: "No meeting points selected.", message: "You must select at least one potential location.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                let nextPage: RequestConfirmationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RequestConfirmationViewController") as! RequestConfirmationViewController
                nextPage.currentRequest = currentRequest
                nextPage.meetingPoints = meetingPoints
                self.present(nextPage, animated: true, completion: nil)
            }
        }
    }

    @IBAction func CancelButton(_ sender: Any) {
        if (DescriptionText.isHidden) {
            backToMain(currentScreen: self)
        } else {
            if (recentAnnotation != nil) {mapView.removeAnnotation(recentAnnotation!)}
            if (recentCircle != nil) {mapView.removeOverlay(recentCircle!)}
            zoomToUser()
            ConfirmOutlet.setTitle("Confirm", for: .normal)
            recentCircle = nil
            DescriptionText.isHidden = true
            mapView.isUserInteractionEnabled = true
            DatePicker.isHidden = true
            currentPoint = nil
            CircleSlider.isEnabled = false
            CircleSlider.isHidden = true
        }
    }
}
