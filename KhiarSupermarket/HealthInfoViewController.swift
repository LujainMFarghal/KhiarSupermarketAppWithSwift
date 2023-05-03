//
//  HealthInfoViewController.swift
//  KhiarSupermarket
//
//  Created by Lujain Farghal on 23/08/1444 AH.
//

import UIKit
import FirebaseDatabase
import Firebase

class HealthInfoViewController: UIViewController, UIPickerViewDelegate , UIPickerViewDataSource , UITextViewDelegate , UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var nutButton: UIButton!
    @IBOutlet weak var wheatButton: UIButton!
    @IBOutlet weak var soyButton: UIButton!
    @IBOutlet weak var peanutButton: UIButton!
    @IBOutlet weak var milkButton: UIButton!
    @IBOutlet weak var eggButton: UIButton!
    @IBOutlet weak var physicalActivity: UITextField!
    @IBOutlet weak var followedDiet: UITextField!
    var isFemale = false
    var isMale = false
    var milk = false
    var egg = false
    var peanut = false
    var soy = false
    var wheat = false
    var nut = false
    var arrOfAllergy = [String]()
    var levelOfActivity = ["Seentary active","Lightly active","Moderately active","Very active","Extra active"]
    var diets = ["Non", "Keto" , "Vegetarian" , "Low Carb"]
    var currentIndexActivity = 0
    var currentIndexDiet = 0
    let pickerActivity = UIPickerView()
    let pickerDiet = UIPickerView()
    var picker : UIPickerView?
    let ref = Database.database().reference()
    override func viewDidLoad() {
        super.viewDidLoad()
        maleButton.addBorder()
        maleButton.makeItCircle()
        femaleButton.addBorder()
        femaleButton.makeItCircle()
        
        milkButton.addBorder()
        eggButton.addBorder()
        peanutButton.addBorder()
        soyButton.addBorder()
        wheatButton.addBorder()
        nutButton.addBorder()
        
        pickerActivity.delegate=self
        pickerActivity.dataSource=self
        
        pickerDiet.delegate=self
        pickerDiet.dataSource=self
        
        let toolBarActivity = UIToolbar()
        toolBarActivity.sizeToFit()
        let doneButtonActivity = UIBarButtonItem(title: "Select", style: .done, target: self, action: #selector(doneToolBar))
        toolBarActivity.setItems([doneButtonActivity], animated: true)
        
        let toolBarDiet = UIToolbar()
        toolBarDiet.sizeToFit()
        let doneButtonDiet = UIBarButtonItem(title: "Select", style: .done, target: self, action: #selector(doneToolBar))
        toolBarDiet.setItems([doneButtonDiet], animated: true)
        
        physicalActivity.inputView = pickerActivity
        physicalActivity.inputAccessoryView = toolBarActivity
        
        followedDiet.inputView = pickerDiet
        followedDiet.inputAccessoryView = toolBarDiet
    }
    
    @IBAction func femaleChecked(_ sender: UIButton) {
        if isMale == true{
            femaleButton.backgroundColor=UIColor.white
            maleButton.backgroundColor=UIColor.darkGray
            isFemale=true
            isMale=false
        }else{
            maleButton.backgroundColor=UIColor.white
            femaleButton.backgroundColor=UIColor.darkGray
            isMale=true
            isFemale=false
        }
    }

    
    @IBAction func maleChecked(_ sender: UIButton) {
        if isFemale == true{
            maleButton.backgroundColor=UIColor.white
            femaleButton.backgroundColor=UIColor.darkGray
            isFemale=false
            isMale=true
        }else{
            femaleButton.backgroundColor=UIColor.white
            maleButton.backgroundColor=UIColor.darkGray
            isFemale=true
            isMale=false
        }
        
    }
    
    @IBAction func milkChecked(_ sender: Any) {
        checked(check: &milk, sender: milkButton , allergyName: "Milk")
    }
    @IBAction func eggChecked(_ sender: Any) {
        checked(check: &egg, sender: eggButton , allergyName: "Egg")
    }
    @IBAction func peanutChecked(_ sender: Any) {
        checked(check: &peanut, sender: peanutButton , allergyName: "Peanut")
    }
    @IBAction func soyChecked(_ sender: Any) {
        checked(check: &soy, sender: soyButton , allergyName: "Soy")
    }
    @IBAction func wheatChecked(_ sender: Any) {
        checked(check: &wheat, sender: wheatButton , allergyName:"Wheat")
    }
    @IBAction func nutChecked(_ sender: Any) {
        checked(check: &nut, sender: nutButton, allergyName:"Nut")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == pickerActivity{
            picker = pickerView
            return levelOfActivity.count
        }else{
            picker=pickerView
            return diets.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == pickerActivity{
            return levelOfActivity[row]
        }else{
            return diets[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerActivity{
            currentIndexActivity = row
            physicalActivity.text = levelOfActivity[row]
        }else{
            currentIndexDiet = row
            followedDiet.text = diets[row]
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc func doneToolBar(){
        doneToolBarII(pickerView: picker!)
    }
    func doneToolBarII(pickerView:UIPickerView){
        if picker == pickerActivity{
            physicalActivity.text = levelOfActivity[currentIndexActivity]
            view.endEditing(true)
        }else{
            followedDiet.text = diets[currentIndexDiet]
            view.endEditing(true)
        }
    }

    @IBAction func doneEditHealthInfo(_ sender: Any) {
        let user = Auth.auth().currentUser?.uid
        let wieght = weightTextField.text
        let height = heightTextField.text
        let diet = followedDiet.text
        var gender : String?
        if isFemale==false{
            gender="female"
        }else{
            gender="male"
        }
        let physicalActivityLevel = physicalActivity.text
        let userinfo = ref.child("User").child(user!).child("HealtInformation")
        userinfo.child("wieght").setValue(wieght)
        userinfo.child("height").setValue(height)
        userinfo.child("gender").setValue(gender)
        userinfo.child("physicalActivityLevel").setValue(physicalActivityLevel)
        userinfo.child("allergens").setValue(arrOfAllergy)
        userinfo.child("diet").setValue(diet)


    }
    func checked( check : inout Bool , sender:UIButton , allergyName:String){
        if check==false{
            sender.setImage(UIImage(systemName: "checkmark"), for: UIControl.State.normal)
            check=true
            arrOfAllergy.append(allergyName)
            print(arrOfAllergy)
        }else{
            sender.setImage(UIImage(), for: UIControl.State.normal)
            check=false
            var counter = 0
            for allergy in arrOfAllergy {
                if allergyName == allergy{
                    arrOfAllergy.remove(at: counter)
                }
                counter += 1
            }
            print(arrOfAllergy)
        }
    }
}
extension UIButton{
    func addBorder(){
        self.layer.borderWidth=1
        self.layer.borderColor=UIColor.lightGray.cgColor
    }
    func makeItCircle(){
        self.layer.cornerRadius = (self.frame.size.width) / 2
    }
}
