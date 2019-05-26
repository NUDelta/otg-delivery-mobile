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

    var request: CoffeeRequest? = nil
    let locationManager = CLLocationManager()
    var circles: [MKCircle: MeetingPoint] = [:]
    var choosingPoint = false
    var chosenPoint: MeetingPoint?
    var referencePoint: MeetingPoint?
    var recentMarker: MKPointAnnotation?

    override func viewDidLoad() {
        checkLocationAuthorizationStatus()
        setText()
        retrieveMeetingPoints()
    }

    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            setUpMapView()
            zoomToUser()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func setUpMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.isUserInteractionEnabled = true
        view.sendSubviewToBack(DetailsView) //hack
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
        for (circle, point) in circles {
            let renderer = MKCircleRenderer(circle: circle)
            let viewPoint = renderer.point(for: mapPoint)
            if (renderer.path.contains(viewPoint)) {
                if (choosingPoint) {
                    chosenPoint = MeetingPoint(latitude: tappedCoordinate.latitude, longitude: tappedCoordinate.longitude, radius: 0.0, requestId: request!.requestId)
                    if (recentMarker != nil) {
                        mapView.removeAnnotation(recentMarker!)
                    }
                    addMarker(coordinate: tappedCoordinate)
                } else {
                    zoomToPoint(point: CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude))
                    referencePoint = point
                    choosingPoint = true
                    ConfirmLabel.isHidden = false
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
        let userLocation = (locationManager.location?.coordinate)!
        print(userLocation)
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
                for point in points {
                    self.addPotentialPoint(point: point)
                }
            }
        })
    }

    func addPotentialPoint(point: MeetingPoint) {
        let pointCoordinate = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
        let circle = MKCircle(center: pointCoordinate, radius: point.radius)
        mapView.addOverlay(circle)

        circles[circle] = point
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation.isEqual(mapView.userLocation)) {return nil}
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        annotationView.canShowCallout = true
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
            saveMeetingPoint(description: AdditionalDetails.text!, eta: LocationUpdate.dateToString(d: ETAPicker.date))
            User.accept(requestId: request!.requestId, userId: defaults.string(forKey: "userId")!)
            User.sendNotification(deviceId: request!.requester!.deviceId, message: "\(defaults.string(forKey: "username")!) has accepted your order. Prepare to meet your helper at the designated meeting location.")
            backToMain(currentScreen: self)
        }
    }

    func saveMeetingPoint(description: String, eta: String) {
        request?.meetingPoint = chosenPoint!.id
        request?.eta = eta
        chosenPoint?.description = description

        chosenPoint?.startTime = referencePoint!.startTime
        chosenPoint?.endTime = referencePoint!.endTime

        MeetingPoint.post(point: chosenPoint!)
    }

    @IBAction func Cancel(_ sender: Any) {
        if (choosingPoint) {
            cancelSettingPoint()
        } else {
            let alert = UIAlertController(title: "Cancel Acceptance.", message: "Are you sure you want to cancel your acceptance?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default) {action in backToMain(currentScreen: self)})
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func cancelSettingPoint() {
        choosingPoint = false
        ConfirmLabel.isHidden = true
        DetailsView.isHidden = true
        mapView.isUserInteractionEnabled = true
        referencePoint = nil
        chosenPoint = nil
        if (recentMarker != nil) {
            mapView.removeAnnotation(recentMarker!)
        }
    }
}
