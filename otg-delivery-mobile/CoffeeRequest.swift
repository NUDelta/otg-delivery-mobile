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
class CoffeeRequest : Codable{
    //API Location
    private static let apiUrl: String = "https://otg-delivery.herokuapp.com/requests"
    //private static let apiUrl: String = "http://localhost:8080/requests" // if TIC TCP Conn fail error, update IP address to that of computer running the server - system preferences/network/wifi

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

    // Instance variables of the object in Swift
    var requester: User? = nil
    var item: Item? = nil
    var status: String
    var deliveryLocation: String
    var deliveryLocationDetails: String
    var helper: String?
    var endTime: String?
    var requestId: String?
    
    // For creating new objects
    var requesterId: String = ""
    var itemId: String = ""
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode data from JSON
        requester = try container.decode(User.self, forKey: .requester)
        item = try container.decode(Item.self, forKey: .orderDescription)
        status = try container.decode(String.self, forKey: .status)
        deliveryLocation = try container.decodeIfPresent(String.self, forKey: .deliveryLocation) ?? ""
        deliveryLocationDetails = try container.decodeIfPresent(String.self, forKey: .deliveryLocationDetails) ?? ""
        helper = try container.decodeIfPresent(String.self, forKey: .helper) ?? ""
        endTime = try container.decode(String.self, forKey: .endTime)
        requestId = try container.decode(String.self, forKey: .requestId)
        
        // Populate id fields
        requesterId = requester?.userId ?? "No requester ID"
        itemId = item?.id ?? "No item ID"
        
    }
    
    init(requester: String, itemId: String, status: String, deliveryLocation: String, deliveryLocationDetails: String, endTime: String) {
        self.requesterId = requester
        self.itemId = itemId
        self.status = status
        self.deliveryLocation = deliveryLocation
        self.deliveryLocationDetails = deliveryLocationDetails
        self.endTime = endTime
        self.requestId = ""
        self.helper = ""
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(requesterId, forKey: .requester)
        try container.encode(itemId, forKey: .orderDescription)
        try container.encode(status, forKey: .status)
        try container.encode(deliveryLocation, forKey: .deliveryLocation)
        try container.encode(deliveryLocationDetails, forKey: .deliveryLocationDetails)
        try container.encode(helper, forKey: .helper)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(requestId, forKey: .requestId)
    }
}
extension CoffeeRequest {

    static func getOpenTask(completionHandler: @escaping (CoffeeRequest?) -> Void) {

        //Get username
        let defaults = UserDefaults.standard
        guard let requesterId = defaults.object(forKey: "userId") as? String else {
            print("Helper ID not in defaults")
            return
        }

        let session: URLSession = URLSession.shared
        let url = URL(string: CoffeeRequest.apiUrl + "/task/\(requesterId)")
        let requestURL = URLRequest(url: url!)

        let task = session.dataTask(with: requestURL){ data, response, error in
            guard let data = data else {
                return
            }

            print("COFFEE REQUEST: request data received!")

            var coffeeRequest: CoffeeRequest?
            let httpResponse = response as? HTTPURLResponse

            if(httpResponse?.statusCode != 400){
                do {
                    let decoder = JSONDecoder()
                    coffeeRequest = try decoder.decode(CoffeeRequest.self, from: data)
                } catch {
                    print("COFFEE REQUEST.getOpenTask: error trying to convert data to JSON...")
                    print(error)
                }
            }
            completionHandler(coffeeRequest)
        }

        task.resume()

    }

