//
//  CartViewController.swift
//  KhiarSupermarket
//
//  Created by Lujain Farghal on 10/09/1444 AH.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
class CartViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, tableCell{
    
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var cartTableView: UITableView!
    var products = [productTableCell]()
    var productsInCart = [productTableCell]()
    let userId = Auth.auth().currentUser?.uid
    let ref = Database.database().reference()
    var productsID = [String]()
    var cartProducts = [[String:Any]]()
    var cartProduct = [String:Any]()
    var price = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
        cartTableView.delegate=self
        cartTableView.dataSource=self

        ref.child("Products").observe(.value , with: { (snapshot) in
            self.products.removeAll()
            for products in snapshot.children.allObjects as! [DataSnapshot] {
                let productData = products.value as? [String:AnyObject]
                let productName = productData?["name"] as! String
                let productPrice = productData?["price"] as! Double
                let productImage = productData?["image"] as! String
                let productQuantity = productData?["quantity"] as! Int
                let productId = productData?["productId"] as! String
                self.products.append(productTableCell(name: productName , price: productPrice , image: productImage , quantity: productQuantity , id: productId))
            }
        })
        ref.child("User").child(userId!).child("Cart").observe(.value) { snapshot in
            self.productsInCart.removeAll()
            for products in snapshot.children.allObjects as! [DataSnapshot] {
                let product = products.value as! [String:Any]
                let id = product["id"]
                let quantity = product["quantity"]
                
                for product in self.products.enumerated() {
                    if id as! String==product.element.id{
                        self.productsInCart.append(productTableCell(name: product.element.name, price: product.element.price, image: product.element.image, quantity: quantity as! Int, id: id as! String))
                        self.price+=(product.element.price * (quantity as! Double))
                    }
                }
                self.totalPrice.text = "\(self.price) RS"
            }
            self.cartTableView.reloadData()
        }
        ref.child("User").child(userId!).child("Cart").observe(.childRemoved) { snapshot in
            self.ref.child("User").child(self.userId!).child("Cart").setValue(self.cartProducts)
        }
        ref.child("User").child(userId!).child("Cart").observe(.childAdded) { datasnapshot in
            self.ref.child("User").child(self.userId!).child("Cart").observe(.value) { snapshot in
                self.cartProducts.removeAll()
                for products in snapshot.children.allObjects as! [DataSnapshot] {
                let product = products.value as! [String:Any]
                let id = product["id"]
                let quantity = product["quantity"]
                self.cartProduct["id"] = id
                self.cartProduct["quantity"] = quantity
                self.cartProducts.append(self.cartProduct)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsInCart.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cartProductsCell") as! CartTableViewCell
        let data = productsInCart[indexPath.row]
        cell.setCell(productQuantity: data.quantity, productPrice: data.price, productName: data.name, productImage: data.image)
        cell.delegate=self
        cell.productIndex=indexPath
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler -> Void in
            self.ref.child("User").child(self.userId!).child("Cart").observeSingleEvent(of: .value) { snapshot in
                let prd =  snapshot.value as! [[String:Any]]
                for (index, key_value) in prd.enumerated(){
                    for cartProduct in self.cartProducts {
                        if key_value["id"] as? String == self.productsInCart[indexPath.row].id && key_value["id"] as? String == cartProduct["id"] as? String{
                            self.cartProducts.remove(at: index)
                            self.ref.child("User").child(self.userId!).child("Cart").removeValue()
                        }
                    }
                }
            }
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    func quantityIncrement(index: Int) {
        var updatedCartProduct = [String:Any]()
        updatedCartProduct["id"] = productsInCart[index].id
        updatedCartProduct["quantity"] = productsInCart[index].quantity + 1
        ref.child("User").child(userId!).child("Cart").updateChildValues([String(index):updatedCartProduct])
        
    }
    
    func quantityDecrement(index: Int) {
        var updatedCartProduct = [String:Any]()
        updatedCartProduct["id"] = productsInCart[index].id
        updatedCartProduct["quantity"] = productsInCart[index].quantity - 1
        ref.child("User").child(userId!).child("Cart").updateChildValues([String(index):updatedCartProduct])
    }
    
    @IBAction func checkout(_ sender: Any) {
        for product in self.productsInCart{
            for (index,key_value) in products.enumerated(){
                if product.id == key_value.id{
                    self.ref.child("Products").child(key_value.id).updateChildValues(["quantity" : (key_value.quantity - product.quantity)])
                }
            }
        }
        cartProducts.removeAll()
        ref.child("User").child(userId!).child("Cart").removeValue()
        totalPrice.text="\(0.0) RS"
    }
}
struct productTableCell{
    var name : String
    var price : Double
    var image : String
    var quantity : Int
    var id : String
}
