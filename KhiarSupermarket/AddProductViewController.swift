//
//  AddProductViewController.swift
//  KhiarSupermarket
//
//  Created by Lujain Farghal on 10/08/1444 AH.
//

import UIKit
import FirebaseDatabase

class AddProductViewController: UIViewController , UIPickerViewDelegate , UIPickerViewDataSource , UITextViewDelegate , UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var ProductImage: UIImageView!
    @IBOutlet weak var productName: UITextField!
    @IBOutlet weak var productQuantity: UITextField!
    @IBOutlet weak var productPrice: UITextField!
    @IBOutlet weak var productSection: UITextField!
    var ref: DatabaseReference!
    let pickerSection = UIPickerView()
    var sections = ["Frozen","Canned","Fresh"]
    var currentIndex = 0
    var dataPic : String?
    var productIngredients : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        pickerSection.delegate=self
        pickerSection.dataSource=self
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Select", style: .done, target: self, action: #selector(doneToolBar))
        toolBar.setItems([doneButton], animated: true)
        productSection.inputView = pickerSection
        productSection.inputAccessoryView = toolBar
        
    }
    
    @IBAction func cnacelProductaddition(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ManagerHomePage") as! ManagerHomePageViewController
        self.present(vc, animated: true)
    }
    @IBAction func addNewProduct(_ sender: Any) {
        
        guard let image = dataPic , !image.isEmpty else{
            warningLabel.text="Please enter produtc's image"
            return
        }
        guard let ingredients = productIngredients else{
            warningLabel.text="Please enter produtc's ingredients.\n If the product is fresh, simply add its name in the ingredients section."
            return
        }
        guard let name = productName.text , !name.isEmpty else {
            warningLabel.text="Please enter produtc's name"
            return
        }
        guard let price = productPrice.text , !price.isEmpty else {
            warningLabel.text="Please enter produtc's price"
            return
        }
        guard let quantity = productQuantity.text , !quantity.isEmpty else {
            warningLabel.text="Please enter produtc's quantity"
            return
        }
        guard let section = productSection.text , !section.isEmpty else {
            warningLabel.text="Please enter produtc's section"
            return
        }
        
//        if section == "Fresh"{
//            productIngredients = name
//        }else{
//            warningLabel.text="Please enter produtc's ingredients."
//        }
        
        let newProduct = ref.child("Products").childByAutoId()
        let intQuantity = Int(quantity) ?? 0
        let doublePrice = Double(price) ?? 0.0
        let arrOfIng = ingredients.split(separator: ",")
        newProduct.child("name").setValue(name)
        newProduct.child("price").setValue(doublePrice)
        newProduct.child("quantity").setValue(intQuantity)
        newProduct.child("section").setValue(section)
        newProduct.child("image").setValue(image)
        newProduct.child("productId").setValue(newProduct.key)
        newProduct.child("ingredients").setValue(arrOfIng)
        
        warningLabel.text="Product Successfuly Added"
        warningLabel.textColor=UIColor.systemGreen
        productName.text = nil
        productPrice.text = nil
        productQuantity.text = nil
        productSection.text = nil
        ProductImage.image = UIImage(systemName: "camera.on.rectangle")
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
    
    @IBAction func addProductPicture(_ sender: Any) {
        showPhotoAlert()
    }
    
    @IBAction func addProductIngredientd(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "addIngredientsPicInterface") as! ProductIngredientsViewController
        self.present(vc, animated: true)
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
            print("Image Not Found")
            return
        }
        if let assetPath = info[.imageURL] as? URL{
               let URLString = assetPath.absoluteString.lowercased()
               if (URLString.hasSuffix("jpg")) {
                   dataPic = URLString
                   print("JPG")
               }
               else if (URLString.hasSuffix("jpeg")) {
                   dataPic = URLString
                   print("JPEG")
               }
               else if (URLString.hasSuffix("png")) {
                   dataPic = URLString
                   print("PNG")
               }
               else {
                   dataPic = URLString
                   print("Unkown Type")
               }
           }
        ProductImage.image = selectedPic
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}
