//
//  LocationAddress.swift
//  AddressFinder
//
//  Created by Josh Kuehn on 12/4/17.
//  Copyright © 2017 Josh Kuehn. All rights reserved.
//

import Foundation
import CoreLocation

enum LocationError: Error {
    case unableToParse(String)
    case invalidPlacemark
}

struct LocationAddress {
    let placemark: CLPlacemark
    let name: String
    let city: String
    let state: String
    let postalCode: String
    let country: String
    
    init(placemark: CLPlacemark?) throws {
        guard let placemark = placemark else {
            throw LocationError.invalidPlacemark
        }
        self.placemark = placemark
        
        guard let name = placemark.name else {
            throw LocationError.unableToParse("Name")
        }
        self.name = name
        
        guard let city = placemark.locality else {
            throw LocationError.unableToParse("City")
        }
        self.city = city
        
        guard let state = placemark.administrativeArea else {
            throw LocationError.unableToParse("State")
        }
        self.state = state
        
        guard let postalCode = placemark.postalCode else {
            throw LocationError.unableToParse("Postal Code")
        }
        self.postalCode = postalCode
        
        guard let country = placemark.country else {
            throw LocationError.unableToParse("Country")
        }
        self.country = country
    }
    
    func addressString() -> String {
        return "\(name) \(city), \(state) \(postalCode)"
    }
}
