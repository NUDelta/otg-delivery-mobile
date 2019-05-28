import UIKit
import MessageUI

class AcceptedRequesterViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    let requestId = defaults.string(forKey: "ActiveRequestId")!
    var request: CoffeeRequest?

    override func viewDidLoad() {
        super.viewDidLoad()
        CoffeeRequest.getRequest(with_id: requestId, completionHandler: {coffeeRequest in
            DispatchQueue.main.async {
                self.request = coffeeRequest
            }
        })
    }

    @IBAction func ContactHelper(_ sender: Any) {
        let phoneNumber = request!.helper!.phoneNumber
        let messageVC = MFMessageComposeViewController()
        messageVC.body = ""
        messageVC.recipients = [phoneNumber]
        messageVC.messageComposeDelegate = self
        self.present(messageVC, animated: false, completion: nil)
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
}
