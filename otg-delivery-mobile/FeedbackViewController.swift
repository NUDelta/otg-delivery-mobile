import UIKit

class FeedbackViewController: UIViewController, UIGestureRecognizerDelegate {
    let activeID = defaults.string(forKey: "ActiveRequestId")
    let userID = defaults.string(forKey: "userId")

    @IBOutlet weak var NextLocationField: UITextField!
    @IBOutlet weak var RatingLabel1: UILabel!
    @IBOutlet weak var Stepper1: UIStepper!
    @IBOutlet weak var RatingLabel2: UILabel!
    @IBOutlet weak var Stepper2: UIStepper!
    @IBOutlet weak var YesNoSegmented: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
    }

    @objc func endEditing() {
        view.endEditing(true)
    }

    @IBAction func Stepper1Changed(_ sender: Any) {
        RatingLabel1.text = String(Int(Stepper1.value))
    }

    @IBAction func Stepper2Changed(_ sender: Any) {
        RatingLabel2.text = String(Int(Stepper2.value))
    }

    @IBAction func SubmitFeedback(_ sender: Any) {
        let alert = UIAlertController(title: "Order Completion", message: "Has the request been completed successfully? (i.e. Item and money has been exchanged.)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default) {_ in self.endOrder()})
        self.present(alert, animated: true, completion: nil)
    }

    func endOrder() {
        let segmentOptions = ["Yes", "No"]
        let feedback = Feedback(userId: userID!,
                                requestId: activeID!,
                                nextLocation: NextLocationField.text!,
                                inconvenience: RatingLabel1.text!,
                                disruption: RatingLabel2.text!,
                                waiting: segmentOptions[YesNoSegmented.selectedSegmentIndex])
        Feedback.post(feedback: feedback)

        CoffeeRequest.getRequest(with_id: activeID!, completionHandler: {request in
            if request?.status == request?.requester?.userId || request?.status == request?.helper?.userId  {
                CoffeeRequest.updateStatus(requestId: request!.requestId, status: "Completed")
            } else {
                CoffeeRequest.updateStatus(requestId: request!.requestId, status: self.userID!)
            }
        })

        defaults.set("", forKey: "ActiveRequestId")
        performSegue(withIdentifier: "EndFeedback", sender: self)
    }
}
