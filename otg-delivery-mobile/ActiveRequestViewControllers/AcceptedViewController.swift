import UIKit
import MessageUI
import MapKit

class AcceptedViewController: UIViewController, MFMessageComposeViewControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var HelperDropdown: UIButton!
    @IBOutlet weak var HelperFiller: UIView!
    @IBOutlet weak var ContactLabel: UIButton!
    
    let requestId = defaults.string(forKey: "ActiveRequestId")!
    var request: CoffeeRequest?
    var meetingPoint: MeetingPoint?
    let locationManager = CLLocationManager()
    var otherId: String?
    var status: String?
    var helperVisible: Bool = false {
        didSet {
            HelperDropdown.isHidden = !helperVisible
            HelperFiller.isHidden = !helperVisible
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        CoffeeRequest.getRequest(with_id: requestId, completionHandler: {coffeeRequest in
            DispatchQueue.main.async {
                self.request = coffeeRequest
                self.setOtherId()
                self.setUpMapView()
            }
        })
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        }
    }

    func setOtherId() {
        if (request?.requester?.userId! == defaults.string(forKey: "userId")) {
            otherId = request?.helper?.userId!
            status = "Requester"
            ContactLabel.setTitle("Contact Helper", for: .normal)
        } else {
            otherId = request?.requester?.userId!
            status = "Helper"
            ContactLabel.setTitle("Contact Requester", for: .normal)
            helperVisible = true

            //helper tools are cancel and change ETA
        }
    }

    func setUpMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.isUserInteractionEnabled = true
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false

        let tapRecognizer = UIGestureRecognizer(target: self, action: #selector(deselectAnnotations(_:)))
        tapRecognizer.delegate = self
        mapView.addGestureRecognizer(tapRecognizer)

        zoomToUser()
        retrievePoint()
        addOtherUserLocation()
    }

    func zoomToUser() {
        let userLocation = (locationManager.location?.coordinate)!
        let span = MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
        let region = MKCoordinateRegion(center: userLocation, span: span)
        mapView.setRegion(region, animated: false)
    }

    func retrievePoint() {
        if (request != nil) {
            MeetingPoint.getById(with_id: request!.meetingPoint, completionHandler: {point in
                self.meetingPoint = point
                self.addMeetingPoint()
            })
        }
    }

    func addMeetingPoint() {
        if (meetingPoint == nil) {return}
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: meetingPoint!.latitude, longitude: meetingPoint!.longitude)
        annotation.title = (meetingPoint?.description == "") ? "No Description" : meetingPoint?.description
        annotation.subtitle = (request?.eta)
        self.reloadAnnotations(newAnnotation: annotation)

        //make a loading screen?
    }

    func addOtherUserLocation() {
        LocationUpdate.getRecent(withId: otherId!, completionHandler: {location in
            if (location != nil) {
                let helperAnnotation = MKPointAnnotation()
                helperAnnotation.coordinate = CLLocationCoordinate2D(latitude: location!.latitude, longitude: location!.longitude)
                helperAnnotation.title = (self.status == "Requester") ? "Requester" : "Helper"
                self.reloadAnnotations(newAnnotation: helperAnnotation)
            }
        })
    }

    func reloadAnnotations(newAnnotation: MKPointAnnotation) {
        let removedAnnotations = mapView.annotations
        for annotation in mapView.annotations {
            if !(annotation is MKUserLocation) {
                mapView.removeAnnotation(annotation)
            }
        }
        mapView.addAnnotation(newAnnotation)
        for annotation in removedAnnotations {
            if !(annotation is MKUserLocation) {
                mapView.addAnnotation(annotation)
            }
        }
    }

    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            if view.annotation is MKUserLocation || view.annotation?.title == "Helper" || view.annotation?.title == "Requester" {
                view.canShowCallout = false
            } else {
                view.canShowCallout = true
            }
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation || annotation.title == "Helper" || annotation.title == "Requester") {return nil}
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        annotationView.pinTintColor = .purple
        return annotationView
    }

    @IBAction func ContactHelper(_ sender: Any) {
        let phoneNumber = request!.helper!.phoneNumber
        let messageVC = MFMessageComposeViewController()
        messageVC.body = ""
        messageVC.recipients = [phoneNumber]
        messageVC.messageComposeDelegate = self
        self.present(messageVC, animated: false, completion: nil)
    }

    @IBAction func CompleteOrder(_ sender: Any) {
        //handle pricing
        //move to feedback screens
    }

    @objc func deselectAnnotations(_ gestureRecognizer: UIGestureRecognizer) {
        for annotation in mapView.annotations {
            mapView.deselectAnnotation(annotation, animated: true)
        }
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }

/*
    @IBAction func CancelAcceptance(_ sender: Any) {
        CoffeeRequest.updateStatus(requestId: requestId, status: "Pending")
        CoffeeRequest.removeHelper(requestId: requestId)
        User.sendNotification(deviceId: request!.requester!.deviceId, message: "Your helper has cancelled your order.")
        defaults.set("", forKey: "ActiveRequestId")
        backToMain(currentScreen: self)
    }
 */
}
