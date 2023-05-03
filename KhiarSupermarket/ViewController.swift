//
//  ViewController.swift
//  KhiarSupermarket
//
//  Created by Lujain Farghal on 08/08/1444 AH.

import UIKit
import Firebase
import FirebaseDatabase

class ViewController: UIViewController   {
    

    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var username: String!
    var userid: String!
    var ref : DatabaseReference!
    override func viewDidLoad() {
        super.viewDidLoad()
        ref=Database.database().reference()
        leftImageView(image:  UIImage(systemName: "at.circle")!, txtField: emailTextField)
        leftImageView(image:  UIImage(systemName: "lock.circle")!, txtField: passwordTextField)
        leftImageView(image:  UIImage(systemName: "person.circle")!, txtField: usernameTextfield)

    }
    
    @IBAction func signUp(_ sender: Any) {
        
        if let email = emailTextField.text, let password = passwordTextField.text{
            if email == "" && password == "" {
                UtilityFunctions().simpleAlert(vc: self, title: "Warnning", message: "Please Enter Email And Password")
            }else if !email.isValidMailInput(input: email){
                UtilityFunctions().simpleAlert(vc: self, title: "Warnning", message: "Please Enter Valid Email")
            }else if !email.isValidMailInput(input: email){
                UtilityFunctions().simpleAlert(vc: self, title: "Warnning", message: "Please Enter Valid Password")
            }else{
               Auth.auth().createUser(withEmail: email, password: password) { authDataResult, error in
                            if let err = error{
                                print(err)
                            }else{
                                let uId = Auth.auth().currentUser?.uid
                                let newUser = self.ref.child("User").child(uId!)
                                self.username = self.usernameTextfield.text
                                self.userid = uId
                                newUser.child("username").setValue(self.username)
                                newUser.child("userID").setValue(self.userid)
                                print("Successfuly create an account")
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainVC") as! UITabBarController
                                self.present(vc, animated: true)
                                
                            }
                        }
                        
            }
        }
       }
    
    func leftImageView(image: UIImage , txtField : UITextField) {
        txtField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: txtField.frame.height))
        txtField.leftViewMode = .always
        let leftView = UIImageView(frame: CGRect(x: 5, y: txtField.frame.height / 2-10, width: 25, height: 20))
        leftView.tintColor = .lightGray
        leftView.image = image
        txtField.addSubview(leftView)
    }


}
extension String{
    func isValidMailInput(input: String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: input)
    }
    func isValidPassword(password: String) -> Bool {
            let passwordRegEx = "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{6,16}"
            let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
            let result = passwordTest.evaluate(with: password)
            return result
        }
}

//func linedTextField(txtField : UITextField) {
//    let bottomLayer = CALayer()
//    bottomLayer.frame = CGRect(x: 0, y: txtField.frame.height, width: txtField.frame.width - 35 , height: 1)
//    bottomLayer.backgroundColor = UIColor.gray.cgColor
//    txtField.layer.addSublayer(bottomLayer)
//}
