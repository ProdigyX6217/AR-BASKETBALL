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

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Set view's delegate
        sceneView.delegate = self
        
//        Show statistics(fps, etc.)
        sceneView.showsStatistics = true
        
//        Create a new scene
        let scene = SCNScene()
        
//        Set scene to View
        sceneView.scene = scene
        
        addBackboard()
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
        let cameraOrientation = SCNVector3(x: cameraTransform.m31,y: cameraTransform.m32,z: cameraTransform.m33)
        
//      x1 + x2, y1 + y2, z1 + z2
        let cameraPosition = SCNVector3Make(cameraLocation.x + cameraOrientation.x,cameraLocation.y + cameraOrientation.y,cameraLocation.z + cameraOrientation.z)
        
        
    }
    
    
    func addBackboard(){
        guard let backboardScene = SCNScene(named: "art.scnassets/hoop.scn") else{
            return
        }
        
        guard let backboardNode = backboardScene.rootNode.childNode(withName: "backboard", recursively: false) else{
            return
        }
        
        backboardNode.position = SCNVector3(x: 0,y: 0.5,z: -3)
        
        sceneView.scene.rootNode.addChildNode(backboardNode)
}
    
}

