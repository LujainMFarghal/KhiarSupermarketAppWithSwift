//
//  ProductDetailsViewController.swift
//  KhiarSupermarket
//
//  Created by Lujain Farghal on 02/09/1444 AH.
//

import UIKit
import Firebase
import FirebaseDatabase
protocol productDetailsProtocol{
    func passDataToProductDetails(Index:Int,arrOfP : [productCell])
}

class ProductDetailsViewController: UIViewController {

    @IBOutlet weak var stepperView: UIView!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var productIngredients: UITextView!
    var imageUrl = ""
    var name = ""
    var price = 0.0
    var ingredients = ""
    var orderQuantity = 1
    var productQuantity = 0
    var productId = ""
    var delegate : productDetailsProtocol?
    var productIndex : IndexPath?
    var arrOfP : [productCell]?
    var favProducts = [String]()
    var cartProducts = [Any]()
    var cartProduct = [String:Any]()
    let ref = Database.database().reference()
    let currentUserId = Auth.auth().currentUser?.uid
    var productsID = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate?.passDataToProductDetails(Index: (productIndex?.row )!, arrOfP: arrOfP!)
        productImage.load(url: imageUrl)
        productName.text=name
        productPrice.text=String(price)
        productIngredients.text=ingredients
        quantity.text=String(orderQuantity)
        stepperView.layer.cornerRadius=20
        
        ref.child("User").child(currentUserId!).child("Favorite").child("ProductsFavList").observe(.value) { snapshot in
            guard let product = snapshot.value as? [String] else{
                return
            }
            for productId in product{
                self.favProducts.append(productId)
            }
         }
        ref.child("User").child(currentUserId!).child("Cart").observe(.value) { snapshot in
            for products in snapshot.children.allObjects as! [DataSnapshot] {
                let product = products.value as! [String:Any]
                let id = product["id"]
                let quantity = product["quantity"]
                self.cartProduct["id"] = id
                self.cartProduct["quantity"] = quantity
                self.cartProducts.append(self.cartProduct)
            }
            var p = [String:Any]()
            for product in self.cartProducts {
                p = product as! [String:Any]
                self.productsID.append(p["id"] as! String)
            }
            
        }

    }
    
    @IBAction func quantityPlus(_ sender: Any) {
        if  orderQuantity <= productQuantity{
            orderQuantity += 1
        }
        quantity.text=String(orderQuantity)
    }
    @IBAction func quantityMinus(_ sender: Any) {
        if orderQuantity >= 1 {
            orderQuantity -= 1
        }
        quantity.text=String(orderQuantity)
    }
    
    @IBAction func addToCart(_ sender: Any) {
        var q = 0
        var productsIngredients = ""
        ref.child("Products").child(productId).child("ingredients").observe(.value, with: { snapshot in
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
                        
                        if self.productsID.contains(self.productId) {
                                    self.ref.child("User").child(self.currentUserId!).child("Cart").observeSingleEvent(of: .value) { snapshot in
                                        let prd =  snapshot.value as! [[String:Any]]
                                        for (index, key_value) in prd.enumerated(){
                                            if key_value["id"] as! String == self.productId{
                                                    q = key_value["quantity"] as! Int + self.orderQuantity
                                                    var updatedCartProduct = [String:Any]()
                                                    updatedCartProduct["id"] = self.productId
                                                    updatedCartProduct["quantity"] = q
                                                   self.ref.child("User").child(self.currentUserId!).child("Cart").updateChildValues([String(index):updatedCartProduct])
                                                    self.dismiss(animated: true)
                                            }
                                        }
                                     }
                                }else{
                                    self.cartProduct["id"] = self.productId
                                    self.cartProduct["quantity"] = self.orderQuantity
                                    self.cartProducts.append(self.cartProduct)
                                    self.ref.child("User").child(self.currentUserId!).child("Cart").setValue(self.cartProducts)
                                    self.dismiss(animated: true)
                                }
                             
                    }
                    alert.addAction(addAction)
                    self.present(alert, animated: true)
                }
        }else{
            if self.productsID.contains(self.productId){
                self.ref.child("User").child(self.currentUserId!).child("Cart").observeSingleEvent(of: .value) { snapshot in
                    let prd =  snapshot.value as! [[String:Any]]
                      for (index, key_value) in prd.enumerated(){
                            if key_value["id"] as! String == self.productId{
                                q = key_value["quantity"] as! Int + self.orderQuantity
                                var updatedCartProduct = [String:Any]()
                                updatedCartProduct["id"] = self.productId
                                updatedCartProduct["quantity"] = q
                                self.ref.child("User").child(self.currentUserId!).child("Cart").updateChildValues([String(index):updatedCartProduct])
                                self.dismiss(animated: true)
                    }
                }
            }
            }else{
                self.cartProduct["id"] = self.productId
                self.cartProduct["quantity"] = self.orderQuantity
                self.cartProducts.append(self.cartProduct)
                self.ref.child("User").child(self.currentUserId!).child("Cart").setValue(self.cartProducts)
                self.dismiss(animated: true)
            }
        }
    }
}
    
    @IBAction func addToFavorite(_ sender: Any) {
        if !favProducts.contains(productId){
            favProducts.append(self.productId)
            ref.child("User").child(currentUserId!).child("Favorite").child("ProductsFavList").setValue(self.favProducts)
            dismiss(animated: true)
        }else{
            UtilityFunctions().simpleAlertII(vc: self, title: "", message: "Product is already in your favorite list")
        }
    }
}

struct productInCart{
    var id : String
    var quantity : Int
}
