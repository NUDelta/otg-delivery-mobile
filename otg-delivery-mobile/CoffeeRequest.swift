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
    //API Location
    private static let apiUrl: String = "https://otg-delivery-backend.herokuapp.com/requests"
    //private static let apiUrl: String = "http://localhost:8080/requests"
    
    // Used to map JSON responses and their properties to properties of our struct
    enum CodingKeys : String, CodingKey {
        case requester
        case orderDescription
        case endTime
        case requestId = "_id"
        case status
        case deliveryLocation
        case deliveryLocationDetails
        case helper
    }
    
    //all fields that go into a request
    let requester: String
    let orderDescription: String
    let status: String
    let deliveryLocation: String
    let deliveryLocationDetails: String
    let helper: String?
    let endTime: String?
    let requestId: String?
}

// Encode and decode CoffeeRequest cobjects

extension CoffeeRequest {
    
    //Method that grabs an unfilled CoffeeRequest from server and parses into object
    static func getUnfilledCoffeeRequest(completionHandler: @escaping (CoffeeRequest?) -> Void) {
        
        let session: URLSession = URLSession.shared
        let url = URL(string: CoffeeRequest.apiUrl)
        let requestURL = URLRequest(url: url!)
        
        let task = session.dataTask(with: requestURL){ data, response, error in
            
            print("COFFEE REQUEST: request data received!")
    
            var coffeeRequest: CoffeeRequest?
            let httpResponse = response as? HTTPURLResponse
            print(httpResponse?.statusCode)
            
            if(httpResponse?.statusCode != 400){
                do {
                    let decoder = JSONDecoder()
                    coffeeRequest = try decoder.decode(CoffeeRequest.self, from: data!)
                } catch {
                    print("COFFEE REQUEST: error trying to convert data to JSON...")
                    print(error)
                }
            }
            completionHandler(coffeeRequest)
        }
        
        task.resume()
        
    }
    
    //Method that takes an existing CoffeeRequest, serializes it, and sends it to server
    static func postCoffeeRequest(coffeeRequest: CoffeeRequest) {
        print("HERE")

        var components = URLComponents(string: "")
        components?.queryItems = [
            URLQueryItem(name: "requester", value: coffeeRequest.requester),
            URLQueryItem(name: "orderDescription", value: coffeeRequest.orderDescription),
            URLQueryItem(name: "endTime", value: coffeeRequest.endTime!),
            URLQueryItem(name: "status", value: coffeeRequest.status),
            URLQueryItem(name: "deliveryLocation", value: coffeeRequest.deliveryLocation),
            URLQueryItem(name: "deliveryLocationDetails", value: coffeeRequest.deliveryLocationDetails)
        ]

        let url = URL(string: CoffeeRequest.apiUrl)
        let session: URLSession = URLSession.shared
        var requestURL = URLRequest(url: url!)
            
        requestURL.httpMethod = "POST"
        requestURL.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        //These two lines are cancerous :: something severly wrong with my hack with URLComponents
        let httpBodyString: String? = components?.url?.absoluteString
        requestURL.httpBody = httpBodyString?.dropFirst(1).data(using: .utf8)
            
        let task = session.dataTask(with: requestURL){ data, response, error in
            print("COFFEE REQUEST: Data post successful.")
        }
            
        task.resume()
        
    }
    
    //Method that takes an ID and changes the status of the request
    //Method that grabs a CoffeeRequest from server and parses into object
    static func updateStatusCoffeeRequestForID(requestId: String, status: String, completionHandler: @escaping () -> Void) {
        
        let session: URLSession = URLSession.shared
        let url = URL(string: CoffeeRequest.apiUrl + "/status/" + requestId)
        var requestURL = URLRequest(url: url!)
        
        requestURL.httpMethod = "POST"
        requestURL.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        var components = URLComponents(string: "")
        components?.queryItems = [URLQueryItem(name: "status", value: status)]
        let httpBodyString: String? = components?.url?.absoluteString
        requestURL.httpBody = httpBodyString?.dropFirst(1).data(using: .utf8)

        let task = session.dataTask(with: requestURL){ data, response, error in
            print("COFFEE REQUEST: Accepted request.")
            completionHandler()
            
        }
        
        task.resume()
        
    }
    
    // Method that takes an ID and updates the request's
    // order description and endTime in the database
    static func acceptRequest(requestId id: String, completionHandler: @escaping () -> Void) {

        //Get username
        let defaults = UserDefaults.standard
        guard let helperId = defaults.object(forKey: "userId") as? String else {
            print("Helper ID not in defaults")
            return
        }
        
        
        //Define session
        let session: URLSession = URLSession.shared
        let url = URL(string: (CoffeeRequest.apiUrl + "/accept/\(helperId)"))
        var requestURL = URLRequest(url: url!)
        
        requestURL.httpMethod = "POST"
        requestURL.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        var components = URLComponents(string: "")
        components?.queryItems = [URLQueryItem(name: "id", value: id)]
        let httpBodyString: String? = components?.url?.absoluteString
        requestURL.httpBody = httpBodyString?.dropFirst(1).data(using: .utf8)
        
        let task = session.dataTask(with: requestURL){ data, response, error in
            print("COFFEE REQUEST: Update request.")
            completionHandler()
        }
        
        task.resume()
    }
    
