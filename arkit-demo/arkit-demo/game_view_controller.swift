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

class GameViewController: UIViewController, ARSCNViewDelegate { //of tyoe UIController
    @IBOutlet weak var somethingSceneView: ARSCNView!
    
    override func viewDidLoad() {
        somethingSceneView.delegate = self          //setting the views delegate
        somethingSceneView.showsStatistics = false  //essentilly shwos FPS && timing information
        
        
        let thisScene = SCNScene(named: "art.scnassets/ship.scn")   //creates new scene
        somethingSceneView.scene = thisScene!
        
        
    }
    
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
