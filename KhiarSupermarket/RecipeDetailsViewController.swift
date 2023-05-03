//
//  RecipeDetailsViewController.swift
//  KhiarSupermarket
//
//  Created by Lujain Farghal on 22/09/1444 AH.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
protocol recipeDetailsProtocol{
    func passDataToRecpieDetails(Index:Int,arrOfR : [recipeCell])
}
class RecipeDetailsViewController: UIViewController , UITableViewDelegate , UITableViewDataSource{

    @IBOutlet weak var recipeProcedure: UITextView!
    @IBOutlet weak var ingredientsTableView: UITableView!
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var heartButton: UIButton!
    var name = ""
    var procedure = ""
    var image = ""
    var ingredients = [String]()
    var recpieId = ""
    let ref = Database.database().reference()
    var delegate : recipeDetailsProtocol?
    var productIndex : IndexPath?
    var arrOfR : [recipeCell]?
    let userID = FirebaseAuth.Auth.auth().currentUser?.uid
    var arrOfFavRec = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        ingredientsTableView.delegate=self
        ingredientsTableView.dataSource=self
        delegate?.passDataToRecpieDetails(Index: (productIndex?.row )!, arrOfR: arrOfR!)
        recipeProcedure.layer.borderWidth=0.4
        recipeProcedure.layer.cornerRadius=3
        recipeProcedure.layer.borderColor=UIColor.lightGray.cgColor
        recipeProcedure.text=procedure
        recipeName.text=name
        recipeImage.load(url: image)
        ref.child("User").child(userID!).child("Favorite").child("RecipesFavList").observe(.value) { snapshot in
            self.arrOfFavRec.removeAll()
            guard let recipe = snapshot.value as? [String] else{
                return
            }
            for recipeId in recipe{
                self.arrOfFavRec.append(recipeId)
            }
         }
    }
    
    @IBAction func addToFavorite(_ sender: Any) {
        if !arrOfFavRec.contains(recpieId){
            arrOfFavRec.append(recpieId)
            self.ref.child("User").child(self.userID!).child("Favorite").child("RecipesFavList").setValue(self.arrOfFavRec)
            heartButton.setImage(UIImage(systemName: "heart.fill"), for: UIControl.State.normal)
            
        }else{
            UtilityFunctions().simpleAlert(vc: self, title: "", message: "Recipe is already in your favorite list")
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ingredients.count
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var product = [String]()
        let searchForProduct = UIContextualAction(style: .normal, title: "Search") { action, view, completionHandler -> Void in
            self.ref.child("Products").observe(.value) { snaphsot in
                for products in snaphsot.children.allObjects as! [DataSnapshot]{
                  let productData = products.value as? [String:AnyObject]
                    let productName = productData?["name"] as! String
                    let productId = productData?["productId"] as! String
                    if productName.lowercased().contains(self.ingredients[indexPath.row].lowercased()) {
                        product.append(productId)
                       
                    }
                }
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "searchedProductUI") as! SearchedProductViewController
                vc.searchedProductsIds = product
                self.present(vc, animated: true)
            }
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [searchForProduct])
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeDetailsCell", for: indexPath)
        cell.textLabel?.text=ingredients[indexPath.row]
        return cell
    }
    

    
}
