import UIKit
import MapKit
import CoreLocation

class PotentialLocationViewController: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var DescriptionText: UILabel!

    var currentRequest: CoffeeRequest?
    let locationManager = CLLocationManager()
    var mapBottomConstraint: NSLayoutConstraint?
    var recentAnnotation: MKPointAnnotation?

    var currentPoint: MeetingPoint?
    var meetingPoints: [MeetingPoint] = []
    var endDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        if (currentRequest == nil) {
            backToMain(currentScreen: self)
        }
        setUpHiddenItems()
        addTapRecognizer()
    }

    override func viewDidAppear(_ animated: Bool) {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            setUpMapView()
        } else {
            locationManager.requestAlwaysAuthorization()
        }
    }

    // MARK: Handle taps

    func addTapRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(addMarker(_:)))
        tapRecognizer.delegate = self
        mapView.addGestureRecognizer(tapRecognizer)
    }

    // Handle taps on map
    @objc func addMarker(_ gestureRecognizer: UIGestureRecognizer) {

        // This line sets the meeting point maximum to 1 for current study
        // Remove this line to enable multiple meeting point placement
        if meetingPoints.count == 1 {
            return
        }

        if (gestureRecognizer.state != .ended) {return}
        let touchPoint = gestureRecognizer.location(in: mapView)
        let touchMapCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)

        ConfirmOutlet.setTitle("Confirm", for: .normal)
        DescriptionText.text = "Select Radius"

        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: touchMapCoordinate, span: span)
        mapView.setRegion(region, animated: true)

        let annotation = MKPointAnnotation()
        annotation.coordinate = touchMapCoordinate
        annotation.title = "title"
        mapView.addAnnotation(annotation)
        recentAnnotation = annotation

        currentPoint = MeetingPoint(latitude: touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude, radius: 50.0, requestId: currentRequest!.requestId)

        MeetingPoint.value(userId: defaults.string(forKey: "userId")!, meetingPointLatitude: currentPoint!.latitude, meetingPointLongitude: currentPoint!.longitude, meetingPointEndTime: LocationUpdate.dateToString(d: endDate!), completionHandler: showValue)

        mapView.isUserInteractionEnabled = false
        mapView.isScrollEnabled = false
    }

    func showValue(value: Double) {
        print(value)
    }

    // handles logic of bottom button -> different actions in different stages of placement
    @IBOutlet weak var ConfirmOutlet: UIButton!
    @IBAction func ConfirmButton(_ sender: Any) {
        if (ConfirmOutlet.titleLabel?.text == "Confirm") {
            currentPoint?.startTime = LocationUpdate.dateToString(d: Date())
            currentPoint?.endTime = LocationUpdate.dateToString(d: endDate!)
            meetingPoints.append(currentPoint!)

            let nextPage: RequestConfirmationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RequestConfirmationViewController") as! RequestConfirmationViewController
            nextPage.currentRequest = currentRequest
            nextPage.meetingPoints = meetingPoints
            self.present(nextPage, animated: true, completion: nil)
        }
    }

    // MARK: Cancellation methods

    // Handles order acceptance cancellation
    @IBAction func CancelButton(_ sender: Any) {
        let alert = UIAlertController(title: "Cancel Request.", message: "Are you sure you want to cancel your request?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default) {_ in backToMain(currentScreen: self)})
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func cancelSetting() {
        if (recentAnnotation != nil) {mapView.removeAnnotation(recentAnnotation!)}
        recentAnnotation = nil
        ConfirmOutlet.setTitle("Confirm", for: .normal)
        DescriptionText.text = "Place Radii"
        mapView.isUserInteractionEnabled = true
        currentPoint = nil
        mapView.isScrollEnabled = true
    }
}

// MARK: Map UI

extension PotentialLocationViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {return nil}
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        annotationView.pinTintColor = .purple
        return annotationView
    }

    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            view.canShowCallout = false
        }
    }

    func setUpMapView() {
        mapView.showsUserLocation = true
        zoomToUser()
    }

    //zooms map to user's location
    func zoomToUser() {
        if (locationManager.location != nil) {
            let userLocation = (locationManager.location?.coordinate)!
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: userLocation, span: span)
            mapView.setRegion(region, animated: false)
        }
    }

    // UI setup
    func setUpHiddenItems() {
        DescriptionText.layer.cornerRadius = 5.0
        DescriptionText.clipsToBounds = true
    }

}
