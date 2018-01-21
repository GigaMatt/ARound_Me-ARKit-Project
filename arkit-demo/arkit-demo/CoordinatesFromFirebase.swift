//
//  CordinatesFromFirebase.swift
//  arkit-demo
//
//  Created by Duc Dao on 1/20/18.
//  Copyright © 2018 Duc Dao. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import Firebase

class CoordinatesFromFirebase {
    let url: String = "https://sbhacksiv.firebaseio.com/buildings.json"
    let encoding = Alamofire.JSONEncoding.default
    
    func getLocation() -> Location {
        let location : Location = Location()
        
        // Get location information asynchronously
        getLocationFromFirebase() { json in
            if let json = json {
                location.name = json["campbellHall"]["name"].stringValue
                location.latitude = json["campbellHall"]["latitude"].doubleValue
                location.longitude = json["campbellHall"]["longitude"].doubleValue
                
                print("Name: " + location.name)
                print("Latitude: " + String(format: "%.2f", location.latitude))
                print("Longitude: " + String(format: "%.2f", location.longitude))
            }
        }
        
        return location
    }
    
    func getLocationFromFirebase(completionHandler: @escaping (JSON?) -> Void) {
        // Run a GET to retrieve JSON data from Firebase asynchronously
        Alamofire.request(self.url,
                          method: .get,
                          encoding: self.encoding).responseJSON { response in
            // Check for GET errors
            guard response.result.error == nil else {
                // Error getting data
                print("Error getting coordinate data from Firebase!")
                print(response.result.error!)
                
                return
            }
            
            // Check if JSON recieved is nil
            guard (response.result.value as? [String:Any]) != nil else {
                print ("Didn't get JSON response from Firebase!")
                print ("Error: \(response.result.error!)")
                
                return
            }
            
            print("JSON EXIST! :D")
                            
            var json = JSON(response.result.value!)
            let locationA : Location = Location()
            locationA.name = json["name"].stringValue
            locationA.latitude = json["latitude"].doubleValue
            locationA.longitude = json["longitude"].doubleValue
            
            print("Name: " + locationA.name)
            print("Latitude: " + String(format: "%.2f", locationA.latitude))
            print("Longitude: " + String(format: "%.2f", locationA.longitude))
                            
            // Initialize SwiftyJSON and return it asynchronously
            completionHandler(JSON(response.result.value!))
        }
    }
}

