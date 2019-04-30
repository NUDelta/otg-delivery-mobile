//
//  RequestManager.swift
//  otg-delivery-mobile
//
//  Created by Sam Naser on 2/25/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import Foundation

enum OrderActionType {
    case Order
    case Edit
}

//Define the original data members
//Codable allows for simple JSON serialization/ deserialization
class CoffeeRequest : Codable {
    private static let apiUrl: String = Constants.apiUrl + "requests"

    // Used to map JSON responses and their properties to properties of our struct
    enum CodingKeys : String, CodingKey {
        case requestId = "_id"
        case requester
        //case orderStartTime
        //case orderEndTime
        case item
        case status
        case deliveryLocationOptions
        case deliveryLocation
        case diffHelperRequesterArrivalTime
        case helperTextTime
        case requesterTextRespondTime
        case timeProbabilities
        case planningNotes
        case pickupLocation
    }

    // Instance variables of the object in Swift
    var requestId: String
    var requesterId: String
    var requester: User? = nil
    //var orderStartTime: String
    //var orderEndTime: String
    var item: String
    var status: String
    var deliveryLocationOptions: [String]
    var pickupLocation: String

    // Will be set later
    var deliveryLocation = ""
    var diffHelperRequesterArrivalTime = ""
    var helperTextTime = ""
    var requesterTextRespondTime = ""
    var planningNotes = ""
    var timeProbabilities = ["5%", "0%", "5%", "0%"]

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode data from JSON
        requester = try container.decode(User.self, forKey: .requester)
        //orderStartTime = try container.decode(String.self, forKey: .orderStartTime)
        //orderEndTime = try container.decode(String.self, forKey: .orderEndTime)
        item = try container.decode(String.self, forKey: .item)
        status = try container.decode(String.self, forKey: .status)
        deliveryLocation = try container.decode(String.self, forKey: .deliveryLocation)
        pickupLocation = try container.decode(String.self, forKey: .pickupLocation)

        let unparsedDeliveryLocation = try container.decodeIfPresent(String.self, forKey: .deliveryLocationOptions) ?? ""
        deliveryLocationOptions = CoffeeRequest.JSONStringToArray(json: unparsedDeliveryLocation)

        let unparsedTimeProbabilities = try container.decodeIfPresent(String.self, forKey: .timeProbabilities) ?? ""
        timeProbabilities = CoffeeRequest.JSONStringToArray(json: unparsedTimeProbabilities)

