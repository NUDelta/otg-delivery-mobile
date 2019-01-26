//
//  Location.swift
//  otg-delivery-mobile
//
//  Created by Maggie Lou on 1/14/19.
//  Copyright © 2019 Sam Naser. All rights reserved.
//

import Foundation

struct Location : Codable {
    private static let apiUrl: String = Constants.apiUrl + "locations"
    
    
    enum CodingKeys : String, CodingKey {
        case id = "_id"
        case name
    }
    
    let id: String
    let name: String
}

extension Location {

    static func getAll(completionHandler: @escaping ([Location]) -> Void) {
        let url = URL(string: "\(Location.apiUrl)")
        let session: URLSession = URLSession.shared
        let requestURL = URLRequest(url: url!)
        
        let task = session.dataTask(with: requestURL){ data, response, error in
            print("LOCATION MODEL: Getting all locations")
            guard let data = data else {
                return
            }
            
            var locations: [Location] = []
            let httpResponse = response as? HTTPURLResponse
            
            if(httpResponse?.statusCode != 400){
                do {
                    let decoder = JSONDecoder()
                    locations = try decoder.decode([Location].self, from: data)
                } catch {
                    print("LOCATION: error trying to convert data to JSON...")
                    print(error)
                }
            }
            completionHandler(locations)
        }
        
        task.resume()
    }
    
    static func camelCaseToWords(camelCaseString: String) -> String {
        var newString: String = ""
        
        for eachCharacter in camelCaseString {
            if (eachCharacter >= "A" && eachCharacter <= "Z") == true {
                newString.append(" ")
            }
            newString.append(eachCharacter)
        }
        
        // Remove added space at beginning
        newString.remove(at: newString.startIndex)
        
        return newString
    }
}
