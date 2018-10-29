//
//  UserModel.swift
//  otg-delivery-mobile
//
//  Created by Sam Naser on 5/2/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import Foundation

//
//  RequestManager.swift
//  otg-delivery-mobile
//
//  Created by Sam Naser on 2/25/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import Foundation

struct User : Codable{
    //API Location
    //private static let apiUrl: String = "https://otg-delivery-backend.herokuapp.com/users"
    private static let apiUrl: String = "http://localhost:8080/users"
    
    // Used to map JSON responses and their properties to properties of our struct
    enum CodingKeys : String, CodingKey {
        case userId = "_id"
        case deviceId
        case username
        case phoneNumber
    }
    
    //all fields that go into a request
    let userId: String?
    let deviceId: String
    let username: String
    let phoneNumber: String
}


//Define HTTP requests
extension User {
    
    //Method that takes an existing CoffeeRequest, serializes it, and sends it to server
    static func create(user: User, completionHandler: @escaping(User?) -> Void) {
        print("Creating User")
        
        var components = URLComponents(string: "")
        components?.queryItems = [
            URLQueryItem(name: "deviceId", value: user.deviceId),
            URLQueryItem(name: "username", value: user.username),
            URLQueryItem(name: "phoneNumber", value: user.phoneNumber),
        ]
        
        let url = URL(string: User.apiUrl)
        let session: URLSession = URLSession.shared
        var requestURL = URLRequest(url: url!)
        
        requestURL.httpMethod = "POST"
        requestURL.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        //These two lines are cancerous :: something severly wrong with my hack with URLComponents
        let httpBodyString: String? = components?.url?.absoluteString
        requestURL.httpBody = httpBodyString?.dropFirst(1).data(using: .utf8)
        
        let task = session.dataTask(with: requestURL){ data, response, error in

            guard let data = data else {
                return
            }
            print("USER DATA: user data returned.")
            
            var userData: User?
            let httpResponse = response as? HTTPURLResponse
            
            if(httpResponse?.statusCode != 400){
                do {
                    let decoder = JSONDecoder()
                    //print(String(data: data, encoding: String.Encoding.utf8) as! String)
                    userData = try decoder.decode(User.self, from: data)
                } catch {
                    print("USER MODEL: error trying to convert data to JSON...")
                    print(error)
                }
            }
            
            completionHandler(userData)
        
        }
        
        task.resume()
    }
    
    
    // Method that takes a user ID and grabs the user model
    static func get(with_id id: String, completionHandler: @escaping (User?) -> Void) {
        let session: URLSession = URLSession.shared
        let url = URL(string: "\(User.apiUrl)/\(id)")
        var requestURL = URLRequest(url: url!)
        requestURL.httpMethod = "GET"
        
        let task = session.dataTask(with: requestURL){ data, response, error in
            if let data = data {
                print("USER: Get user \(id).")
                
                var userModel: User?
                let httpResponse = response as? HTTPURLResponse
                
                if(httpResponse?.statusCode != 400){
                    do {
                        let decoder = JSONDecoder()
                        userModel = try decoder.decode(User.self, from: data)
                    } catch {
                        print("COFFEE REQUEST: error trying to convert data to JSON...")
                        print(error)
                    }
                }
                completionHandler(userModel)
            }
        }
        
        task.resume()
    }
    
    static func acceptRequest(requestId id: String, completionHandler: @escaping () -> Void) {
        
        //Get username
        let defaults = UserDefaults.standard
        guard let helperId = defaults.object(forKey: "userId") as? String else {
            print("Helper ID not in defaults")
            return
        }
        
        CoffeeRequest.getRequest(with_id: id, completionHandler: { (request) in
            guard let request = request else {
                print("USER MODEL.acceptRequest: No request returned.")
                
                return
            }
            Logging.sendEvent(location: request.deliveryLocation, eventType: Logging.eventTypes.taskAccepted.rawValue, details: "")
        })
        
        //Define session
        let session: URLSession = URLSession.shared
        let url = URL(string: ("\(User.apiUrl)/\(helperId)/accept/\(id)"))
        var requestURL = URLRequest(url: url!)
        
        requestURL.httpMethod = "PATCH"
        requestURL.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let components = URLComponents(string: "")
        let httpBodyString: String? = components?.url?.absoluteString
        requestURL.httpBody = httpBodyString?.dropFirst(1).data(using: .utf8)
        
        let task = session.dataTask(with: requestURL){ data, response, error in
            print("USER MODEL: Accept request \(id)")
            completionHandler()
        }
        
        task.resume()
    }
    
    static func getMyRequests(completionHandler: @escaping ([CoffeeRequest]) -> Void) {
        // Get current user's username for api route
        let defaults = UserDefaults.standard
        
        guard let userId = defaults.object(forKey: "userId") as? String else {
            return
        }
        
        let session: URLSession = URLSession.shared
        let url = URL(string: ("\(User.apiUrl)/\(userId)/requests"))
        let requestURL = URLRequest(url: url!)
        
        let task = session.dataTask(with: requestURL){ data, response, error in
            guard let data = data else {
                return
            }
            print("USER MODEL: Getting current user's requests")
            
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
    
    
    static func getMyTasks(completionHandler: @escaping ([CoffeeRequest]) -> Void) {
        // Get current user's username for api route
        let defaults = UserDefaults.standard
        guard let userId = defaults.object(forKey: "userId") as? String else {
            return
        }
        
        let session: URLSession = URLSession.shared
        let url = URL(string: ("\(User.apiUrl)/\(userId)/tasks"))
        let requestURL = URLRequest(url: url!)
        
        
        let task = session.dataTask(with: requestURL){ data, response, error in
            guard let data = data else {
                return
            }
            print("USER MODEL: Getting current user's tasks")
            
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
    
    static func removeHelperFromTask(withId taskId: String) {
        let defaults = UserDefaults.standard
        guard let userId = defaults.object(forKey: "userId") as? String else {
            return
        }
        
        let session: URLSession = URLSession.shared
        let url = URL(string: User.apiUrl + "/\(userId)/removeHelper/\(taskId)")
        var requestURL = URLRequest(url: url!)
        
        requestURL.httpMethod = "PATCH"
        
        let task = session.dataTask(with: requestURL){ data, response, error in
            if((error) != nil) {
                print("USER MODEL: Error removing helper from request \(taskId)")
                return
            }
            print("USER MODEL: Removed helper from request \(taskId).")
        }
        
        task.resume()
    }
}