    //Method that takes an existing CoffeeRequest, serializes it, and sends it to server
    static func postCoffeeRequest(coffeeRequest: CoffeeRequest) {
        Logging.sendEvent(location: coffeeRequest.deliveryLocation, eventType: Logging.eventTypes.requestMade.rawValue, details: "")
        
        var components = URLComponents(string: "")
        components?.queryItems = [
            URLQueryItem(name: "requester", value: coffeeRequest.requesterId),
            URLQueryItem(name: "orderDescription", value: coffeeRequest.itemId),
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
    static func updateStatus(requestId: String, status: String, completionHandler: @escaping () -> Void) {

        let session: URLSession = URLSession.shared
        let url = URL(string: (CoffeeRequest.apiUrl + "/\(requestId)/status"))
        var requestURL = URLRequest(url: url!)

        requestURL.httpMethod = "PATCH"
        requestURL.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        var components = URLComponents(string: "")
        components?.queryItems = [URLQueryItem(name: "status", value: status)]
        let httpBodyString: String? = components?.url?.absoluteString
        requestURL.httpBody = httpBodyString?.dropFirst(1).data(using: .utf8)

        let task = session.dataTask(with: requestURL){ data, response, error in
            print("COFFEE REQUEST: Update")
            completionHandler()

        }

        task.resume()

    }

    static func updateRequest(with_id id: String, withRequest coffeeRequest: CoffeeRequest, completionHandler: @escaping () -> Void) {
        print("In update request ")
        let session: URLSession = URLSession.shared
        let url = URL(string: (CoffeeRequest.apiUrl + "/\(id)"))
        var requestURL = URLRequest(url: url!)

        requestURL.httpMethod = "PATCH"
        requestURL.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        var components = URLComponents(string: "")
        components?.queryItems = [
            URLQueryItem(name: "requester", value: coffeeRequest.requesterId),
            URLQueryItem(name: "orderDescription", value: coffeeRequest.itemId),
            URLQueryItem(name: "endTime", value: coffeeRequest.endTime!),
            URLQueryItem(name: "deliveryLocation", value: coffeeRequest.deliveryLocation),
            URLQueryItem(name: "deliveryLocationDetails", value: coffeeRequest.deliveryLocationDetails)
        ]

        //These two lines are cancerous :: something severly wrong with my hack with URLComponents
        let httpBodyString: String? = components?.url?.absoluteString
        requestURL.httpBody = httpBodyString?.dropFirst(1).data(using: .utf8)

        let task = session.dataTask(with: requestURL){ data, response, error in
            print("COFFEE REQUEST: Data post successful.")
        }

        task.resume()
    }


    // Method that takes an ID and deletes the request from the database
    static func deleteRequest(with_id id: String) {
        print("Deleting request")
        let session: URLSession = URLSession.shared
        let url = URL(string: CoffeeRequest.apiUrl + "/\(id)")
        var requestURL = URLRequest(url: url!)

        requestURL.httpMethod = "DELETE"

        let task = session.dataTask(with: requestURL){ data, response, error in
            print("COFFEE REQUEST: Delete request \(id).")
        }

        task.resume()
    }

    static func getRequest(with_id id: String, completionHandler: @escaping (CoffeeRequest?) -> Void) {
        let session: URLSession = URLSession.shared
        let url = URL(string: CoffeeRequest.apiUrl + "/\(id)")
        var requestURL = URLRequest(url: url!)
        requestURL.httpMethod = "GET"

        let task = session.dataTask(with: requestURL){ data, response, error in
            if let data = data {
                print("COFFEE REQUEST: Get request \(id).")

                var coffeeRequest: CoffeeRequest?
                let httpResponse = response as? HTTPURLResponse

                if(httpResponse?.statusCode != 400){
                    do {
                        let decoder = JSONDecoder()
                        coffeeRequest = try decoder.decode(CoffeeRequest.self, from: data)
                    } catch {
                        print("COFFEE REQUEST.get: error trying to convert data to JSON...")
                        print(error)
                    }
                }
                completionHandler(coffeeRequest)
            }
        }

        task.resume()
    }
    
    static func getAllOpen(completionHandler: @escaping ([CoffeeRequest]) -> Void) {
        let defaults = UserDefaults.standard
        guard let userId = defaults.object(forKey: "userId") as? String else {
            print("User ID not in defaults")
            return
        }
        
        let session: URLSession = URLSession.shared
        let url = URL(string: "\(CoffeeRequest.apiUrl)?status=Pending?&excluding=\(userId)")
        var requestURL = URLRequest(url: url!)
        requestURL.httpMethod = "GET"
        
        let task = session.dataTask(with: requestURL){ data, response, error in
            if let data = data {
                print("COFFEE REQUEST: Get all open requests.")
                
                var coffeeRequests: [CoffeeRequest] = []
                let httpResponse = response as? HTTPURLResponse
                
                if(httpResponse?.statusCode != 400){
                    do {
                        let decoder = JSONDecoder()
                        coffeeRequests = try decoder.decode([CoffeeRequest].self, from: data)
                    } catch {
                        print("COFFEE REQUEST.getAllOpen: error trying to convert data to JSON...")
                        print(error)
                    }
                }
                
                completionHandler(coffeeRequests)
            }
        }
        
        task.resume()
    }

    static func parseTime(dateAsString: String) -> String {
        // Strip end of date string
        var dateAsStringParsed = dateAsString.components(separatedBy: ".")[0]

        // Parse input to date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        let dateAsDate = formatter.date(from: dateAsStringParsed)

        // Set desired date format
        formatter.dateFormat = "h:mm a"
        formatter.timeZone = NSTimeZone.local
        let formattedDate = formatter.string(from: dateAsDate!)
        return formattedDate
    }
}
