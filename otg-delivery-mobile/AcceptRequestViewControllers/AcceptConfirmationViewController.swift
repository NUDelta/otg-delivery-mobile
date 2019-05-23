import UIKit
import MapKit

class AcceptConfirmationViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var InfoView: UIView!
    @IBOutlet weak var ItemLabel: UILabel!
    @IBOutlet weak var PickupLabel: UILabel!
    @IBOutlet weak var RequesterLabel: UILabel!
    @IBOutlet weak var DetailsLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    var request: CoffeeRequest? = nil
    let locationManager = CLLocationManager()
    var circles: [MKCircle: MeetingPoint] = [:]

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

        let circleRecognizer = UITapGestureRecognizer(target: self, action: #selector(detectCircleTap(_:)))
        circleRecognizer.delegate = self
        mapView.addGestureRecognizer(circleRecognizer)
    }

    @objc func detectCircleTap(_ gestureRecognizer: UIGestureRecognizer) {
        let tappedPoint = gestureRecognizer.location(in: mapView)
        let tappedCoordinate = mapView.convert(tappedPoint, toCoordinateFrom: mapView)
        let mapPoint = MKMapPoint(tappedCoordinate)
        for (circle, point) in circles {
            let renderer = MKCircleRenderer(circle: circle)
            let viewPoint = renderer.point(for: mapPoint)
            if (renderer.path.contains(viewPoint)) {
                zoomToPoint(point: CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude))
            }
        }
    }

    func zoomToPoint(point: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: point, span: span)
        mapView.setRegion(region, animated: true)
    }

    func zoomToUser() {
        let userLocation = (locationManager.location?.coordinate)!
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
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
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
        annotation.title = "\(point.startTime) -"
        annotation.subtitle = point.endTime
        mapView.addAnnotation(annotation)

        let circle = MKCircle(center: annotation.coordinate, radius: point.radius)
        mapView.addOverlay(circle)

        circles[circle] = point
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation.isEqual(mapView.userLocation)) {return nil}
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        annotationView.canShowCallout = true
        annotationView.pinTintColor = .purple

        let tapRecognizer = UITapGestureRecognizer(target: self, action: nil)
        tapRecognizer.delegate = self
        annotationView.addGestureRecognizer(tapRecognizer)

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
        User.accept(requestId: request!.requestId, userId: defaults.string(forKey: "userId")!)
        User.sendNotification(deviceId: request!.requester!.deviceId, message: "\(defaults.string(forKey: "username")!) has accepted your order. Prepare to meet your helper at the designated meeting location.")
        //add meeting point selection logic
        backToMain(currentScreen: self)
    }

    /*@IBAction func Cancel(_ sender: Any) {
        backToMain(currentScreen: self)
    }*/
}
