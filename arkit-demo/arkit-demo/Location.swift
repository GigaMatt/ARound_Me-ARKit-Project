//
//  Location.swift
//  arkit-demo
//
//  Created by Duc Dao on 1/20/18.
//  Copyright © 2018 Duc Dao. All rights reserved.
//

import Foundation

class Location {
    var name: String
    var latitude: Double
    var longitude: Double
    
    init() {
        self.name = ""
        self.latitude = 0
        self.longitude = 0
    }
    
    init(_ name: String, _ latitude: Double, _ longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func printValues() {
        print("Name: " + self.name)
        print("Latitude: " + String(format: "%f", self.latitude))
        print("Longitude: " + String(format: "%f", self.longitude))
    }
}
