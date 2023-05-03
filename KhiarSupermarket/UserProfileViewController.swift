//
//  UserProfileViewController.swift
//  KhiarSupermarket
//
//  Created by Lujain Farghal on 21/08/1444 AH.
//

import UIKit
import FirebaseDatabase
import Firebase

class UserProfileViewController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate{

    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var username: UILabel!
    let ref = Database.database().reference()
    let user = Auth.auth().currentUser?.uid
    var dataPic : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        profilePhoto.layer.cornerRadius = (profilePhoto.frame.size.width) / 2
        profilePhoto.clipsToBounds = true
        profilePhoto.layer.borderWidth = 1.0
        profilePhoto.layer.borderColor = UIColor.lightGray.cgColor
        ref.child("User").child(user!).child("username").observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists(){
                self.username.text = snapshot.value as? String
            }
        }
        ref.child("User").child(user!).child("profilePicture").observe(.value) { snapshot in
            if snapshot.exists(){
                let image = snapshot.value as? String
                self.profilePhoto.load(url: image!)
            }
        }
        
    }
    
    @IBAction func editProfile(_ sender: Any) {
        showPhotoAlert()
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
                   dataPic = URLString
        profilePhoto.image = selectedPic
    }
}
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

