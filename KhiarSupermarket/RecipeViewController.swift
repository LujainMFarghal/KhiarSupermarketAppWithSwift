//
//  RecipeViewController.swift
//  KhiarSupermarket
//
//  Created by Lujain Farghal on 21/09/1444 AH.
//

import UIKit
import FirebaseDatabase
import Firebase
import FirebaseAuth
class RecipeViewController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout , recipeDetailsProtocol, recipeControllerCell, UISearchBarDelegate{
    

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var recipeViewController: UICollectionView!
    var arrOfRec = [recipeCell]()
    var arrOfFavRec = [String]()
    let ref = Database.database().reference()
    let userID = FirebaseAuth.Auth.auth().currentUser?.uid
    var arrOfRecpieSearch = [recipeCell]()
    var search = false
    override func viewDidLoad() {
        super.viewDidLoad()
        recipeViewController.delegate=self
        recipeViewController.dataSource=self
        searchBar.delegate=self
        ref.child("Recipe").observe(.value , with: { (snapshot) in
            for recipe in snapshot.children.allObjects as! [DataSnapshot] {
                let recipeData = recipe.value as? [String:AnyObject]
                let recipeName = recipeData?["name"] as! String
                let recipeImage = recipeData?["image"] as! String
                let recipeIngredients = recipeData?["ingredients"] as! [String]
                let recipeId = recipeData?["id"] as! String
                let recipeProcedure = recipeData?["procedure"] as! String

                self.arrOfRec.append(recipeCell(name: recipeName, image: recipeImage , ingredients: recipeIngredients , procedure: recipeProcedure, id: recipeId))
            }
            self.recipeViewController.reloadData()
        })
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if search==false{
            return arrOfRec.count
        }else{
            return arrOfRecpieSearch.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Recipe", for: indexPath) as! RecipeCollectionViewCell
        if search == false{
            let data = arrOfRec[indexPath.row]
            cell.setupRecipeCell(recipeName: data.name, recipeImage: data.image)
        }else{
            let data = arrOfRecpieSearch[indexPath.row]
            cell.setupRecipeCell(recipeName: data.name, recipeImage: data.image)
        }
        cell.layer.cornerCurve = .circular
        cell.layer.cornerRadius = 10
        cell.delegate=self
        cell.indexPath=indexPath
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width * 0.5, height: self.view.frame.width * 0.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 5)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        passDataToRecpieDetails(Index: indexPath.row, arrOfR: arrOfRec)
    }
    func passDataToRecpieDetails(Index: Int , arrOfR : [recipeCell]) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "RecipeDetailsUI") as! RecipeDetailsViewController
        vc.name=arrOfRec[Index].name
        vc.image=arrOfRec[Index].image
        for ing in arrOfRec[Index].ingredients{
            vc.ingredients.append(ing)
        }
        vc.procedure=arrOfR[Index].procedure
        vc.recpieId=arrOfR[Index].id
        present(vc, animated: true)
    }
    func addToFavoriteLis(index: Int) {
        if !arrOfFavRec.contains(arrOfRec[index].id){
            arrOfFavRec.append(arrOfRec[index].id)
            self.ref.child("User").child(self.userID!).child("Favorite").child("RecipesFavList").setValue(self.arrOfFavRec)
        }else{
            UtilityFunctions().simpleAlert(vc: self, title: "", message: "Recipe is already in your favorite list")
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if !searchText.isEmpty{
            search=true
            arrOfRecpieSearch.removeAll()
                for recpie in arrOfRec{
                    if recpie.name.lowercased().contains(searchText.lowercased()){
                        arrOfRecpieSearch.append(recpie)
            }
        }

        }else{
            search=false
            arrOfRecpieSearch.removeAll()
            arrOfRecpieSearch=arrOfRec
        }
        recipeViewController.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        search=false
        arrOfRecpieSearch.removeAll()
        searchBar.text=""
        recipeViewController.reloadData()
    }
            
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
struct recipeCell{
    let name : String
    let image : String
    let ingredients : [String]
    let procedure : String
    let id : String
}
