//
//  DrinkData.swift
//  otg-delivery-mobile
//
//  Created by Sam Naser on 4/4/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import Foundation

struct Item : Codable {
//    private static let apiUrl: String = "https://otg-delivery-backend.herokuapp.com/items"
    private static let apiUrl: String = "http://10.0.0.157:8080/items"

    
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
        var requestURL = URLRequest(url: url!)
        
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
        var requestURL = URLRequest(url: url!)

        
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


//let drinkData = [
//    //Burritos
//    Item(name: "Chicken Tinga Burrito", description: "Chicken sauteed with cabbage, onion, and chipotle sauce.", price: 6.50),
//    Item(name: "Yucca with Chimichuri Burrito", description: "Served with mashed Cuban beans and rice.", price: 6.50),
//    Item(name: "Grilled Chicken Burrito", description: "Served with spicy rub and two-chili relish.", price: 6.50),
//    Item(name: "Chochinita Pibil Burrito", description: "Pork cooked in fresh-squeezed orange and lime juice and achiote wrapped in plantain leaves.", price: 6.50),
//    Item(name: "Sweet Potatoes Burrito", description: "Carrots, caulifower, and charred corn with guajillo sauce.", price: 6.50),
//    Item(name: "Ground Beef Burrito", description: "Served with chili chipotle.", price: 6.50),
//    Item(name: "Black Beans with Grilled Queso Burrito", description: "Pico de gallo and salso verde.", price: 6.50),
//    Item(name: "Tofu Burrito", description: "Made from Tofu and served to steaming perfection.", price: 6.50),
//    Item(name: "Caramelized Onions and Charred Poblano Burrito", description: "Red peppers with chihuahua cheese.", price: 6.50),
//    Item(name: "Panko-Habanero Crusted Tilapia Burrito", description: "Served with pineapple mojo.", price: 6.50),
//    Item(name: "Spicy Pork with Salsa Verde Burrito", description: "With salsa verde.", price: 6.50),
//    Item(name: "Al Pastor Burrito", description: "Marinated pork.", price: 6.50),
//    Item(name: "Carne Asada Burrito", description: "Spiced-rubbed skirt steak.", price:6.50),
//
//    //Tacos
//    Item(name: "Tofu Taco", description: "Taco with some tofu.", price: 3.00),
//    Item(name: "Yucca with Chimichurri Taco", description: "Topped with onions and cilantro.", price: 3.00),
//    Item(name: "Sweet Potatoes Taco", description: "With carrots, cauliflower and charred corn, guajillo sauce and cojita cheese. Topped with onions and cilantro.", price: 3.00),
//    Item(name: "Grilled Chicken Taco", description: "Served with spicy rub and two-chili relish and charred corn. Topped with onions and cilantro.", price: 3.00),
//    Item(name: "Cochinita Pibil Taco", description: "Pork cooked in orange and lime juice and achiote wrapped in plantain leaves. Topped with onions and cilantro.", price: 3.00),
//    Item(name: "Cochinita Pibil Taco", description: "Pork cooked in orange and lime juice and achiote wrapped in plantain leaves. Topped with onions and cilantro.", price: 3.00),
//    Item(name: "Chicken Tinga Taco", description: "Chicken sauteed with cabbage, onion, and chipotle sauce.", price: 3.00),
//    Item(name: "Ground Beef Taco", description: "Served with chili chipotle. Topped with onions and cilantro.", price:3.00),
//    Item(name: "Black Beans with Queso Blanco Taco", description: "Black beans w/ grilled queso blanco, pico de gallo, and salsa verde. Topped with onions and cilantro.", price: 3.00),
//    Item(name: "Caramelized Onions and Charred Poblano Taco", description: "Red peppers with chihuahua cheese.", price: 3.00),
//    Item(name: "Planko Habanero Crusted Tilapia Taco", description: "Pineapple mojo. Topped with onions and cilantro.", price: 3.00),
//    Item(name: "Spicy Pork with Salsa Verde Taco", description: "With salsa verde. Topped with onions and cilantro.", price: 3.00),
//    Item(name: "Al Pastor Taco", description: "Marinated pork. Topped with onions and cilantro.", price: 3.00),
//    Item(name: "Carne Asada Taco", description: "Spiced-rubbed skirt steak. Topped with onions and cilantro.", price: 3.00)
//]
