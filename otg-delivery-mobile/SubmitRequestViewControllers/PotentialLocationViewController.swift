import UIKit
import MapKit
import CoreLocation

class PotentialLocationViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var CircleSlider: UISlider!
    @IBOutlet weak var DescriptionText: UILabel!
    @IBOutlet weak var DatePicker: UIDatePicker!
    @IBOutlet weak var MarkerView: UIView!
    @IBOutlet weak var MarkerTimes: UILabel!

    var currentRequest: CoffeeRequest?
    let locationManager = CLLocationManager()
    var mapBottomConstraint: NSLayoutConstraint?
    var recentAnnotation: MKPointAnnotation?
    var recentCircle: MKCircle?
    var infoHidden: Bool = true {
        didSet {
            MarkerView.isHidden = infoHidden
        }
    }

    var currentPoint: MeetingPoint?
    var meetingPoints: [MeetingPoint] = []
    var currentStartDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        if (currentRequest == nil) {
            initializeRequest()
        }
        setUpHiddenItems()
        addTapRecognizer()
    }

    func setUpHiddenItems() {
        DescriptionText.layer.cornerRadius = 5.0
        DescriptionText.clipsToBounds = true
        DatePicker.backgroundColor = .white
        DatePicker.clipsToBounds = true
        DatePicker.layer.cornerRadius = 5.0
        DatePicker.locale = NSLocale(localeIdentifier: "en_US") as Locale
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
        if (locationManager.location != nil) {
            let userLocation = (locationManager.location?.coordinate)!
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: userLocation, span: span)
            mapView.setRegion(region, animated: false)
        }
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
        currentPoint = MeetingPoint(latitude: touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude, radius: 0.0, requestId: currentRequest!.requestId)

        mapView.isScrollEnabled = false
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

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        cancelSetting() //I hate MapKit
        let annotationCoordinate = view.annotation!.coordinate
        for point in meetingPoints {
            if (annotationCoordinate.latitude == point.latitude && annotationCoordinate.longitude == point.longitude) {
                MarkerTimes.text = "\(extractTime(date: point.startTime )) - \(extractTime(date: point.endTime))"
                mapView.isUserInteractionEnabled = false
                infoHidden = false
                recentAnnotation = view.annotation as? MKPointAnnotation
                return
            }
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation.isEqual(mapView.userLocation)) {return nil}
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        annotationView.canShowCallout = false
        annotationView.pinTintColor = .purple

        return annotationView
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
        if (ConfirmOutlet.titleLabel?.text == "Select Timeframe") {
            ConfirmOutlet.setTitle("Select End Time", for: .normal)
            DescriptionText.text = "Select Start Time"
            CircleSlider.isEnabled = false
            CircleSlider.isHidden = true
            mapView.isUserInteractionEnabled = false
            DatePicker.isHidden = false
            currentPoint?.radius = recentCircle!.radius
        } else if (ConfirmOutlet.titleLabel?.text == "Select End Time") {
            currentStartDate = DatePicker.date
            DatePicker.setDate(DatePicker.date.addingTimeInterval(TimeInterval(3600.0)), animated: true)
            DescriptionText.text = "Select End Time"
            ConfirmOutlet.setTitle("Add Point", for: .normal)
        } else if (ConfirmOutlet.titleLabel?.text == "Add Point") {
            if (DatePicker.date <= currentStartDate!) {return}
            currentPoint?.startTime = LocationUpdate.dateToString(d: currentStartDate!)
            currentPoint?.endTime = LocationUpdate.dateToString(d: DatePicker.date)
            zoomToUser()
            ConfirmOutlet.setTitle("Confirm", for: .normal)
            DescriptionText.isHidden = true
            mapView.isUserInteractionEnabled = true
            DatePicker.isHidden = true
            meetingPoints.append(currentPoint!)
            recentCircle = nil
            currentPoint = nil
            mapView.isScrollEnabled = true
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

    @IBAction func DeleteMarker(_ sender: Any) {
        infoHidden = true
        if (recentAnnotation != nil) {
            let index = mapView.annotations.firstIndex(where: {coordinateEqual(c1: $0.coordinate, c2: recentAnnotation!.coordinate)})
            meetingPoints.remove(at: index!)
            var pointCircle: MKOverlay?
            for circle in mapView.overlays {
                if (coordinateEqual(c1: circle.coordinate, c2: recentAnnotation!.coordinate)) {
                    pointCircle = circle
                    break
                }
            }
            if (pointCircle != nil) {
                mapView.removeOverlay(pointCircle!)
            }
            mapView.removeAnnotation(recentAnnotation!)
            mapView.isUserInteractionEnabled = true
        }
    }

    func coordinateEqual(c1: CLLocationCoordinate2D, c2: CLLocationCoordinate2D) -> Bool {
        return c1.latitude == c2.latitude && c1.longitude == c2.longitude
    }

    @IBAction func CancelButton(_ sender: Any) {
        if (!infoHidden) {return}
        if (DescriptionText.isHidden) {
            if (meetingPoints.count > 0) {
                let alert = UIAlertController(title: "Cancel Request.", message: "Are you sure you want to cancel your request?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .default) {action in backToMain(currentScreen: self)})
                alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                backToMain(currentScreen: self)
            }
        } else {
            cancelSetting()
            zoomToUser()
        }
    }

    func cancelSetting() {
        if (recentAnnotation != nil) {mapView.removeAnnotation(recentAnnotation!)}
        if (recentCircle != nil) {mapView.removeOverlay(recentCircle!)}
        ConfirmOutlet.setTitle("Confirm", for: .normal)
        recentCircle = nil
        DescriptionText.isHidden = true
        mapView.isUserInteractionEnabled = true
        DatePicker.isHidden = true
        currentPoint = nil
        mapView.isScrollEnabled = true
        CircleSlider.isEnabled = false
        CircleSlider.isHidden = true
    }

    func extractTime(date: String) -> String {
        return date.components(separatedBy: " ")[1]
    }
}
