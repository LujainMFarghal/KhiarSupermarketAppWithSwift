//
//  HomePageViewController.swift
//  KhiarSupermarket
//
//  Created by Lujain Farghal on 10/08/1444 AH.
//

import UIKit
import FirebaseDatabase
import Firebase
import FirebaseAuth

class HomePageViewController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout , productDetailsProtocol , recipeDetailsProtocol{

    
    @IBOutlet weak var latestRecipesCollectionView: UICollectionView!
    @IBOutlet weak var latestProductsCollectionView: UICollectionView!
    @IBOutlet weak var vegetrianPage: UIButton!
    @IBOutlet weak var KetoPage: UIButton!
    @IBOutlet weak var sugerFreePage: UIButton!
    let ref = Database.database().reference()
    var latestProducts = [productCell]()
    var latesrRecipes = [recipeCell]()

    override func viewDidLoad() {
        super.viewDidLoad()
        vegetrianPage.imageView?.contentMode = .scaleAspectFill
        KetoPage.imageView?.contentMode = .scaleAspectFill
        sugerFreePage.imageView?.contentMode = .scaleAspectFill
        latestProductsCollectionView.delegate=self
        latestProductsCollectionView.dataSource=self
        latestRecipesCollectionView.delegate=self
        latestRecipesCollectionView.dataSource=self
        ref.child("Products").queryLimited(toLast: 3).observe(.value) { snapshot in
            for products in snapshot.children.allObjects as! [DataSnapshot] {
                let productData = products.value as? [String:AnyObject]
                let productName = productData?["name"] as! String
                let productPrice = productData?["price"] as! Double
                let productImage = productData?["image"] as! String
                let productQuantity = productData?["quantity"] as! Int
                let productSection = productData?["section"] as! String
                let productId = productData?["productId"] as! String
                let productIngredients = productData?["ingredients"] as! [String]
                
                self.latestProducts.append(productCell(name: productName , price: productPrice , image: productImage , quantity: productQuantity , section: productSection , id: productId , ingredients: productIngredients))
            }
            self.latestProductsCollectionView.reloadData()
        }
        ref.child("Recipe").queryLimited(toLast: 3).observe(.value) { snapshot in
            for recipe in snapshot.children.allObjects as! [DataSnapshot] {
                let recipeData = recipe.value as? [String:AnyObject]
                let recipeName = recipeData?["name"] as! String
                let recipeImage = recipeData?["image"] as! String
                let recipeIngredients = recipeData?["ingredients"] as! [String]
                let recipeId = recipeData?["id"] as! String
                let recipeProcedure = recipeData?["procedure"] as! String

                self.latesrRecipes.append(recipeCell(name: recipeName, image: recipeImage , ingredients: recipeIngredients , procedure: recipeProcedure, id: recipeId))
            }
            self.latestRecipesCollectionView.reloadData()
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == latestProductsCollectionView{
        return latestProducts.count
        }else{
            return latesrRecipes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == latestProductsCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "latestProductsCell", for: indexPath) as! CustomerProductCollectionViewCell
            let data = latestProducts[indexPath.row]
            cell.setLatestProductData(productPrice: String(data.price), productName: data.name, productImage: data.image)
            cell.layer.cornerCurve = .circular
            cell.layer.cornerRadius = 10
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "latestRecipesCell", for: indexPath) as! RecipeCollectionViewCell
            let data = latesrRecipes[indexPath.row]
            cell.setupRecipeCell(recipeName: data.name, recipeImage: data.image)
            cell.layer.cornerCurve = .circular
            cell.layer.cornerRadius = 10
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == latestProductsCollectionView{
            return CGSize(width: self.view.frame.width * 0.4, height: self.view.frame.width * 0.35)

        }else{
            return CGSize(width: self.view.frame.width * 0.4, height: self.view.frame.width * 0.35)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == latestProductsCollectionView{
            return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        }else{
            return UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)

        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == latestProductsCollectionView{
            passDataToProductDetails(Index: indexPath.row, arrOfP: latestProducts)
        }else{
            passDataToRecpieDetails(Index: indexPath.row, arrOfR: latesrRecipes)
        }

    }
    func passDataToProductDetails(Index: Int, arrOfP: [productCell]) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ProductDetailsUI") as! ProductDetailsViewController
        let ing = arrOfP[Index].ingredients.joined(separator: ",")
        vc.name=arrOfP[Index].name
        vc.price=arrOfP[Index].price
        vc.imageUrl=arrOfP[Index].image
        vc.ingredients=ing
        vc.productId=arrOfP[Index].id
        vc.productQuantity=arrOfP[Index].quantity
        present(vc, animated: true)
    }
    func passDataToRecpieDetails(Index: Int, arrOfR: [recipeCell]) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "RecipeDetailsUI") as! RecipeDetailsViewController
        vc.name=latesrRecipes[Index].name
        vc.image=latesrRecipes[Index].image
        for ing in latesrRecipes[Index].ingredients{
            vc.ingredients.append(ing)
        }
        vc.procedure=arrOfR[Index].procedure
        vc.recpieId=arrOfR[Index].id
        present(vc, animated: true)
    }

}


