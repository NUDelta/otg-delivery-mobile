import Foundation
import UIKit
import MapKit

func backToMain(currentScreen: UIViewController) {
    let mainPage: OrderViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainOrderViewController") as! OrderViewController
    currentScreen.present(mainPage, animated: true, completion: nil)
}

func coordinateEqual(c1: CLLocationCoordinate2D, c2: CLLocationCoordinate2D) -> Bool {
    return c1.latitude == c2.latitude && c1.longitude == c2.longitude
}

func extractTime(date: String) -> String {
    let time = date.components(separatedBy: " ")[1]
    let HHMMSS = time.components(separatedBy: ":")
    return "\(HHMMSS[0]):\(HHMMSS[1])"
}
