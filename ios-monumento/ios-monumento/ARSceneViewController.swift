//
//  ARSceneViewController.swift
//  ios-monumento
//
//  Created by Suryansh Singh Tomar on 05/03/21.
//

import UIKit
import Flutter
import ARKit
import GLTFSceneKitLoader
import GLTFSceneKit


class ARSceneViewController: UIViewController,URLSessionDownloadDelegate{
    
    let loader = GLTFLoader()
    var modelNode = SCNNode()
    
    var monumentModelURL:String = ""
    var monumentName:String = ""

    
    @IBOutlet weak var sceneView: ARSCNView!

    override func viewDidLoad() {
        super.viewDidLoad()

//                loader.load(baseURL: monumentModelURL, filename: "model.gltf"){ node in
//                   print("new node => \(node)")
//                   if let node = node {
//                    self.modelNode.addChildNode(node)
//                   }
//                    self.addTapGestureToSceneView()
//
//               }
        addTapGestureToSceneView()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSceneView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func setUpSceneView() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    
    
   
    @objc func addShipToSceneView(withGestureRecognizer recognizer: UIGestureRecognizer) {
        print("tapped")
        let tapLocation = recognizer.location(in: sceneView)
            let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
            
            guard let hitTestResult = hitTestResults.first else { return }
            let translation = hitTestResult.worldTransform.translation
            let x = translation.x
            let y = translation.y
            let z = translation.z
            
            guard let shipScene = SCNScene(named: "3DObjects/ship.scn"),
                let shipNode = shipScene.rootNode.childNode(withName: "ship", recursively: false)
                else { return }
            
            
            shipNode.position = SCNVector3(x,y,z)
            sceneView.scene.rootNode.addChildNode(shipNode)    }
    
 
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ARSceneViewController.addShipToSceneView(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func downloadSceneTask(){

            //1. Get The URL Of The SCN File
            guard let url = URL(string: "https://poly.googleusercontent.com/downloads/c/fp/1613182480735156/ajc6GfQ7_d_/1qyW-0haLGU/archive.zip") else { return }

//            //2. Create The Download Session
            let downloadSession = URLSession(configuration: URLSession.shared.configuration, delegate: self, delegateQueue: nil)

//            //3. Create The Download Task & Run It
            let downloadTask = downloadSession.downloadTask(with: url)
            downloadTask.resume()
        
       
        }

     

func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

    //1. Create The Filename
    let fileURL = getDocumentsDirectory().appendingPathComponent("model.zip")

    //2. Copy It To The Documents Directory
    do {
//        try FileManager.default.removeItem(at: fileURL)
        try FileManager.default.copyItem(at: location, to: fileURL)

        print("Successfuly Saved File \(fileURL)")

        //3. Load The Model
        DispatchQueue.main.async { [self] in
            addTapGestureToSceneView()
        }
       
    } catch {

        print("Error Saving: \(error)")
    }

}
func getDocumentsDirectory() -> URL {

let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
let documentsDirectory = paths[0]
return documentsDirectory

}
   


}


extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

extension UIColor {
    open class var transparentLightBlue: UIColor {
        return UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.50)
    }
}

extension ARSceneViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
            
            // 2
            let width = CGFloat(planeAnchor.extent.x)
            let height = CGFloat(planeAnchor.extent.z)
            let plane = SCNPlane(width: width, height: height)
            
            // 3
            plane.materials.first?.diffuse.contents = UIColor.transparentLightBlue
            
            // 4
            let planeNode = SCNNode(geometry: plane)
            
            // 5
            let x = CGFloat(planeAnchor.center.x)
            let y = CGFloat(planeAnchor.center.y)
            let z = CGFloat(planeAnchor.center.z)
            planeNode.position = SCNVector3(x,y,z)
            planeNode.eulerAngles.x = -.pi / 2
            
            // 6
            node.addChildNode(planeNode)
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // 1
        guard let planeAnchor = anchor as?  ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }
         
        // 2
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        plane.width = width
        plane.height = height
         
        // 3
        let x = CGFloat(planeAnchor.center.x)
        let y = CGFloat(planeAnchor.center.y)
        let z = CGFloat(planeAnchor.center.z)
        planeNode.position = SCNVector3(x, y, z)
    }
}

