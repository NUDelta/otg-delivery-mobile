import CoreLocation

let pickupLocations: [(locationName: String, location: CLLocationCoordinate2D)] = [
    ("Norbucks", CLLocationCoordinate2D(latitude: 42.053343, longitude: -87.672956)),
    ("TechExpress", CLLocationCoordinate2D(latitude: 42.057958, longitude: -87.675335)),
    ("Lisa's", CLLocationCoordinate2D(latitude: 42.060271, longitude: -87.675804)),
    ("Garrett", CLLocationCoordinate2D(latitude: 42.055958, longitude: -87.675135)),
    ("Bergson", CLLocationCoordinate2D(latitude: 42.0532, longitude: -87.674635)),
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
    ("Willard Lobby", CLLocationCoordinate2D(latitude: 42.051655, longitude:  -87.681316)),
]
