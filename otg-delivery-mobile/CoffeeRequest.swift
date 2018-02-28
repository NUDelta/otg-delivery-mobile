//
//  RequestManager.swift
//  otg-delivery-mobile
//
//  Created by Sam Naser on 2/25/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import Foundation

//Define the original data members
//Codable allows for simple JSON serialization/ deserialization
struct CoffeeRequest : Codable{
    //all fields that go into a request
    let requester: String;
    let orderDescription: String;
}

// Encode and decode CoffeeRequest cobjects

extension CoffeeRequest {
    
    //Method that grabs a CoffeeRequest from server and parses into object
    static func getCoffeeRequest(completionHandler: @escaping (CoffeeRequest) -> Void) {
        
        let session: URLSession = URLSession.shared
        let requestEndpoint = "https://secure-wave-26416.herokuapp.com/api/requests"
        let url = URL(string: requestEndpoint)
        let requestURL = URLRequest(url: url!)
        
        let task = session.dataTask(with: requestURL){ data, response, error in
            
            do{
                print("COFFEE REQUEST: request data received!")
                
                var coffeeRequest: CoffeeRequest?
                let decoder = JSONDecoder()
                
                do {
                    coffeeRequest = try decoder.decode(CoffeeRequest.self, from: data!)
                    print(coffeeRequest)
                    completionHandler(coffeeRequest!)
                } catch {
                    print("COFFEE REQUEST: error trying to convert data to JSON...")
                    print(error)
                    completionHandler(coffeeRequest!)
                }
                
            }
            
        }
        
        task.resume()
        
    }
    
    //Method that takes an existing CoffeeRequest, serializes it, and sends it to server
    static func postCoffeeRequest(coffeeRequest: CoffeeRequest) {
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(coffeeRequest)
            let jsonString = String(data: jsonData, encoding: .utf8)
            print("COFFEE REQUEST: JSON Serialized String: " + jsonString!)
        }
        
        catch { print("Data could not be converted to JSON format.") }
    }
    
}