        requestId = try container.decode(String.self, forKey: .requestId)
        if (requester != nil) {
            requesterId = requester!.userId!
        } else {
            requesterId = "No ID"
        }
    }

    init(requester: String, orderStartTime: String, orderEndTime: String, status: String, item: String, deliveryLocationOptions: [String], pickupLocation: String) {
        self.requesterId = requester
        //self.orderStartTime = orderStartTime
        //self.orderEndTime = orderEndTime
        self.status = status
        self.item = item
        self.deliveryLocationOptions = deliveryLocationOptions
        self.requestId = ""
        self.pickupLocation = pickupLocation
    }
    
    init() {
        self.requesterId = ""
        //self.orderStartTime = ""
        //self.orderEndTime = ""
        self.item = ""
        self.status = ""
        self.deliveryLocationOptions = []
        self.deliveryLocation = ""
        self.requestId = ""
        self.pickupLocation = ""
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(requestId, forKey: .requestId)
        try container.encode(requesterId, forKey: .requester)
        //try container.encode(orderStartTime, forKey: .orderStartTime)
        //try container.encode(orderEndTime, forKey: .orderEndTime)
        try container.encode(status, forKey: .status)
        try container.encode(item, forKey: .item)
        try container.encode(deliveryLocationOptions, forKey: .deliveryLocationOptions)
        try container.encode(pickupLocation, forKey: .pickupLocation)
    }
}
extension CoffeeRequest {
    //Method that takes an existing CoffeeRequest, serializes it, and sends it to server
    static func postCoffeeRequest(coffeeRequest: CoffeeRequest) {
        Logging.sendEvent(location: CoffeeRequest.arrayToJson(arr: coffeeRequest.deliveryLocationOptions), eventType: Logging.eventTypes.requestMade.rawValue, details: "")
        var components = URLComponents(string: "")
        components?.queryItems = [
            URLQueryItem(name: "requester", value: coffeeRequest.requesterId),
            //URLQueryItem(name: "orderStartTime", value: coffeeRequest.orderStartTime),
            //URLQueryItem(name: "orderEndTime", value: coffeeRequest.orderEndTime),
            URLQueryItem(name: "item", value: coffeeRequest.item),
            URLQueryItem(name: "status", value: coffeeRequest.status),
            URLQueryItem(name: "deliveryLocation", value: coffeeRequest.deliveryLocation),
            URLQueryItem(name: "deliveryLocationOptions", value: CoffeeRequest.arrayToJson(arr: coffeeRequest.deliveryLocationOptions)),
            URLQueryItem(name: "timeProbabilities", value: CoffeeRequest.arrayToJson(arr: coffeeRequest.timeProbabilities)),
            URLQueryItem(name: "pickupLocation", value: coffeeRequest.pickupLocation)
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
    static func updateStatus(requestId: String, status: String) {
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
        }

        task.resume()
    }
//
//    static func updateRequest(with_id id: String, withRequest coffeeRequest: CoffeeRequest, completionHandler: @escaping () -> Void) {
//        print("In update request ")
//        let session: URLSession = URLSession.shared
//        let url = URL(string: (CoffeeRequest.apiUrl + "/\(id)"))
//        var requestURL = URLRequest(url: url!)
//
//        requestURL.httpMethod = "PATCH"
//        requestURL.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//
//        var components = URLComponents(string: "")
//        components?.queryItems = [
//            URLQueryItem(name: "requester", value: coffeeRequest.requesterId),
//            URLQueryItem(name: "orderDescription", value: coffeeRequest.itemId),
//            URLQueryItem(name: "endTime", value: coffeeRequest.endTime!),
//            URLQueryItem(name: "deliveryLocation", value: CoffeeRequest.arrayToJson(arr: coffeeRequest.deliveryLocation)),
//            URLQueryItem(name: "deliveryLocationDetails", value: coffeeRequest.deliveryLocationDetails)
//        ]
//
//        //These two lines are cancerous :: something severly wrong with my hack with URLComponents
//        let httpBodyString: String? = components?.url?.absoluteString
//        requestURL.httpBody = httpBodyString?.dropFirst(1).data(using: .utf8)
//
//        let task = session.dataTask(with: requestURL){ data, response, error in
//            print("COFFEE REQUEST: Data post successful.")
//        }
//
//        task.resume()
//    }


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

//    static func getRequest(with_id id: String, completionHandler: @escaping (CoffeeRequest?) -> Void) {
//        let session: URLSession = URLSession.shared
//        let url = URL(string: CoffeeRequest.apiUrl + "/\(id)")
//        var requestURL = URLRequest(url: url!)
//        requestURL.httpMethod = "GET"
//
//        let task = session.dataTask(with: requestURL){ data, response, error in
//            if let data = data {
//                print("COFFEE REQUEST: Get request \(id).")
//
//                var coffeeRequest: CoffeeRequest?
//                let httpResponse = response as? HTTPURLResponse
//
//                if(httpResponse?.statusCode != 400){
//                    do {
//                        let decoder = JSONDecoder()
//                        coffeeRequest = try decoder.decode(CoffeeRequest.self, from: data)
//                    } catch {
//                        print("COFFEE REQUEST.get: error trying to convert data to JSON...")
//                        print(error)
//                    }
//                }
//                completionHandler(coffeeRequest)
//            }
//        }
//
//        task.resume()
//    }
//
    static func getAllOpen(completionHandler: @escaping ([CoffeeRequest]) -> Void) {
        let defaults = UserDefaults.standard
        guard let userId = defaults.object(forKey: "userId") as? String else {
            print("User ID not in defaults")
            return
        }

        let session: URLSession = URLSession.shared
        let url = URL(string: "\(CoffeeRequest.apiUrl)?&excluding=\(userId)")
        //let url = URL(string: "\(CoffeeRequest.apiUrl)?status=Pending?&excluding=\(userId)")
        var requestURL = URLRequest(url: url!)
        requestURL.httpMethod = "GET"

        let task = session.dataTask(with: requestURL){ data, response, error in
            if let data = data {
                print("COFFEE REQUEST: Get all open requests.")

                var coffeeRequests: [CoffeeRequest] = []
                let httpResponse = response as? HTTPURLResponse

                if(httpResponse?.statusCode != 400) {
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
        let formatter = DateFormatter()
        let dateAsDate = stringToDate(s: dateAsString)

        // Set desired date format
        formatter.dateFormat = "h:mm a"
        formatter.timeZone = NSTimeZone.local
        let formattedDate = formatter.string(from: dateAsDate)
        return formattedDate
    }

    static func stringToDate(s: String) -> Date {
        //Remove milliseconds for parsing ease
        var parsedDateString = s.components(separatedBy: ".")[0]
        if parsedDateString.last! == "Z" {
            parsedDateString = String(parsedDateString.dropLast())
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let date = dateFormatter.date(from: parsedDateString)
        return date!
    }

    static func dateToString(d: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let s = dateFormatter.string(from: d)
        return s
    }

    static func arrayToJson(arr: [String]) -> String {
        guard let jsonObject = try? JSONSerialization.data(withJSONObject: arr, options: []) else {
            return ""
        }
        let jsonString = String(data: jsonObject, encoding: String.Encoding.utf8)
        return jsonString ?? ""
    }
    
    static func JSONStringToArray(json: String) -> [String] {
        // Remove brackets, quotes, extra characters
        var parsedJSON = json
        parsedJSON = parsedJSON.replacingOccurrences(of: "[", with: "")
        parsedJSON = parsedJSON.replacingOccurrences(of: "\"", with: "")
        parsedJSON = parsedJSON.replacingOccurrences(of: "]", with: "")

        let separatedJSONArr = parsedJSON.components(separatedBy: ",")
        return separatedJSONArr
    }
    
    static func prettyParseArray(arr: [String]) -> String {
        var arrString = arr.joined(separator:", ")
        arrString = arrString.replacingOccurrences(of: "]", with: "")
        arrString = arrString.replacingOccurrences(of: "[", with: "")
        arrString = arrString.replacingOccurrences(of: "\"", with: "")
        return arrString
    }

    static func generateTimeframeString(startTime: String, timeframeMins: Int) -> String {
        let start = stringToDate(s: startTime)
        let end = addMinToDate(date: start, numMin: timeframeMins)
        
        let timeframe = parseTime(dateAsString: dateToString(d: start)) + " - " + parseTime(dateAsString: dateToString(d: end))
        return timeframe
    }

    static func addMinToDate(date: Date, numMin: Int) -> Date {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.timeZone = NSTimeZone.local

        return calendar.date(byAdding: .minute, value: numMin, to: date)!
    }
}
