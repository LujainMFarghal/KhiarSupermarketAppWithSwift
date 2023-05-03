//
//  FavoriteViewController.swift
//  KhiarSupermarket
//
//  Created by Lujain Farghal on 27/09/1444 AH.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
class FavoriteViewController: UIViewController , UITableViewDelegate , UITableViewDataSource{

    @IBOutlet weak var favoriteSegmants: UISegmentedControl!
    @IBOutlet weak var favoriteTableView: UITableView!
    var segmant = "products"
    var favProducts = [productCell]()
    var favRecpies = [recipeCell]()
    var usersFavRecpies = [String]()
    var usersFavProducts = [String]()
    let ref = Database.database().reference()
    let userID = Auth.auth().currentUser?.uid
    override func viewDidLoad() {
        super.viewDidLoad()
        favoriteTableView.delegate=self
        favoriteTableView.dataSource=self

        ref.child("User").child(userID!).child("Favorite").child("RecipesFavList").observe(.value) { snapshot in
            self.favRecpies.removeAll()
            guard let favRcps = snapshot.value as? [String] else {return}
            for favRcp in favRcps{
            self.ref.child("Recipe").observe(.value) { snapshot in
                for recpies in snapshot.children.allObjects as! [DataSnapshot]{
                    let rcpData = recpies.value as! [String:AnyObject]
                    guard let name = rcpData["name"] as? String else { return }
                    guard let image = rcpData["image"] as? String else { return }
                    guard let ingredients = rcpData["ingredients"] as? [String] else { return }
                    guard let procedure = rcpData["procedure"] as? String  else { return }
                    guard let id = rcpData["id"] as? String else { return }
                    if favRcp == id{
                        self.favRecpies.append(recipeCell(name: name, image: image, ingredients: ingredients, procedure: procedure, id: id))
                    }
                }
                self.favoriteTableView.reloadData()
            }
            }
        }

        ref.child("User").child(userID!).child("Favorite").child("ProductsFavList").observe(.value) { snapshot in
            self.favProducts.removeAll()
            guard let favPrds = snapshot.value as? [String] else {return}
            for favPrd in favPrds{
            self.ref.child("Products").observe(.value) { snapshot in
                for products in snapshot.children.allObjects as! [DataSnapshot]{
                    let prdData = products.value as! [String:AnyObject]
                    guard let name = prdData["name"] as? String else { return }
                    guard let image = prdData["image"] as? String else { return }
                    guard let ingredients = prdData["ingredients"] as? [String] else { return }
                    guard let price = prdData["price"] as? Double else { return }
                    guard let quantity = prdData["quantity"] as? Int else { return }
                    guard let productId = prdData["productId"] as? String else { return }
                    guard let section = prdData["section"] as? String else { return }
                    if favPrd == productId{
                        self.favProducts.append(productCell(name: name, price: price, image: image, quantity: quantity, section: section, id: productId, ingredients: ingredients))
                    }
                }
                self.favoriteTableView.reloadData()
            }
            }
        }
        ref.child("User").child(userID!).child("Favorite").child("ProductsFavList").observe(.childRemoved) { snapshot in
            self.ref.child("User").child(self.userID!).child("Favorite").child("ProductsFavList").setValue(self.usersFavProducts)
        }
        ref.child("User").child(userID!).child("Favorite").child("RecipesFavList").observe(.childRemoved) { snapshot in
            self.ref.child("User").child(self.userID!).child("Favorite").child("RecipesFavList").setValue(self.usersFavRecpies)
        }
}
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmant == "products"{
            return favProducts.count
        }else{
            return favRecpies.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteTabelCell", for: indexPath) as! UserTableViewCell
        if segmant == "products"{
            let data = favProducts[indexPath.row]
            cell.setFavCell(favName: data.name, favImage: data.image)
        }else{
            let data = favRecpies[indexPath.row]
            cell.setFavCell(favName: data.name, favImage: data.image)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if segmant == "products"{
            self.usersFavProducts.removeAll()
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
                self.ref.child("User").child(self.userID!).child("Favorite").child("ProductsFavList").observeSingleEvent(of: .value) { snapshot in
                    let favPrd = snapshot.value as! [String]
                    for (index , key_value) in favPrd.enumerated() {
                        if key_value == self.favProducts[indexPath.row].id{
                            self.ref.child("User").child(self.userID!).child("Favorite").child("ProductsFavList").child(String(index)).removeValue()
                        }else{
                            self.usersFavProducts.append(key_value)
                        }
                    }
                }
                completionHandler(true)
            }
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }else{
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
                self.usersFavRecpies.removeAll()
                    self.ref.child("User").child(self.userID!).child("Favorite").child("RecipesFavList").observeSingleEvent(of: .value) { snapshot in
                        let favRcp = snapshot.value as! [String]
                        for (index , key_value) in favRcp.enumerated(){
                            if key_value == self.favRecpies[indexPath.row].id{
                                self.ref.child("User").child(self.userID!).child("Favorite").child("RecipesFavList").child(String(index)).removeValue()
                            }else{
                                self.usersFavRecpies.append(key_value)
                            }
                        }
                    }
                completionHandler(true)
            }
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
    }
    @IBAction func segmantChanged(_ sender: Any) {
        if favoriteSegmants.selectedSegmentIndex == 0 {
            self.segmant = "products"
            favoriteTableView.reloadData()
        }else{
            self.segmant = "recpies"
            favoriteTableView.reloadData()
        }
        
    }
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

