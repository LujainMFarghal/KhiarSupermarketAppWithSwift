//
//  UserRecipeViewController.swift
//  KhiarSupermarket
//
//  Created by Lujain Farghal on 27/09/1444 AH.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
class UserRecipeViewController: UIViewController , UITableViewDelegate , UITableViewDataSource{

    @IBOutlet weak var userRecipeTableView: UITableView!
    var arrOfRec = [UserRecipeCell]()
    let ref = Database.database().reference()
    let userID = Auth.auth().currentUser?.uid
    override func viewDidLoad() {
        super.viewDidLoad()
        userRecipeTableView.delegate=self
        userRecipeTableView.dataSource=self
        ref.child("Recipe").observe(.value) { snapshot in
            self.arrOfRec.removeAll()
            for recipes in snapshot.children.allObjects as! [DataSnapshot]{
                let recipeData = recipes.value as? [String:AnyObject]
                guard let name = recipeData?["name"] as? String else{ return }
                guard let userid = recipeData?["userId"] as? String else{ return }
                guard let image = recipeData?["image"] as? String else { return }
                guard let id = recipeData?["id"] as? String else { return }
                
                if userid == self.userID{
                    self.arrOfRec.append(UserRecipeCell(image: image, name: name, id: id))
                }

            }
            self.userRecipeTableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOfRec.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userRecipiesCell") as! UserTableViewCell
        let data = arrOfRec[indexPath.row]
        cell.setCell(userRecipeName: data.name, userRecipeImage: data.image)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true)
    }
    @IBAction func addNewRecipe(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "addNewRecipeVC") as! AddRecipeViewController
        self.present(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler -> Void in
            self.ref.child("Recipe").observeSingleEvent(of: .value) { snapshot in
                for rcp in snapshot.children.allObjects as! [DataSnapshot]{
                    let rcpData = rcp.value as! [String:Any]
                    let id = rcpData["id"] as! String
                    if id == self.arrOfRec[indexPath.row].id{
                        self.ref.child("Recipe").child(id).removeValue()
                    }
                }
            }
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
struct UserRecipeCell{
    let image : String
    let name : String
    let id : String
}
