//
//  Locations.swift
//  otg-delivery-mobile
//
//  Created by Cooper Barth on 4/17/19.
//  Copyright © 2019 Sam Naser. All rights reserved.
//

import Foundation
import CoreLocation

let pickupLocations: [(locationName: String, location: CLLocationCoordinate2D)] = [
    //        ("Norbucks", CLLocationCoordinate2D(latitude: 42.053343, longitude: -87.672956)),
    //        ("Sherbucks", CLLocationCoordinate2D(latitude: 42.04971, longitude: -87.682014)),
    //        ("Kresge Starbucks", CLLocationCoordinate2D(latitude: 42.051725, longitude: -87.675103)),
    //        ("Fran's", CLLocationCoordinate2D(latitude: 42.051717, longitude: -87.681063)),
    //        ("Coffee Lab", CLLocationCoordinate2D(latitude: 42.058518, longitude: -87.683645)),
    //        ("Kaffein", CLLocationCoordinate2D(latitude: 42.046968, longitude: -87.679088)),
    ("Lisa's", CLLocationCoordinate2D(latitude: 42.060271, longitude: -87.675804)),
    ("Noyes", CLLocationCoordinate2D(latitude: 42.058345, longitude: -87.683724)),
    ("Tech Express Sheridan", CLLocationCoordinate2D(latitude: 42.057816, longitude: -87.677123)), // On Sheridan
    ("Tech Express Mudd", CLLocationCoordinate2D(latitude: 42.057958, longitude: -87.674735)), // By Mudd
    ("Downtown Evanston", CLLocationCoordinate2D(latitude: 42.048555, longitude: -87.681854)),
]

let meetingPointLocations: [(locationName: String, location: CLLocationCoordinate2D)] = [
    ("Tech Lobby Sheridan", CLLocationCoordinate2D(latitude: 42.057816, longitude: -87.677123)), // On Sheridan
    ("Tech Lobby Mudd", CLLocationCoordinate2D(latitude: 42.057958, longitude: -87.674735)), // By Mudd
    ("Bridge between Tech and Mudd", CLLocationCoordinate2D(latitude: 42.057958, longitude: -87.674735)),
    ("Main Library Sign-In Desk", CLLocationCoordinate2D(latitude: 42.053166, longitude: -87.674774)),
    ("Kresge, By Entrance", CLLocationCoordinate2D(latitude: 42.051352, longitude: -87.675254)),
    ("SPAC, By Entrance", CLLocationCoordinate2D(latitude: 42.059135, longitude: -87.672755)),
    ("Norris, By Front Entrance", CLLocationCoordinate2D(latitude: 42.053328,  longitude: -87.673141)),
    ("Plex Lobby", CLLocationCoordinate2D(latitude: 42.053822, longitude: -87.678237)),
    ("Willard Lobby", CLLocationCoordinate2D(latitude: 42.051655,
                                             longitude:  -87.681316)),
]
