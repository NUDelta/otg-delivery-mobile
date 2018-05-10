//
//  DrinkData.swift
//  otg-delivery-mobile
//
//  Created by Sam Naser on 4/4/18.
//  Copyright © 2018 Sam Naser. All rights reserved.
//

import Foundation

struct Item {
    let name: String
    let description: String
    let price: Double
    
    func getPriceString() -> String {
        return String.init(format: "$%.2f", self.price)
    }
}

let drinkData = [
    Item(name: "Chicken Tinga Burrito", description: "Chicken sauteed with cabbage, onion, and chipotle sauce.", price: 6.50),
    Item(name: "Yucca with Chimichuri Burrito", description: "Served with mashed Cuban beans and rice.", price: 6.50),
    Item(name: "Grilled Chicken Burrito", description: "Served with spicy rub and two-chili relish.", price: 6.50),
    Item(name: "Chochinita Pibil Burrito", description: "Pork cooked in fresh-squeezed orange and lime juice and achiote wrapped in plantain leaves.", price: 6.50),
    Item(name: "Sweet Potatoes Burrito", description: "Carrots, caulifower, and charred corn with guajillo sauce.", price: 6.50),
    Item(name: "Ground Beef Burrito", description: "Served with chili chipotle.", price: 6.50),
    Item(name: "Black Beans with Grilled Queso Burrito", description: "Pico de gallo and salso verde.", price: 6.50),
    Item(name: "Tofu Burrito", description: "Made from Tofu and served to steaming perfection.", price: 6.50),
    Item(name: "Caramelized Onions and Charred Poblano Burrito", description: "Red peppers with chihuahua cheese.", price: 6.50),
    Item(name: "Panko-Habanero Crusted Tilapia Burrito", description: "Served with pineapple mojo.", price: 6.50),
    Item(name: "Spicy Pork with Salsa Verde Burrito", description: "With salsa verde.", price: 6.50),
    Item(name: "Al Pastor Burrito", description: "Marinated pork.", price: 6.50),
    Item(name: "Carne Asada Burrito", description: "Spiced-rubbed skirt steak.", price:6.50)
]
