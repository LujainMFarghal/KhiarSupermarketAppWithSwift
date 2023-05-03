//
//  ProductIngredientsViewController.swift
//  KhiarSupermarket
//
//  Created by Lujain Farghal on 17/08/1444 AH.
//

import UIKit
import Vision

class ProductIngredientsViewController: UIViewController ,  UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    

    @IBOutlet weak var extractedIngredients: UITextView!
    @IBOutlet weak var pproductIngredientsPic: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func addProductIngredientsPic(_ sender: Any) {
        showPhotoAlert()
    }
    
    func textRecognizer(image : UIImage){
        guard let cgImage = image.cgImage else{
            return
        }
        // handler
        let handler = VNImageRequestHandler(cgImage: cgImage)
        
        //request
        let request = VNRecognizeTextRequest{ [weak self] request,error in
            guard let observation = request.results as? [VNRecognizedTextObservation],
                  error == nil else{
                return
            }
            let text = observation.compactMap({
                $0.topCandidates(1).first?.string
            }).joined(separator: " ")
            DispatchQueue.main.async {
                self?.extractedIngredients.text=text
            }
        }

        // process request
        do{
            try handler.perform([request])
        }
        catch{
            extractedIngredients.text="\(error)"
        }
    }
    
    func showPhotoAlert(){
        let alert = UIAlertController(title: "Take Picture From", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            self.getPicture(type: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { action in
            self.getPicture(type: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:  nil ))
        present(alert, animated: true)
    }
    
    func getPicture(type:UIImagePickerController.SourceType){
        let picker = UIImagePickerController()
        picker.sourceType = type
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)
        guard let selectedPic = info[.editedImage] as? UIImage else{
            print("Image Not Fount")
            return
        }
        pproductIngredientsPic.image = selectedPic
        textRecognizer(image : selectedPic)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    @IBAction func doneExtractIngredients(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "addNewProduct") as! AddProductViewController
        vc.productIngredients = extractedIngredients.text
        self.present(vc, animated: true)
    }

}
