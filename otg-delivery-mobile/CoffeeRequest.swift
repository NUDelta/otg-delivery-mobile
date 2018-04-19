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
    //private static let apiUrl: String = "https://otg-delivery-backend.herokuapp.com/requests"
    private static let apiUrl: String = "http://localhost:8080/requests"
    
    //all fields that go into a request
    let requester: String
    let orderDescription: String
    let timeFrame: String?
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


        var components = URLComponents(string: "")
        components?.queryItems = [
            URLQueryItem(name: "requester", value: coffeeRequest.requester),
            URLQueryItem(name: "orderDescription", value: coffeeRequest.orderDescription),
            URLQueryItem(name: "timeFrame", value: coffeeRequest.timeFrame!),
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
    
    //Method that takes an ID and accepts the request
    //Method that grabs a CoffeeRequest from server and parses into object
    static func acceptCoffeeRequestForID(requestId: String, completionHandler: @escaping () -> Void) {
        
        let session: URLSession = URLSession.shared
        let url = URL(string: CoffeeRequest.apiUrl + "/accept/" + requestId)
        let requestURL = URLRequest(url: url!)
        
        let task = session.dataTask(with: requestURL){ data, response, error in
            
            print("COFFEE REQUEST: accepted request, handling server stuff.")
            completionHandler()
            
        }
        
        task.resume()
        
    }
    
    // Grabs the current user's most recent request from the server, and parses into object
    static func getMyRequest(completionHandler: @escaping ([CoffeeRequest]) -> Void) {
        // Get current user's username for api route
        let defaults = UserDefaults.standard
        let requesterName = (defaults.object(forKey: "username") as! String)
        
        let session: URLSession = URLSession.shared
        let url = URL(string: (CoffeeRequest.apiUrl + "/name/\(requesterName as! String)"))
        let requestURL = URLRequest(url: url!)
        
        let task = session.dataTask(with: requestURL){ data, response, error in
            print("COFFEE REQUEST: Getting current user's requests")
            
            var coffeeRequests: [CoffeeRequest] = []
            let httpResponse = response as? HTTPURLResponse
            
            if(httpResponse?.statusCode != 400){
                do {
                    let decoder = JSONDecoder()
                    coffeeRequests = try decoder.decode([CoffeeRequest].self, from: data!)
                } catch {
                    print("COFFEE REQUEST: error trying to convert data to JSON...")
                    print(error)
                }
            }
            completionHandler(coffeeRequests)
        }
        
        task.resume()
        
    }
    
    // Method that takes an ID and updates the request's
    // order description and timeframe in the database
    static func updateRequest(with_id id: String, to_order order: String) {
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
        }
        
        task.resume()
    }
  
    // Method that takes an ID and deletes the request from the database
    static func deleteRequest(with_id id: String) {
        let session: URLSession = URLSession.shared
        let url = URL(string: "http://localhost:8080/requests/\(id)")
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
        let url = URL(string: "http://localhost:8080/requests/\(id)")
        //let url = URL(string: CoffeeRequest.apiUrl + "/\(id)")
        var requestURL = URLRequest(url: url!)
        requestURL.httpMethod = "GET"
        
        let task = session.dataTask(with: requestURL){ data, response, error in
            print("COFFEE REQUEST: Get request \(id).")
            
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
}
