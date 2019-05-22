import UIKit
import MapKit

class AcceptConfirmationViewController: UIViewController {
    @IBOutlet weak var InfoView: UIView!
    @IBOutlet weak var ItemLabel: UILabel!
    @IBOutlet weak var PickupLabel: UILabel!
    @IBOutlet weak var RequesterLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!

    var request: CoffeeRequest? = nil
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        ItemLabel.text = request?.item
        PickupLabel.text = request?.pickupLocation
        RequesterLabel.text = request?.requester?.username
    }

    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            setUpmapView()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func setUpmapView() {
        mapView.showsUserLocation = true
        zoomToUser()
    }

    func zoomToUser() {
        let userLocation = (locationManager.location?.coordinate)!
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: userLocation, span: span)
        mapView.setRegion(region, animated: true)
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
