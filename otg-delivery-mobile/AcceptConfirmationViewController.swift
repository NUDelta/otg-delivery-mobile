import UIKit
import MapKit

class AcceptConfirmationViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var InfoView: UIView!
    @IBOutlet weak var ItemLabel: UILabel!
    @IBOutlet weak var PickupLabel: UILabel!
    @IBOutlet weak var RequesterLabel: UILabel!
    @IBOutlet weak var DetailsLabel: UILabel!
    @IBOutlet weak var ConfirmLabel: UIButton!
    @IBOutlet weak var DetailsView: UIView!
    @IBOutlet weak var ETAPicker: UIDatePicker!
    @IBOutlet weak var AdditionalDetails: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var CancelButton: UIButton!
    @IBOutlet weak var TimeLabel: UILabel!

    var request: CoffeeRequest? = nil
    let locationManager = CLLocationManager()
    var circles: [MKCircle: MeetingPoint] = [:]
    var chosenPoint: MeetingPoint?
    var referencePoint: MeetingPoint?
    var recentMarker: MKPointAnnotation?
    var confirmHidden: Bool = true {
        didSet {
            ConfirmLabel.isHidden = confirmHidden
            TimeLabel.isHidden = confirmHidden
        }
    }
    var activeCircle: MKCircleRenderer?

    override func viewDidLoad() {
        checkLocationAuthorizationStatus()
        setText()
        retrieveMeetingPoints()
    }

    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        }
        setUpMapView()
        zoomToUser()
    }

    func setUpMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.isUserInteractionEnabled = true
        view.sendSubviewToBack(DetailsView) //hacky
        view.sendSubviewToBack(CancelButton)
        view.sendSubviewToBack(mapView)
        ETAPicker.locale = NSLocale(localeIdentifier: "en_US") as Locale

        let circleRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleCircleTap(_:)))
        circleRecognizer.delegate = self
        mapView.addGestureRecognizer(circleRecognizer)

        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func handleCircleTap(_ gestureRecognizer: UIGestureRecognizer) {
        InfoView.isHidden = true
        let tappedPoint = gestureRecognizer.location(in: mapView)
        let tappedCoordinate = mapView.convert(tappedPoint, toCoordinateFrom: mapView)
        let mapPoint = MKMapPoint(tappedCoordinate)
        if (activeCircle != nil) {
            let viewPoint = activeCircle!.point(for: mapPoint)
            if activeCircle!.path.contains(viewPoint) {
                chosenPoint = MeetingPoint(latitude: tappedCoordinate.latitude, longitude: tappedCoordinate.longitude, radius: 0.0, requestId: request!.requestId)
                if (recentMarker != nil) {
                    mapView.removeAnnotation(recentMarker!)
                }
                addMarker(coordinate: tappedCoordinate)
            }
        } else {
            for (circle, point) in circles {
                let renderer = MKCircleRenderer(circle: circle)
                let viewPoint = renderer.point(for: mapPoint)
                if (renderer.path.contains(viewPoint)) {
                    zoomToPoint(point: CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude))
                    referencePoint = point
                    confirmHidden = false
                    mapView.isScrollEnabled = false
                    TimeLabel.text = "Requester in radius from \(extractTime(date: point.startTime)) - \(extractTime(date: point.endTime))"
                    activeCircle = renderer
                }
            }
        }
    }

    func addMarker(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        recentMarker = annotation
    }

    func zoomToPoint(point: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: point, span: span)
        mapView.setRegion(region, animated: true)
    }

    func zoomToUser() {
        let userLocation = (locationManager.location != nil) ? (locationManager.location?.coordinate)! : CLLocationCoordinate2D(latitude: 42.060271, longitude: -87.675804)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: userLocation, span: span)
        mapView.setRegion(region, animated: false)
    }

    func setText() {
        ItemLabel.text = request?.item
        PickupLabel.text = request?.pickupLocation
        RequesterLabel.text = request?.requester?.username
        DetailsLabel.text = request?.description
    }

    func retrieveMeetingPoints() {
        if (request == nil) {return}
        MeetingPoint.getByRequest(with_id: request!.requestId, completionHandler: { points in
            DispatchQueue.main.async {
                print(points)
                for point in points {
                    self.addPotentialPoint(point: point)
                }
            }
        })
    }

    func addPotentialPoint(point: MeetingPoint) {
        if (LocationUpdate.stringToDate(d: point.endTime) < Date()) {return}
        let pointCoordinate = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
        let circle = MKCircle(center: pointCoordinate, radius: point.radius)
        mapView.addOverlay(circle)

        circles[circle] = point
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation.isEqual(mapView.userLocation)) {return nil}
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        annotationView.canShowCallout = false
        annotationView.pinTintColor = .purple

        return annotationView
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

    @IBAction func ToggleInfoView(_ sender: Any) {
        InfoView.isHidden = !InfoView.isHidden
    }

    @IBAction func AcceptOrder(_ sender: Any) {
        if (ConfirmLabel.title(for: .normal) == "Set Meeting Point") {
            if (recentMarker == nil) {
                let alert = UIAlertController(title: "No point selected.", message: "You must select a meeting point.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                mapView.isUserInteractionEnabled = false
                DetailsView.isHidden = false
                ETAPicker.minimumDate = Date(timeIntervalSinceNow: 0.0)
                ETAPicker.maximumDate = LocationUpdate.stringToDate(d: referencePoint!.endTime)
                ConfirmLabel.setTitle("Accept Order", for: .normal)
            }
        } else {
            let additionalDetails = AdditionalDetails.text! //this is to allow access to this US element from a non-main thread later
            CoffeeRequest.getRequest(with_id: request!.requestId, completionHandler: {request in
                if request?.item == "" { //seeing if errored
                    let alert = UIAlertController(title: "Error", message: "The specified request has been cancelled (or another error has occurred).", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Return to Main", style: .default) {_ in backToMain(currentScreen: self)})
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.saveMeetingPoint(description: additionalDetails, completionHandler: { meetingPoint in
                        DispatchQueue.main.async {
                            User.accept(requestId: self.request!.requestId, userId: defaults.string(forKey: "userId")!, meetingPointId: meetingPoint.id, eta: LocationUpdate.dateToString(d: self.ETAPicker.date))
                            User.sendNotification(deviceId: self.request!.requester!.deviceId, message: "\(defaults.string(forKey: "username")!) has accepted your order. Prepare to meet your helper at the designated meeting location.")
                            self.setUpGeofence(geofenceRegionCenter: CLLocationCoordinate2D(latitude: self.chosenPoint!.latitude, longitude: self.chosenPoint!.longitude), radius: 200.0, identifier: self.request!.requestId)
                            backToMain(currentScreen: self)
                        }
                    })
                }
            })
        }
    }

    func setUpGeofence(geofenceRegionCenter: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String) {
        let geofenceRegion = CLCircularRegion(center: geofenceRegionCenter,
                                              radius: radius,
                                              identifier: identifier)
        geofenceRegion.notifyOnEntry = true
        geofenceRegion.notifyOnExit = true

        locationManager.startMonitoring(for: geofenceRegion)
        defaults.set(request!.requester!.deviceId, forKey: "RequesterId")
    }

    func saveMeetingPoint(description: String, completionHandler: @escaping (MeetingPoint) -> Void) {
        chosenPoint?.description = description
        chosenPoint?.startTime = referencePoint!.startTime
        chosenPoint?.endTime = referencePoint!.endTime
        MeetingPoint.post(point: chosenPoint!, completionHandler: completionHandler)
    }

    @IBAction func Cancel(_ sender: Any) {
        if (activeCircle != nil) {
            cancelSettingPoint()
        } else {
            let alert = UIAlertController(title: "Cancel Acceptance.", message: "Are you sure you want to cancel your acceptance?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default) {_ in backToMain(currentScreen: self)})
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func cancelSettingPoint() {
        confirmHidden = true
        DetailsView.isHidden = true
        mapView.isUserInteractionEnabled = true
        mapView.isScrollEnabled = true
        referencePoint = nil
        chosenPoint = nil
        if (recentMarker != nil) {
            mapView.removeAnnotation(recentMarker!)
        }
        activeCircle = nil
    }
}
