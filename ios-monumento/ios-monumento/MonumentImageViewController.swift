//
//  MonumentImageViewController.swift
//  ios-monumento
//
//  Created by Suryansh Singh Tomar on 05/03/21.
//

import UIKit

class MonumentImageViewController: UIViewController, UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    private var modelURl = ""
    private var monumentName = ""
    private var monumentModelMap = [
        "Taj Mahal" : "https://poly.googleusercontent.com/downloads/c/fp/1594202789615202/ajc6GfQ7_d_/fZXEbDa8gRt/taj.gltf",
        "Eiffel Tower" : "https://poly.googleusercontent.com/downloads/c/fp/1594652332676840/cPeRoB-RS0Q/4Z73gO10xW3/scene.gltf",
        "Statue of Liberty" : "https://poly.googleusercontent.com/downloads/c/fp/1594203800428477/ef9Yd09Doxh/6iB-aRbRXqD/model.gltf",
        "Colosseum" : "https://poly.googleusercontent.com/downloads/c/fp/1594117136139223/cVtCnH0tnHJ/fdSQ8NwCQDK/model.gltf",
        "Leaning Tower of Pisa" : "https://poly.googleusercontent.com/downloads/c/fp/1592733756165702/9hcSqLXC58h/afqTiZoEw8O/f42649ee9cd14a7db955bdcee2d21ac3.gltf"
        ]

    @IBOutlet weak var noModel: UILabel!
    @IBOutlet weak var augmentButton: UIButton!
    
    
    @IBAction func augmentButtonPressed(_ sender: Any) {
        //navigate to arsceneview
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ARSceneViewController") as! ARSceneViewController
        vc.monumentModelURL = modelURl
        vc.monumentName = monumentName
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBOutlet weak var detectedMonument: UILabel!
    
    
    @IBAction func detectMonumentButtonPressed(_ sender: Any) {
        if(capturedImage.image != nil){
        GoogleCloudAPI().detect(image: capturedImage.image!) { [self] (detectedLandmark) in
            if(detectedLandmark != nil){
            detectedMonument.text = detectedLandmark?.text
            detectedMonument.isHidden = false
                if((monumentModelMap[detectedLandmark!.text]) != nil){
                    augmentButton.isHidden = false
                    modelURl = monumentModelMap[detectedLandmark!.text]!
                    monumentName = detectedLandmark!.text
                }
                else{
                    augmentButton.isHidden = true
                    noModel.text = "No Model found for" + detectedLandmark!.text
                }
            
            }
            
        }
        }
    }
    
    @IBOutlet weak var detectMonumentButton: UIButton!
    
    @IBAction func onCaptureButtonPress(_ sender: Any) {
        
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        present(vc, animated: true)

        
    }
    @IBOutlet weak var capturedImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        augmentButton.isHidden = true
        detectedMonument.isHidden = true
        noModel.isHidden = true
        detectMonumentButton.isHidden = true
//        detectMonumentButton.isHidden = true

        // Do any additional setup after loading the view.
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        
        capturedImage.image = image;
        detectMonumentButton.isHidden = false

        // print out the image size as a test
        print(image.size)
    }
    

    

}
