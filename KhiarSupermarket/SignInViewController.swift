//
//  SignInViewController.swift
//  KhiarSupermarket
//
//  Created by Lujain Farghal on 09/08/1444 AH.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {

    @IBOutlet weak var errorTextField: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        leftImageView(image: UIImage(systemName: "lock.circle")!, txtField: passwordTextField)
        leftImageView(image: UIImage(systemName: "at.circle")!, txtField: emailTextField)
        
    }
    
    @IBAction func backToSignUpPage(_ sender: Any) {
        self.dismiss(animated: true)
    }

    
    @IBAction func signUp(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "signUpPage") as! ViewController
        self.present(vc, animated: true)
    }
    @IBAction func signIn(_ sender: Any) {
        guard let email = emailTextField.text else{return}
        guard let password = passwordTextField.text else{return}
        Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            if let err = error{
                self.errorTextField.isHidden = false
                self.errorTextField.text = "User Does Not Exist Or Invalid Password"
                print(err)
            }else{
                print("Successfuly signed in")
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainVC") as! UITabBarController
                self.present(vc, animated: true)
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
