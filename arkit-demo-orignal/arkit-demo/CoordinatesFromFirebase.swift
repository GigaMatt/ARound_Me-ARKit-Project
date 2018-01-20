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

class CoordinatesFromFirebase {
    let getEndpoint: String = "https://sbhacksiv.firebaseio.com/"
    
    func getLocationCoordinates() {
        // Run a GET to retrieve JSON data from Firebase
        Alamofire.request(getEndpoint, method: .get).responseJSON { response in
            // Check for GET errors
            guard response.result.error == nil else {
                // Error getting data
                print("Error getting coordinates from Firebase!")
                print(response.result.error!)
                
                return
            }
            
            // Check if value recieved is nil
            guard (response.result.value as? [String:Any]) != nil else {
                print ("Didn't get JSON response from Firebase!")
                print ("Error: \(response.result.error!)")
                
                return
            }
            
            
        }
    }
}
