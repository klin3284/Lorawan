//
//  LocationManager.swift
//  Wancer
//
//  Created by Kenny Lin on 4/6/24.
//

import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocationCoordinate2D?
    
    static var shared = LocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        requestLocation()
    }

    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location.coordinate
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error getting location: \(error.localizedDescription)")
    }
}

extension CLLocationCoordinate2D {
    var formattedCoordinate: String {
        let latitude = self.latitude
        let longitude = self.longitude
        
        let latitudeDegrees = Int(latitude)
        let latitudeMinutes = Int((latitude - Double(latitudeDegrees)) * 60)
        let latitudeSeconds = Int((latitude - Double(latitudeDegrees) - Double(latitudeMinutes) / 60) * 3600)
        let latitudeCardinalDirection = latitude >= 0 ? "N" : "S"
        
        let longitudeDegrees = Int(longitude)
        let longitudeMinutes = Int((longitude - Double(longitudeDegrees)) * 60)
        let longitudeSeconds = Int((longitude - Double(longitudeDegrees) - Double(longitudeMinutes) / 60) * 3600)
        let longitudeCardinalDirection = longitude >= 0 ? "E" : "W"
        
        return "\(abs(latitudeDegrees))°\(latitudeMinutes)'\(latitudeSeconds)\" \(latitudeCardinalDirection), \(abs(longitudeDegrees))°\(longitudeMinutes)'\(longitudeSeconds)\" \(longitudeCardinalDirection)"
    }
}
