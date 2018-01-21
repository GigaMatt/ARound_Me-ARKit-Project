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
    let url: String = "https://sbhacksiv.firebaseio.com/buildings/"
    let encoding = Alamofire.JSONEncoding.default
    var locations: [Location] = [Location]()
    
    func getLocation() {
        // Get location information asynchronously
        for index in 0..<5 {
            getLocationFromFirebase(index) { json in
                if var json = json {
                    let location = Location(json["name"].stringValue,
                                            json["latitude"].doubleValue,
                                            json["longitude"].doubleValue)
                    location.printValues()
                
                    self.locations.append(location)
                }
            }
        }
    }
    
    func getLocationFromFirebase(_ index: Int, completionHandler: @escaping (JSON?) -> Void) {
        // Run a GET to retrieve JSON data from Firebase asynchronously
        Alamofire.request(urlConstructor(index),
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
                print("Didn't get JSON response from Firebase!")
                print("Error: \(response.result.error!)")
                
                return
            }
            
            // Return JSON asynchronously
            completionHandler(JSON(response.result.value!))
        }
    }
    
    func urlConstructor(_ index: Int) -> String {
        return self.url + String(index) + ".json"
    }
}

