//
//  game_view_controller.swift
//  arkit-demo
//
//  Created by Matthew Medina on 1/20/18.
//  Copyright © 2018 Matthew Medina. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit
import CoreLocation
import PusherSwift      //FIXME: Still need to download from article


class GameViewController: UIViewController, ARSCNViewDelegate { //of tyoe UIController
    @IBOutlet weak var somethingSceneView: ARSCNView!
    
    override func viewDidLoad() {
        somethingSceneView.delegate = self          //setting the views delegate
        somethingSceneView.showsStatistics = false  //essentilly shwos FPS && timing information
        
        
        let scene = SCNScene(named: "art.scnassets/ship.scn")   //creates new scene
        somethingSceneView.scene = thisScene!
    }
    
    /*
     
     //Get the 
     
     long1 = 0
     lat1= 0
     
     long2 = 34.412646
     lat2 = -119.848389
     
     x = sin(long2 - long1) * cos(long2)
     y = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(long2 - long1)
     
     atan2(x,y)
 
 */
    
    
    override func viewWillDisappear(_ animated: Bool){
        somethingSceneView.session.pause()
        
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let config = ARWorldTrackingConfiguration()
        somethingSceneView.session.run(config)  //setting the scene \/ seeing the image here
        
    
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        
    }
    func sessionInterruptionEnded(_ session: ARSession) {
        
    }
    func session(_ session: ARSession, didFailWithError error: Error) {
        
    }
}
