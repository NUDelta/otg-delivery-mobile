//
//  DrinkData.swift
//  otg-delivery-mobile
//
//  Created by Sam Naser on 4/4/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import Foundation

struct Item : Codable {
    //private static let apiUrl: String = "https://otg-delivery.herokuapp.com/items"
    private static let apiUrl: String = "http://localhost:8080/items"

    
    enum CodingKeys : String, CodingKey {
        case id = "_id"
        case name
        case description
        case price
        case location
    }
    
    let id: String
    let name: String
    let description: String
    let price: Double
    let location: String
}

extension Item {
    func getPriceString() -> String {
        return String.init(format: "$%.2f", self.price)
    }
    
    static func get(withId id: String, completionHandler: @escaping (Item?) -> Void) {
        print("Get item with id \(id)")
        
        let url = URL(string: "\(Item.apiUrl)/\(id)")
        let session: URLSession = URLSession.shared
        let requestURL = URLRequest(url: url!)
        
        let task = session.dataTask(with: requestURL){ data, response, error in
            guard let data = data else {
                return
            }
            
            print("ITEM: get with id \(id)")
            
            var item: Item?
            let httpResponse = response as? HTTPURLResponse
            
            if(httpResponse?.statusCode != 400){
                do {
                    let decoder = JSONDecoder()
                    item = try decoder.decode(Item.self, from: data)
                } catch {
                    print("ITEM.get: error trying to convert data to JSON...")
                    print(error)
                }
            }
            completionHandler(item!)
        }
        
        task.resume()
    }
    
    static func getAll(forLocation location: String, completionHandler: @escaping ([Item]) -> Void) {
        print("Get all items for location \(location)")
        var components = URLComponents(string: "")
        components?.queryItems = [
            URLQueryItem(name: "location", value: location)
        ]
        
        let url = URL(string: "\(Item.apiUrl)?location=\(location)")
        let session: URLSession = URLSession.shared
        let requestURL = URLRequest(url: url!)

        
        let task = session.dataTask(with: requestURL){ data, response, error in
            print("ITEM MODEL: Getting items for \(location)")
            guard let data = data else {
                return
            }
            
            var items: [Item] = []
            let httpResponse = response as? HTTPURLResponse
            
            if(httpResponse?.statusCode != 400){
                do {
                    let decoder = JSONDecoder()
                    items = try decoder.decode([Item].self, from: data)
                } catch {
                    print("ITEM: error trying to convert data to JSON...")
                    print(error)
                }
            }
            completionHandler(items)
        }
        
        task.resume()
    }
}
