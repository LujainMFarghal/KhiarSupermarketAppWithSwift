//
//  ModifyProductViewController.swift
//  KhiarSupermarket
//
//  Created by Lujain Farghal on 13/08/1444 AH.
//

import UIKit
import FirebaseDatabase

class ModifyProductViewController: UIViewController , UIPickerViewDelegate , UIPickerViewDataSource , UITextViewDelegate , UIImagePickerControllerDelegate , UINavigationControllerDelegate{

    @IBOutlet weak var productName: UITextField!
    @IBOutlet weak var productPicture: UIImageView!
    @IBOutlet weak var productPrice: UITextField!
    @IBOutlet weak var productQuantity: UITextField!
    @IBOutlet weak var productSection: UITextField!
    var name = ""
    var url = ""
    var price = 0.0
    var quantity = 0
    var section = ""
    let pickerSection = UIPickerView()
    var sections = ["Frozen","Canned","Fresh"]
    var currentIndex = 0
    var productId : String?
    var dataPic : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        productName.text=name
        productPicture.load(url: url)
        productPrice.text = String(price)
        productQuantity.text = String(quantity)
        productSection.text = section
        dataPic=url
        
        pickerSection.delegate=self
        pickerSection.dataSource=self
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Select", style: .done, target: self, action: #selector(doneToolBar))
        toolBar.setItems([doneButton], animated: true)
        productSection.inputView = pickerSection
        productSection.inputAccessoryView = toolBar
        
    }
    
    @IBAction func cancelModification(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ManagerHomePage") as! ManagerHomePageViewController
        self.present(vc, animated: false)
    }
    @IBAction func changeProductPic(_ sender: Any) {
        showPhotoAlert()
    }
    @IBAction func doneModify(_ sender: Any) {
        guard let pId = productId else{ return }
        let ref = Database.database().reference().child("Products").child(pId)
        let changes : [String:Any] = ["name":productName.text! + " " , "price": Double(productPrice.text!) ?? 0.0, "quantity": Int(productQuantity.text!) ?? 0 , "section":productSection.text , "image": dataPic]
        ref.updateChildValues(changes)
        self.dismiss(animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sections.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sections[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentIndex = row
        productSection.text = sections[row]
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    @objc func doneToolBar(){
        productSection.text = sections[currentIndex]
        view.endEditing(true)
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
        if let assetPath = info[.imageURL] as? URL{
               let URLString = assetPath.absoluteString.lowercased()
                   dataPic = URLString
           }
        productPicture.image = selectedPic
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }

}
