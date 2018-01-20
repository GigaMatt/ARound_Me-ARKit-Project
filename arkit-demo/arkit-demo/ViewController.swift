//
//  ViewController.swift
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


class ViewController: UIViewController, ARSCNViewDelegate, CLLocationManagerDelegate {
    //Request && store the user's location
    let locationManager = CLLocationManager()
    var userLocation = CLLocation()
    
    //Direction && distance the other person is from us
    var heading : Double! = 0.0
    var distance : Float! = 0.0 {
        didSet {
            setStatusText()
        }
    }
    var status: String! {
        didSet {
            setStatusText()
        }
    }
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /*************************************************
     Display the distance on-screen
     Text will be updated as new values come in
    *************************************************/
    func setStatusText() {
        var text = "Status: \(status!)\n"
        text += "Distance: \(String(format: "%.2f m", distance))"
        statusTextView.text = text
    }
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
    //Store and name the root node of the SCCNode HUMAN_HEAD model (within .scn)
    var modelNode:SCNNode!
    let rootNodeName = "Head"
    
    //Original transformation of the node to calculate the orientation (rotation) of the model in the best possible way
    var originalTransform:SCNMatrix4!
    
    //Begin working with pusher
    let pusher = Pusher(
        key: "YOUR_PUSHER_APP_KEY",
        options: PusherClientOptions(
            authMethod: .inline(secret: "YOUR_PUSHER_APP_SECRET"),
            host: .cluster("YOUR_PUSHER_APP_CLUSTER")
        )
    )
    var channel: PusherChannel!
    
    
    /**************************************
     Set up SceneKit && Location Services
     **************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the view's delegate
        sceneView.delegate = self
        //Create a new scene
        let scene = SCNScene()
        //Set the scene to the view
        sceneView.scene = scene
        
        //Start location services
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        //Set the initial status
        status = "Getting user location..."
        
        //Set a padding in the text view
        statusTextView.textContainerInset = UIEdgeInsetsMake(20.0, 10.0, 10.0, 0.0)
    }
    
    
    /************************
     Configure the AR Session
     ************************/
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Create session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        
        //Run view session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Pause the view's session
        sceneView.session.pause()
    }
    
    
    /************************
     Get user location
        -CLLocationManager
     ************************/
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Implementing this method is required
        print(error.localizedDescription)
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    
    /********************************
     Connect user location to pusher
     ********************************/
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {        //Initalize the connect to pusher
        if let location = locations.last {
            userLocation = location
            status = "Connecting to Pusher..."
            
            self.connectToPusher()
        }
    }
    func connectToPusher() {                                                                                 //Connect + subscribe to channel, && bind to event
        let channel = pusher.subscribe("private-channel")
        
        let _ = channel.bind(eventName: "client-new-location", callback: { (data: Any?) -> Void in
            if let data = data as? [String : AnyObject] {
                if let latitude = Double(data["latitude"] as! String),
                    let longitude = Double(data["longitude"] as! String),
                    let heading = Double(data["heading"] as! String)  {
                    self.status = "Driver's location received"
                    self.heading = heading
                    self.updateLocation(latitude, longitude)
                }
            }
        })
        
        pusher.connect()
        status = "Waiting to receive location events..."
    }
    
    
    /***********************************************
     Calculate distance between us and other person
     ***********************************************/
    func updateLocation(_ latitude : Double, _ longitude : Double) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        self.distance = Float(location.distance(from: self.userLocation))
        
        //Will ALWAYS be nil at first initiation
        if self.modelNode == nil {
            let modelScene = SCNScene(named: "art.scnassets/head.dae")!                                 //FIXME: May need to be head.scn
            self.modelNode = modelScene.rootNode.childNode(withName: rootNodeName, recursively: true)!
            
            //Move model's pivot to its center in the Y axis
            let (minBox, maxBox) = self.modelNode.boundingBox
            self.modelNode.pivot = SCNMatrix4MakeTranslation(0, (maxBox.y - minBox.y)/2, 0)
            
            //Save original transform to calculate future rotations
            self.originalTransform = self.modelNode.transform
            
            //Position the model in the correct place
            positionModel(location)
            
            //Add the model to the scene
            sceneView.scene.rootNode.addChildNode(self.modelNode)
            
            //Create arrow from the emoji
            let arrow = makeBillboardNode("⬇️".image()!)
            
            //Position it on top of the HUMAN_HEAD
            arrow.position = SCNVector3Make(0, 4, 0)
            
            //Add it as a child of the HUMAN_HEAD model
            self.modelNode.addChildNode(arrow)
        }
        else {
            //Begin animation
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 1.0
            
            //Position the model in the correct place
            positionModel(location)
            
            //End animation
            SCNTransaction.commit()
        }
    }
    
    
    /********************************************************************
     Modify width/height of 3D plane so arrow emoji can be seen properly
     ********************************************************************/
    func makeBillboardNode(_ image: UIImage) -> SCNNode {
        let plane = SCNPlane(width: 10, height: 10)
        plane.firstMaterial!.diffuse.contents = image
        let node = SCNNode(geometry: plane)
        node.constraints = [SCNBillboardConstraint()]
        return node
    }
    
    
    /********************************************************************
     Properly position the model by rotating accordingly
     ********************************************************************/
    func positionModel(_ location: CLLocation) {
        //Rotate node as a*b (b*a != a*b in linear algebra)
        self.modelNode.transform = rotateNode(Float(-1 * (self.heading - 180).toRadians()), self.originalTransform)
        
        //Translate node
        self.modelNode.position = translateNode(location)
        
        //Scale node
        self.modelNode.scale = scaleNode(location)
    }
    
    /********************************************************************
     Rotate the node 
     ********************************************************************/
    func rotateNode(_ angleInRadians: Float, _ transform: SCNMatrix4) -> SCNMatrix4 {
        let rotation = SCNMatrix4MakeRotation(angleInRadians, 0, 1, 0)
        return SCNMatrix4Mult(transform, rotation)
    }
    
    
    /********************************************************************
     Scale model in proportion to the distance
     ********************************************************************/
    func scaleNode (_ location: CLLocation) -> SCNVector3 {
            let scale = min( max( Float(1000/distance), 1.5 ), 3 )
            return SCNVector3(x: scale, y: scale, z: scale)
        }
    
    
}




//------------------------------------------------------------------------//
class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
