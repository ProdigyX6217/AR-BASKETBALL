//
//  ViewController.swift
//  AR- BASKETBALL
//
//  Created by Student Laptop_7/19_1 on 8/25/20.
//  Copyright © 2020 Makeschool. All rights reserved.
//

import UIKit
import RealityKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
//    IBOutlet - Reference to Storyboard Element
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var addHoopButton: UIButton!
    
    var currentNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Set view's delegate
        sceneView.delegate = self
        
//        Show game statistics(fps, etc.)
//        sceneView.showsStatistics = true
        
//        Create a new scene
        let scene = SCNScene()
        
//        Set scene to View
        sceneView.scene = scene
        
        registerGestureRecognizer()
    }
    
    func registerGestureRecognizer(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(gestureRecognizer: UIGestureRecognizer){
//        sceneView to be accessed
//        access point of view of the sceneView...center point
        guard let sceneView = gestureRecognizer.view as? ARSCNView else{
            return
        }
        
        guard let centerPoint = sceneView.pointOfView else{
            return
        }
        
//        pointOfView allows access to transform matrix
//        TM contains the orientation/location of the camera
//        We need orientation/location to determine camera position. At this point is where we want the ball to be placed
        let cameraTransform = centerPoint.transform
        let cameraLocation = SCNVector3(x: cameraTransform.m41,y: cameraTransform.m42,z: cameraTransform.m43)
        let cameraOrientation = SCNVector3(x: -cameraTransform.m31,y: -cameraTransform.m32,z: -cameraTransform.m33)
        
//      x1 + x2, y1 + y2, z1 + z2
        let cameraPosition = SCNVector3Make(cameraLocation.x + cameraOrientation.x,cameraLocation.y + cameraOrientation.y,cameraLocation.z + cameraOrientation.z)
        
        let ball = SCNSphere(radius: 0.15)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "basketballSkin.png")
        ball.materials = [material]
        
//        In order to set object position in AR, that object needs to be a node
        let ballNode = SCNNode(geometry: ball)
        ballNode.position = cameraPosition
        
        
        let physicsShape = SCNPhysicsShape(node: ballNode, options: nil)
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicsShape)
        
//        Applying Physics Body to Ball Node
        ballNode.physicsBody = physicsBody
        
        let forceVector:Float = 6
        ballNode.physicsBody?.applyForce(SCNVector3(x: cameraOrientation.x * forceVector,y: cameraOrientation.y * forceVector ,z: cameraOrientation.z * forceVector), asImpulse: true)
        
        
//        Adding node to scene
        sceneView.scene.rootNode.addChildNode(ballNode)
        
    }
    
    
    func addBackboard(){
        guard let backboardScene = SCNScene(named: "art.scnassets/hoop.scn") else{
            return
        }
        
        guard let backboardNode = backboardScene.rootNode.childNode(withName: "backboard", recursively: false) else{
            return
        }
        
        backboardNode.position = SCNVector3(x: 0,y: 0.5,z: -3)
        
//          Applying Physics Body to Backboard
//          SceneKit knows there's a hole in the hoop (.concavePolyhedron)
        let physicsShape = SCNPhysicsShape(node: backboardNode, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.concavePolyhedron])
        
        let physicsBody = SCNPhysicsBody(type: .static, shape: physicsShape)
        
        backboardNode.physicsBody = physicsBody
        
        sceneView.scene.rootNode.addChildNode(backboardNode)
        currentNode = backboardNode
}
    
    
    func horizontalAction(node:SCNNode){
        let leftAction = SCNAction.move(by: SCNVector3(x: -1,y: 0,z: 0), duration: 3)
        let rightAction = SCNAction.move(by: SCNVector3(x: 1,y: 0,z: 0), duration: 3)
        
        let actionSequence = SCNAction.sequence([leftAction, rightAction])
        
//        node.runAction(actionSequence)
        node.runAction(SCNAction.repeat(actionSequence, count: 4))
    }
    
    
    func roundAction(node: SCNNode){
        let upLeft = SCNAction.move(by: SCNVector3(x: 1,y: 1, z:0), duration: 2)
        let downRight = SCNAction.move(by: SCNVector3(x: 1,y: -1, z:0), duration: 2)
        let downLeft = SCNAction.move(by: SCNVector3(x: -1,y: -1, z:0), duration: 2)
        let upRight = SCNAction.move(by: SCNVector3(x: -1,y: 1, z:0), duration: 2)

        let actionSequence = SCNAction.sequence([upLeft, downRight, downLeft, upRight])
        
//        node.runAction(actionSequence)
        node.runAction(SCNAction.repeat(actionSequence, count: 2))
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        Create A Session Configuration
        let configuration = ARWorldTrackingConfiguration()
        
//        Run the View's Session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            
//        Pause the View's Session
            sceneView.session.pause()
        }
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            
//        Release Any Cached Data that isn't in use.
        }
    
    
    func sessionWasInterrupted(_ session: ARSession, didFailWithError error:Error) {
//    Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
//        Inform user that the session has been interrupted, for ex. by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
    //    Reset tracking and/or remove existing anchors if consistent Tracking is required
        }
    
    
//    IBAction - Action to be performed upon click
    @IBAction func addHoop(_ sender: Any) {
        addBackboard()
        addHoopButton.isHidden = true
    }
    
    @IBAction func startRoundAction(_ sender: Any) {
        roundAction(node: currentNode)
    }
    
    @IBAction func stopAllActions(_ sender: Any) {
        currentNode.removeAllActions()
    }
    
    @IBAction func startHorizontalAction(_ sender: Any) {
        horizontalAction(node: currentNode)
    }
    
    
    
    
}

