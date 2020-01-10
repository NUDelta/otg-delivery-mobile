import UIKit
import UserNotifications

class RequestConfirmationViewController: UIViewController, UIGestureRecognizerDelegate {
    var currentRequest: CoffeeRequest?
    var meetingPoints: [MeetingPoint] = []

    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var pickupLocationLabel: UILabel!
    @IBOutlet weak var TextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        if currentRequest == nil {
            let alert = UIAlertController(title: "We apologize. There is some error with your order.", message: "", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                backToMain(currentScreen: self)
            }))

            self.present(alert, animated: true, completion: nil)
        }

        itemLabel.text = currentRequest!.item
        pickupLocationLabel.text = currentRequest!.pickupLocation

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
    }

    @objc func endEditing() {
        view.endEditing(true)
    }

    @IBAction func cancelButton(_ sender: Any) {
        backToMain(currentScreen: self)
    }

    //submits order
    @IBAction func submitButton(_ sender: Any) {
        currentRequest?.status = "Searching for Helper"
        currentRequest?.description = TextField.text!

        var latestEndTime = Date()
        var validEndTimes = false
        for point in meetingPoints {
            if LocationUpdate.stringToDate(d: point.endTime) > latestEndTime {
                validEndTimes = true
                latestEndTime = LocationUpdate.stringToDate(d: point.endTime)
            }
        }

        if validEndTimes {
            CoffeeRequest.postCoffeeRequest(coffeeRequest: currentRequest!, completionHandler: { requestId in
                DispatchQueue.main.async {
                    for var point in self.meetingPoints {
                        point.requestId = requestId!
                        MeetingPoint.post(point: point, completionHandler: {_ in })
                    }
                    defaults.set(requestId!, forKey: "expireId")
                    let timer = Timer.init(fireAt: latestEndTime, interval: 0, target: self, selector: #selector(self.expire), userInfo: nil, repeats: false)
                    RunLoop.main.add(timer, forMode: .common)
                    // Get all users currently within the geofence of the given point
                    // Notify them
                }
            })
            performSegue(withIdentifier: "Submit", sender: self)
        } else {
            let alertController = UIAlertController(title: "Error", message: "You have no meeting points with end times after now.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }

        let requestsPlaced = defaults.object(forKey: "requestsPlaced") as! Int + 1
        defaults.set(requestsPlaced, forKey: "requestsPlaced")
    }

    //handles order expiry
    @objc func expire() {
        CoffeeRequest.updateStatus(requestId: defaults.string(forKey: "expireId")!, status: "Expired")
    }

    func setTimeProbabilities(request: CoffeeRequest) -> CoffeeRequest {
        let requestsPlaced = defaults.object(forKey: "requestsPlaced") as! Int

        if (requestsPlaced < 1) {
            request.timeProbabilities[1] = "30%"
            request.timeProbabilities[3] = "60%"
        } else {
            request.timeProbabilities[1] = "60%"
            request.timeProbabilities[3] = "30%"
        }

        return request
    }
}
