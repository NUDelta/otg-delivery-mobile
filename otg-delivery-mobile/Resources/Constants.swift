import Foundation
import CoreLocation

let defaults = UserDefaults.standard

struct Constants {
    static let apiUrl: String = "http://otg-delivery.herokuapp.com/"
    //static let apiUrl: String = "http://localhost:8080/"
    //static let apiUrl: String = "http://10.105.237.143:8080/" //run ifconfig to update this before running

    static let researcherNumber: String = "7324563380"
}

/*
 To switch from dev to production:
 .otgDev <-> .B
 .entitlements
 apiUrl in Constants.swift
 build settings->"code signing"
 */
