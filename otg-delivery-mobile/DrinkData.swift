//
//  DrinkData.swift
//  otg-delivery-mobile
//
//  Created by Sam Naser on 4/4/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import Foundation

enum DrinkSize: String {
    case Small
    case Medium
    case Large
    
    func asString() -> String {
        return self.rawValue
    }
}

struct Drink {
    let name: String
    let prices: [(DrinkSize, Double)]
    
    func priceRangeString() -> String {
        
        //First price
        var resultString = String.init(format: "$%.2f", prices[0].1)
        
        if prices.count > 0 {
            resultString += String.init(format: "-%.2f", prices[prices.count-1].1)
        }
        
        return resultString;
    }
    
}

let drinkData = [
    Drink(name: "Americano", prices: [(.Small, 2.50), (.Large, 4.75)]),
    Drink(name: "Cappuccino", prices: [(.Small, 3.95), (.Large, 4.85)]),
    Drink(name: "Latte", prices: [(.Small, 3.50), (.Large, 4.00)]),
    Drink(name: "Mocha", prices: [(.Small, 3.75), (.Large, 4.40)]),
    Drink(name: "White Mocha", prices: [(.Small, 3.75), (.Large, 4.40)]),
    Drink(name: "White Mocha", prices: [(.Small, 3.75), (.Medium, 5.00), (DrinkSize.Large, 4.40)])

]
