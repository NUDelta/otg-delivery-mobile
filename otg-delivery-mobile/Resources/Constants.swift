import Foundation
import CoreLocation

let defaults = UserDefaults.standard

struct Constants {
    //static let apiUrl: String = "http://otg-delivery.herokuapp.com/"
    //static let apiUrl: String = "http://localhost:8080/"
    static let apiUrl: String = "http://10.105.237.143:8080/" //run ifconfig to update this before running

    static let researcherNumber: String = "7324563380"
    static let researcherDeviceId: String = "E64BB4185E8B8D21143C371582367D9FB7D0EE770FCB453E632AE15B245E9071"
}

/*
 To switch from dev to production:
 .otgDev <-> .B
 .entitlements
 apiUrl in Constants.swift
 build settings->"code signing"
 */
