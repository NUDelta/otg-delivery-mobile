import UIKit
import MessageUI
import MapKit

class AcceptedViewController: UIViewController, MFMessageComposeViewControllerDelegate, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var HelperDropdown: UIButton!
    @IBOutlet weak var HelperFiller: UIView!
    @IBOutlet weak var ContactLabel: UIButton!
    @IBOutlet weak var ChangeETALabel: UIButton!
    @IBOutlet weak var CancelAcceptanceLabel: UIButton!
    @IBOutlet weak var ETAView: UIView!
    @IBOutlet weak var ETAChanger: UIDatePicker!

    let requestId = defaults.string(forKey: "ActiveRequestId")!
    var request: CoffeeRequest?
    var meetingPoint: MeetingPoint?
    let locationManager = CLLocationManager()
    var otherId: String?
    var status: String?
    var meetingPointAnnotation: MKPointAnnotation?
    var timer: Timer?
    var helperVisible: Bool = false {
        didSet {
            HelperDropdown.isHidden = !helperVisible
            HelperFiller.isHidden = !helperVisible
        }
    }
    var buttonsVisible: Bool = false {
        didSet {
            ChangeETALabel.isHidden = !buttonsVisible
            CancelAcceptanceLabel.isHidden = !buttonsVisible
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

        ChangeETALabel.layer.borderColor = UIColor.black.cgColor
        ChangeETALabel.layer.borderWidth = 0.25
        CancelAcceptanceLabel.layer.borderColor = UIColor.black.cgColor
        CancelAcceptanceLabel.layer.borderWidth = 0.25

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
                DispatchQueue.main.async {
                    self.meetingPoint = point
                    self.addMeetingPoint()
                }
            })
        }
    }

    func addMeetingPoint() {
        if (meetingPoint == nil) {return}
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: meetingPoint!.latitude, longitude: meetingPoint!.longitude)
        annotation.title = ("ETA: \(extractTime(date: request!.eta))")
        if status == "Requester" {
            annotation.subtitle = (meetingPoint?.description == "") ? "No Description" : meetingPoint?.description
        } else if status == "Helper" {
            annotation.subtitle = (request?.description == "") ? "No Description" : request!.description
        } else {
            annotation.subtitle = ""
        }
        self.reloadAnnotations(newAnnotation: annotation)
        meetingPointAnnotation = annotation
        self.zoomToUser()
    }

    @objc func addOtherUserLocation() {
        LocationUpdate.getRecent(withId: otherId!, completionHandler: {location in
            DispatchQueue.main.async {
                if (location != nil) {
                    let helperAnnotation = MKPointAnnotation()
                    helperAnnotation.coordinate = CLLocationCoordinate2D(latitude: location!.latitude, longitude: location!.longitude)
                    helperAnnotation.title = (self.status == "Requester") ? "Requester" : "Helper"
                    self.reloadAnnotations(newAnnotation: helperAnnotation)
                    self.zoomToUser()
                }
                if self.timer == nil {
                    self.timer = Timer(timeInterval: 5.0, target: self, selector: #selector(self.addOtherUserLocation), userInfo: nil, repeats: true)
                }
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
                mapView.selectAnnotation(annotation, animated: true)
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

    @IBAction func HelperDropDown(_ sender: Any) {
        buttonsVisible = !buttonsVisible
    }

    @IBAction func ChangeETA(_ sender: Any) {
        buttonsVisible = false
        ETAView.isHidden = false
        HelperDropdown.isEnabled = false
        mapView.isScrollEnabled = false
        ETAChanger.minimumDate = Date()
        ETAChanger.maximumDate = LocationUpdate.stringToDate(d: meetingPoint!.endTime)
        ETAChanger.date = LocationUpdate.stringToDate(d: request!.eta)
    }

    @IBAction func SetETA(_ sender: Any) {
        let stringDate = LocationUpdate.dateToString(d: ETAChanger!.date)
        let stringTime = extractTime(date: stringDate)
        if (stringDate != request!.eta) {
            request?.eta = stringDate
            CoffeeRequest.updateETA(requestId: request!.requestId, eta: request!.eta)
            if (meetingPointAnnotation != nil) {
                meetingPointAnnotation!.title = stringTime
            }
            User.sendNotification(deviceId: (request?.requester!.deviceId)!, message: "Your helper has updated their ETA to \(stringTime). Please be ready at the meeting point with payment.")
        }
        HelperDropdown.isEnabled = true
        ETAView.isHidden = true
        mapView.isScrollEnabled = true
    }

    @IBAction func CancelAcceptance(_ sender: Any) {
        let alert = UIAlertController(title: "Cancel Acceptance.", message: "Are you sure you want to cancel your acceptance? You will need to pay for any items you have picked up already.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default) {_ in self.cancel()})
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func cancel() {
        CoffeeRequest.updateStatus(requestId: requestId, status: "Pending")
        CoffeeRequest.removeHelper(requestId: requestId)
        User.sendNotification(deviceId: request!.requester!.deviceId, message: "\(request!.helper!.username) has cancelled your order. Your placed request will be re-opened.")
        defaults.set("", forKey: "ActiveRequestId")
        //TODO: Show Feedback why they cancelled
        backToMain(currentScreen: self)
    }

    @IBAction func CompleteOrder(_ sender: Any) {
        CoffeeRequest.updateStatus(requestId: requestId, status: "Completed")
        defaults.set(true, forKey: "FeedbackActive")
        performSegue(withIdentifier: "GoToFeedback", sender: self)
    }

    @objc func deselectAnnotations(_ gestureRecognizer: UIGestureRecognizer) {
        for annotation in mapView.annotations {
            mapView.deselectAnnotation(annotation, animated: true)
        }
        buttonsVisible = false
        ETAView.isHidden = true
        HelperDropdown.isEnabled = true
        mapView.isScrollEnabled = true
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
}