    // Grabs the current user's most recent request from the server, and parses into object
    static func getMyRequest(completionHandler: @escaping ([CoffeeRequest]) -> Void) {
        // Get current user's username for api route
        let defaults = UserDefaults.standard
        
        guard let userId = defaults.object(forKey: "userId") as? String else {
            return
        }
        
        let session: URLSession = URLSession.shared
        let url = URL(string: (CoffeeRequest.apiUrl + "/userid/\(userId)"))
        let requestURL = URLRequest(url: url!)
        
        let task = session.dataTask(with: requestURL){ data, response, error in
            guard let data = data else {
                return
            }
            print("COFFEE REQUEST: Getting current user's requests")
            
            var coffeeRequests: [CoffeeRequest] = []
            let httpResponse = response as? HTTPURLResponse
            
            if(httpResponse?.statusCode != 400){
                do {
                    let decoder = JSONDecoder()
                    coffeeRequests = try decoder.decode([CoffeeRequest].self, from: data)
                } catch {
                    print("COFFEE REQUEST: error trying to convert data to JSON...")
                    print(error)
                }
            }
            completionHandler(coffeeRequests)
        }
        
        task.resume()
        
    }
    

    // Grabs the current user's most recent request from the server, and parses into object
    static func getMyAcceptedRequests(completionHandler: @escaping ([CoffeeRequest]) -> Void) {
        // Get current user's username for api route
        let defaults = UserDefaults.standard
        guard let userId = defaults.object(forKey: "userId") as? String else {
            return
        }
        
        let session: URLSession = URLSession.shared
        let url = URL(string: (CoffeeRequest.apiUrl + "/accept/\(userId)"))
        let requestURL = URLRequest(url: url!)
        
        
        let task = session.dataTask(with: requestURL){ data, response, error in
            guard let data = data else {
                return
            }
            print("COFFEE REQUEST: Getting current user's tasks")
            
            var itemRequests: [CoffeeRequest] = []
            let httpResponse = response as? HTTPURLResponse
            
            if(httpResponse?.statusCode != 400){
                do {
                    let decoder = JSONDecoder()
                    itemRequests = try decoder.decode([CoffeeRequest].self, from: data)
                } catch {
                    print("COFFEE REQUEST: error trying to convert data to JSON...")
                    print(error)
                }
            }
            completionHandler(itemRequests)
        }
        
        task.resume()
        
    }
    
    
    // Method that takes an ID and updates the request's
    // order description and endTime in the database
    static func updateRequest(with_id id: String, to_order order: String, completionHandler: @escaping () -> Void) {
        print("In update request ")
        let session: URLSession = URLSession.shared
        let url = URL(string: (CoffeeRequest.apiUrl + "/update/\(id)"))
        var requestURL = URLRequest(url: url!)
        
        requestURL.httpMethod = "POST"
        requestURL.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        var components = URLComponents(string: "")
        components?.queryItems = [URLQueryItem(name: "order", value: order)]
        let httpBodyString: String? = components?.url?.absoluteString
        requestURL.httpBody = httpBodyString?.dropFirst(1).data(using: .utf8)
        
        let task = session.dataTask(with: requestURL){ data, response, error in
            print("COFFEE REQUEST: Update request.")
            completionHandler()
        }
        
        task.resume()
    }
  
    // Method that takes an ID and deletes the request from the database
    static func deleteRequest(with_id id: String) {
        let session: URLSession = URLSession.shared
        let url = URL(string: "http://localhost:8080/requests/id/\(id)")
        //let url = URL(string: CoffeeRequest.apiUrl + "/\(id)")
        var requestURL = URLRequest(url: url!)
        
        requestURL.httpMethod = "DELETE"
        
        let task = session.dataTask(with: requestURL){ data, response, error in
            print("COFFEE REQUEST: Delete request \(id).")
        }
        
        task.resume()
    }
    
    // Method that takes an ID and returns the request from the database
    static func getRequest(with_id id: String, completionHandler: @escaping (CoffeeRequest?) -> Void) {
        let session: URLSession = URLSession.shared
        let url = URL(string: "http://localhost:8080/requests/id/\(id)")
        //let url = URL(string: CoffeeRequest.apiUrl + "/\(id)")
        var requestURL = URLRequest(url: url!)
        requestURL.httpMethod = "GET"
        
        let task = session.dataTask(with: requestURL){ data, response, error in
            if let data = data {
                print("COFFEE REQUEST: Get request \(id).")
                
                var coffeeRequest: CoffeeRequest?
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse?.statusCode)
                
                if(httpResponse?.statusCode != 400){
                    do {
                        let decoder = JSONDecoder()
                        coffeeRequest = try decoder.decode(CoffeeRequest.self, from: data)
                    } catch {
                        print("COFFEE REQUEST: error trying to convert data to JSON...")
                        print(error)
                    }
                }
                completionHandler(coffeeRequest)
            }
        }
        
        task.resume()
    }
}
