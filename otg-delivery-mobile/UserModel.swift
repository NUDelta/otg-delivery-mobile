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

struct UserModel : Codable{
    //API Location
    private static let apiUrl: String = "https://otg-delivery-backend.herokuapp.com/users"
    //private static let apiUrl: String = "http://localhost:8080/users"
    
    // Used to map JSON responses and their properties to properties of our struct
    enum CodingKeys : String, CodingKey {
        case userId = "_id"
        case deviceId
        case username
    }
    
    //all fields that go into a request
    let userId: String?
    let deviceId: String
    let username: String
}


//Define HTTP requests
extension UserModel {
    
    //Method that takes an existing CoffeeRequest, serializes it, and sends it to server
    static func createUser(user: UserModel, completionHandler: @escaping(UserModel?) -> Void) {
        
        var components = URLComponents(string: "")
        components?.queryItems = [
            URLQueryItem(name: "deviceId", value: user.deviceId),
            URLQueryItem(name: "username", value: user.username)
        ]
        
        let url = URL(string: UserModel.apiUrl)
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
            
            var userData: UserModel?
            let httpResponse = response as? HTTPURLResponse
            
            if(httpResponse?.statusCode != 400){
                do {
                    let decoder = JSONDecoder()
                    print(String(data: data, encoding: String.Encoding.utf8) as! String)
                    userData = try decoder.decode(UserModel.self, from: data)
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
    static func getRequest(with_id id: String, completionHandler: @escaping (UserModel?) -> Void) {
        let session: URLSession = URLSession.shared
        let url = URL(string: "\(UserModel.apiUrl)?userId=\(id)")
        var requestURL = URLRequest(url: url!)
        requestURL.httpMethod = "GET"
        
        let task = session.dataTask(with: requestURL){ data, response, error in
            if let data = data {
                print("COFFEE REQUEST: Get request \(id).")
                
                var userModel: UserModel?
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse?.statusCode)
                
                if(httpResponse?.statusCode != 400){
                    do {
                        let decoder = JSONDecoder()
                        userModel = try decoder.decode(UserModel.self, from: data)
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
    
}
