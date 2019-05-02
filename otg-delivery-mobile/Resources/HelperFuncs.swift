//
//  HelperFuncs.swift
//  otg-delivery-mobile
//
//  Created by Cooper Barth on 5/2/19.
//  Copyright © 2019 Sam Naser. All rights reserved.
//

import Foundation
import UIKit

func backToMain(currentScreen: UIViewController) {
    let mainPage: OrderViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainOrderViewController") as! OrderViewController
    currentScreen.present(mainPage, animated: true, completion: nil)
}
