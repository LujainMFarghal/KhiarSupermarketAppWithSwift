//
//  SearchedProductViewController.swift
//  KhiarSupermarket
//
//  Created by Lujain Farghal on 22/09/1444 AH.
//

import UIKit
import Firebase
import FirebaseDatabase
class SearchedProductViewController: UIViewController, UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout , productsCV , productDetailsProtocol {
        
    
    @IBOutlet weak var collectionView: UICollectionView!
    var products = [productCell]()
    var searchedProductsIds = [String]()
    let ref = Database.database().reference()
    var productsID = [String]()
    let currentUserId = Auth.auth().currentUser?.uid
    var cartProducts = [Any]()
    var cartProduct = [String:Any]()
    var count = 0
    let orderQuantity = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate=self
        collectionView.dataSource=self
        ref.child("Products").observe(.value) { snapshot in
            for products in snapshot.children.allObjects as! [DataSnapshot] {
                let productData = products.value as? [String:AnyObject]
                let productName = productData?["name"] as! String
                let productPrice = productData?["price"] as! Double
                let productImage = productData?["image"] as! String
                let productQuantity = productData?["quantity"] as! Int
                let productSection = productData?["section"] as! String
                let productId = productData?["productId"] as! String
                let productIngredients = productData?["ingredients"] as! [String]
                
                for searchedProductsId in self.searchedProductsIds {
                    if searchedProductsId == productId{
                        self.products.append(productCell(name: productName, price: productPrice, image: productImage, quantity: productQuantity, section: productSection, id: productId, ingredients: productIngredients))
                    }
                }
            }
            self.collectionView.reloadData()
        }
        ref.child("User").child(currentUserId!).child("Cart").observe(.value) { snapshot in
            self.cartProducts.removeAll()
            for products in snapshot.children.allObjects as! [DataSnapshot] {
                let product = products.value as! [String:Any]
                let id = product["id"]
                let quantity = product["quantity"]
                self.cartProduct["id"] = id
                self.cartProduct["quantity"] = quantity
                self.cartProducts.append(self.cartProduct)
                self.count = self.cartProducts.count
            }
            var p = [String:Any]()
            for product in self.cartProducts {
                p = product as! [String:Any]
                self.productsID.append(p["id"] as! String)
            }
            
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchedProductsCell", for: indexPath) as! CustomerProductCollectionViewCell
        let data = products[indexPath.row]
        cell.setProductData(productPrice: String(data.price), productName: data.name, productImage: data.image)
        cell.delegate=self
        cell.productIndex=indexPath
        return cell
    }
    func addToCart(index: Int) {
        let productKey=self.products[index].id
        var q = 0
        var productsIngredients = ""
        ref.child("Products").child(productKey).child("ingredients").observe(.value, with: { snapshot in
            let productIngredients = snapshot.value as! NSArray
            productsIngredients = productIngredients.componentsJoined(by: ",")
        })
        Database.database().reference().child("User").child(currentUserId!).child("HealtInformation").child("allergens").observe(.value) { snapshot in

            var allergensIngredients = [String]()
            let allergens = snapshot.value as! NSArray
            let ingToCompare = productsIngredients.split(separator: ",")
            for allergen in allergens{
                for ingToCompare in ingToCompare {
                    if allergen as! String.SubSequence == ingToCompare {
                        allergensIngredients.append(allergen as! String)
                    }
                }
            }
        if !allergensIngredients.isEmpty{
                for allergensIngredient in allergensIngredients {
                    let alert = UIAlertController(title: "Allergens Warning", message: "Product contains \(allergensIngredient)\nDo you want to add it to the cart?", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    let addAction = UIAlertAction(title: "Add", style: .default) { alertAction in
                        
                        if self.productsID.contains(productKey) {
                                    self.ref.child("User").child(self.currentUserId!).child("Cart").observeSingleEvent(of: .value) { snapshot in
                                        let prd =  snapshot.value as! [[String:Any]]
                                        for (index, key_value) in prd.enumerated(){
                                            if key_value["id"] as? String == productKey{
                                                    q = key_value["quantity"] as! Int + self.orderQuantity
                                                    var updatedCartProduct = [String:Any]()
                                                    updatedCartProduct["id"] = productKey
                                                    updatedCartProduct["quantity"] = q
                                                   self.ref.child("User").child(self.currentUserId!).child("Cart").updateChildValues([String(index):updatedCartProduct])
                                            }
                                        }
                                     }
                                }else{
                                    self.cartProduct["id"] = productKey
                                    self.cartProduct["quantity"] = self.orderQuantity
                                    self.cartProducts.append(self.cartProduct)
                                    self.ref.child("User").child(self.currentUserId!).child("Cart").setValue(self.cartProducts)
                                }
                             
                    }
                    alert.addAction(addAction)
                    self.present(alert, animated: true)
                }
        }else{
            if self.productsID.contains(productKey){
                self.ref.child("User").child(self.currentUserId!).child("Cart").observeSingleEvent(of: .value) { snapshot in
                    let prd =  snapshot.value as! [[String:Any]]
                      for (index, key_value) in prd.enumerated(){
                          if key_value["id"] as? String == productKey{
                                q = key_value["quantity"] as! Int + self.orderQuantity
                                var updatedCartProduct = [String:Any]()
                                updatedCartProduct["id"] = productKey
                                updatedCartProduct["quantity"] = q
                                self.ref.child("User").child(self.currentUserId!).child("Cart").updateChildValues([String(index):updatedCartProduct])
                    }
                }
            }
            }else{
                self.cartProduct["id"] = productKey
                self.cartProduct["quantity"] = self.orderQuantity
                self.cartProducts.append(self.cartProduct)
                self.ref.child("User").child(self.currentUserId!).child("Cart").setValue(self.cartProducts)
                
            }
        }
    }


    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let productIndex = indexPath.row
        passDataToProductDetails(Index: productIndex, arrOfP: products)
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
    
    
}
