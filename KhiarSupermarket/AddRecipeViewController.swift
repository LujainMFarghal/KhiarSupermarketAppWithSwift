//
//  AddRecipeViewController.swift
//  KhiarSupermarket
//
//  Created by Lujain Farghal on 19/09/1444 AH.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
class AddRecipeViewController: UIViewController , UITableViewDelegate , UITableViewDataSource ,  UIImagePickerControllerDelegate , UINavigationControllerDelegate{

    @IBOutlet weak var vegetarinaButton: UIButton!
    @IBOutlet weak var sugerfreeButton: UIButton!
    @IBOutlet weak var ketoButton: UIButton!
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeName: UITextField!
    @IBOutlet weak var recipeIngredients: UITextField!
    @IBOutlet weak var recipeProcedure: UITextView!
    var ref: DatabaseReference!
    var keto = false
    var sugerFree = false
    var vegetarian = false
    var arrOfIng = [String]()
    var suitedDiets = [String]()
    var dataPic : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        ingredientsTableView.delegate=self
        ingredientsTableView.dataSource=self
        vegetarinaButton.addBorder()
        sugerfreeButton.addBorder()
        ketoButton.addBorder()
        recipeProcedure.layer.borderWidth=0.4
        recipeProcedure.layer.cornerRadius=3
        recipeProcedure.layer.borderColor=UIColor.lightGray.cgColor
        
    }
    @IBAction func keto(_ sender: Any) {
        self.checked(check: &keto, sender: ketoButton, dietName: "Keto")
    }
    @IBAction func sugerFree(_ sender: Any) {
        self.checked(check: &sugerFree, sender: sugerfreeButton, dietName: "Suger-Free")
    }
    @IBAction func vegetarian(_ sender: Any) {
        self.checked(check: &vegetarian, sender: vegetarinaButton, dietName: "Vegetarian")
    }
    @IBAction func addIngredient(_ sender: Any) {
        if let text = recipeIngredients.text{
            arrOfIng.append(text)
            let indexPath = IndexPath(row: arrOfIng.count-1, section: 0)
            ingredientsTableView.beginUpdates()
            ingredientsTableView.insertRows(at: [indexPath], with: .automatic)
            ingredientsTableView.endUpdates()
            recipeIngredients.text=""
        }
    }
    @IBAction func chooseImage(_ sender: Any) {
        showPhotoAlert()
    }
    @IBAction func addRecipe(_ sender: Any) {
        guard let pic = dataPic , !pic.isEmpty else{
            UtilityFunctions().simpleAlert(vc: self, title: "Uncompleted data", message: "Please choose picture for the recipe")
            return
        }
        guard let name = recipeName.text , !name.isEmpty else{
            UtilityFunctions().simpleAlert(vc: self, title: "Uncompleted data", message: "Please type name for the recipe")
            return
        }
        guard !arrOfIng.isEmpty else{
            UtilityFunctions().simpleAlert(vc: self, title: "Uncompleted data", message: "Please type ingredients of the recipe")
            return
        }
        guard !suitedDiets.isEmpty else{
            UtilityFunctions().simpleAlert(vc: self, title: "Uncompleted data", message: "Please choose diets that suited for the recipe")
            return
        }
        guard let procedure = recipeProcedure.text , !procedure.isEmpty else{
            UtilityFunctions().simpleAlert(vc: self, title: "Uncompleted data", message: "Please type recipe procedure")
            return
        }
        let newProduct = ref.child("Recipe").childByAutoId()
        newProduct.child("userId").setValue(FirebaseAuth.Auth.auth().currentUser?.uid)
        newProduct.child("image").setValue(pic)
        newProduct.child("id").setValue(newProduct.key)
        newProduct.child("name").setValue(name)
        newProduct.child("procedure").setValue(procedure)
        newProduct.child("dietsSuited").setValue(suitedDiets)
        newProduct.child("ingredients").setValue(arrOfIng)
        self.dismiss(animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(arrOfIng)
        return arrOfIng.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ingredient", for: indexPath)
        cell.textLabel?.text=arrOfIng[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
            self.arrOfIng.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
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
                   dataPic = URLString
            recipeImage.image = selectedPic
    }
}
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    func checked( check : inout Bool , sender:UIButton , dietName:String){
        if check==false{
            sender.setImage(UIImage(systemName: "checkmark"), for: UIControl.State.normal)
            check=true
            suitedDiets.append(dietName)
            print(suitedDiets)
        }else{
            sender.setImage(UIImage(), for: UIControl.State.normal)
            check=false
            var counter = 0
            for diet in suitedDiets {
                if dietName == diet{
                    suitedDiets.remove(at: counter)
                }
                counter += 1
            }
            print(suitedDiets)
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
}

