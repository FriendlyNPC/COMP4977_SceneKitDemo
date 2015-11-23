//
//  GameViewController.swift
//  SKDemo
//
//  Created by Team5 on 2015-11-22.
//  Copyright (c) 2015 Devan Yim. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController, SCNPhysicsContactDelegate {
    
    var sceneView: SCNView!
    var scene : SCNScene!
    var barrel: SCNNode!
    var currentRock: SCNNode!
    var particles1Node: SCNNode!
    var particles1: SCNParticleSystem!
    var onFire: Bool!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        onFire = false
    
        
        // create a new scene
        scene = SCNScene(named: "art.scnassets/my_scene.scn")!
        scene.physicsWorld.contactDelegate = self
        
        sceneView = self.view as! SCNView
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        tapRecognizer.addTarget(self, action: "sceneTapped:")
        sceneView.gestureRecognizers = [tapRecognizer]
       
        barrel = scene.rootNode.childNodeWithName("barrel", recursively: true)!
        barrel.physicsBody?.contactTestBitMask = 4
        particles1Node = barrel.childNodeWithName("particles1", recursively: true)!
        particles1 = particles1Node.particleSystems![0]
        particles1.birthRate = 0;
        
        // set the scene to the view
        sceneView.scene = scene
        
        
        // show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // allows the user to manipulate the camera
        sceneView.allowsCameraControl = true
        
        // configure the view
        sceneView.backgroundColor = UIColor.blackColor()
        
    }
    
    func sceneTapped(recognizer: UITapGestureRecognizer) {
        let location = recognizer.locationInView(sceneView)
        
        let hitResults = sceneView.hitTest(location, options: nil)
        if hitResults.count > 0 {
            let result = hitResults[0] as SCNHitTestResult
            let node = result.node
           
            if (node.name == "cylinder") {

                // retrieve the source node
                
                let source = scene.rootNode.childNodeWithName("source", recursively: true)!
                
                
                // retrieve the target
                let target = barrel.childNodeWithName("target", recursively: true)!
                
                
                let rockScene = SCNScene(named: "art.scnassets/ball.scn")
                let rockNode = rockScene!.rootNode.childNodeWithName("geosphere", recursively: true)
                
                rockNode?.position = source.position
                currentRock = rockNode!
                source.addChildNode(rockNode!)
                //rockNode!.physicsBody!.contactTestBitMask = 2
                var targetVector =  barrel.presentationNode.position
                
                targetVector.y += target.presentationNode.position.y
                
                let direction = get_vector(source.position, end: targetVector)
                
                rockNode?.physicsBody?.applyForce(direction, atPosition: SCNVector3(x:0,y:0,z:0), impulse: true)
                
            }
        }
    }
    
    func get_vector(start: SCNVector3, end: SCNVector3) -> SCNVector3{
        let x = end.x - start.x
        let y = end.y - start.y
        let z = end.z - start.z
        
        return SCNVector3(x: x*4,y: y*4 ,z:z*4)
    }
    
    func physicsWorld(world: SCNPhysicsWorld, didBeginContact contact: SCNPhysicsContact) {
        
        print("collision!")
        
        print("\(contact.nodeA.name)")
        print("\(contact.nodeB.name)")
        
        if (currentRock == nil){
            return
        }
        
        if (contact.nodeA == barrel || contact.nodeA == currentRock) && (contact.nodeB == barrel || contact.nodeB == currentRock) {
            
             particles1.birthRate = 45
             
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
