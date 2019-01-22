//
//  LocationUpdate.swift
//  otg-delivery-mobile
//
//  Created by Maggie Lou on 1/21/19.
//  Copyright © 2019 Sam Naser. All rights reserved.
//

import Foundation

struct LocationUpdate : Codable {
    //private static let apiUrl: String = "https://otg-delivery.herokuapp.com/locupdates"
    private static let apiUrl: String = "http://localhost:8080/locupdates"
    
    
    enum CodingKeys : String, CodingKey {
        case latitude
        case longitude
        case speed
        case direction
        case uncertainty
        case timestamp
        case userId
    }
    
    let latitude: Double
    let longitude: Double
    let speed: Double
    let direction: Double
    let uncertainty: Double
    let timestamp: Date
    let userId: String
}

extension LocationUpdate {
    static func post(locUpdate: LocationUpdate) {
        var components = URLComponents(string: "")
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(locUpdate.latitude)),
            URLQueryItem(name: "longitude", value: String(locUpdate.longitude)),
            URLQueryItem(name: "speed", value: String(locUpdate.speed)),
            URLQueryItem(name: "direction", value: String(locUpdate.direction)),
            URLQueryItem(name: "uncertainty", value: String(locUpdate.uncertainty)),
            URLQueryItem(name: "timestamp", value: dateToString(d: locUpdate.timestamp)),
        ]
        
        let url = URL(string: LocationUpdate.apiUrl)
        let session: URLSession = URLSession.shared
        var requestURL = URLRequest(url: url!)
        
        requestURL.httpMethod = "POST"
        requestURL.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        //These two lines are cancerous :: something severly wrong with my hack with URLComponents
        let httpBodyString: String? = components?.url?.absoluteString
        requestURL.httpBody = httpBodyString?.dropFirst(1).data(using: .utf8)
        
        let task = session.dataTask(with: requestURL){ data, response, error in
            let httpResponse = response as? HTTPURLResponse
            
            // Keep retrying if unsuccessful
            //print(httpResponse?.statusCode)
            if(httpResponse?.statusCode != 200){
                print("Retry")
                self.post(locUpdate: locUpdate)
            }
        }
        
        task.resume()
    }
    
    static func dateToString(d: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let s = formatter.string(from: d)
        return s
    }
}
