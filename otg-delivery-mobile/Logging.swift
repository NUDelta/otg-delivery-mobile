//
//  Logging.swift
//  otg-delivery-mobile
//
//  Created by Maggie Lou on 10/28/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import Foundation

struct Logging {
    private static let apiUrl: String = Constants.apiUrl + "logging"
    
    public enum eventTypes : String{
        case enterRegion = "Entered Pickup Region"
        case taskNotification = "Task Notification Sent"
        case helperIntendedLocation = "Intended Helper Destination"
        case taskAccepted = "Task Accepted"
        case requestMade = "Request Made"
        public static var eventTypeARR = [enterRegion,taskNotification,taskAccepted, requestMade]
    }
}

extension Logging {
    static func sendEvent(location: String, eventType: String, details: String){
        let defaults = UserDefaults.standard
        let requesterName = defaults.object(forKey: "username")
        
        var components = URLComponents(string: "")
        components?.queryItems = [
            URLQueryItem(name: "requester", value: requesterName as? String),
            URLQueryItem(name: "location", value: location),
            URLQueryItem(name: "eventType", value: eventType),
            URLQueryItem(name: "details", value: details),
        ]
        
        let url = URL(string: Logging.apiUrl)
        let session: URLSession = URLSession.shared
        var requestURL = URLRequest(url: url!)
        
        requestURL.httpMethod = "POST"
        requestURL.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        //These two lines are cancerous :: something severly wrong with my hack with URLComponents
        let httpBodyString: String? = components?.url?.absoluteString
        requestURL.httpBody = httpBodyString?.dropFirst(1).data(using: .utf8)
        
        let task = session.dataTask(with: requestURL){ data, response, error in
            print("LOGGING: Logged notification to server.")
        }
        
        task.resume()
    }
    
}
