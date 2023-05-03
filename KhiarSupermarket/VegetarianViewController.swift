//
//  VegetarianViewController.swift
//  KhiarSupermarket
//
//  Created by Lujain Farghal on 01/09/1444 AH.
//

import UIKit
import Firebase
import FirebaseDatabase

class VegetarianViewController: UIViewController, UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, productsCV , productDetailsProtocol , UISearchBarDelegate{
    
    @IBOutlet weak var productsCollectionView: UICollectionView!
    @IBOutlet weak var productsSegments: UISegmentedControl!
    var arrOfProducts = [productCell]()
    var ref = Database.database().reference()
    var vegetarianAvoid = [String]()
    var arrOfCanned = [productCell]()
    var arrOfFresh = [productCell]()
    var arrOfFrozen = [productCell]()
    var productSection = "All"
    var arrOfAllergy = ["milk","egg","peanut","soy","wheat","nut"]
    public var notForVegetarian = [String]()
    @IBOutlet weak var productSearchBar: UISearchBar!
    var arrOfProductsSearch = [productCell]()
    var search = false
    var cartProducts = [Any]()
    var cartProduct = [String:Any]()
    let orderQuantity = 1
    var productsID = [String]()
    var count = 0
    let currentUserId = Auth.auth().currentUser?.uid

    override func viewDidLoad() {
        super.viewDidLoad()
        productSearchBar.delegate=self
        productsCollectionView.dataSource=self
        productsCollectionView.delegate=self
        if let path = Bundle.main.path(forResource: "vegetarianAvoid", ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path, encoding: .utf8)
                vegetarianAvoid = data.components(separatedBy: ",")
            } catch {
                print(error)
            }
        }
        ref.child("Products").observe(.value , with: { (snapshot) in

            for products in snapshot.children.allObjects as! [DataSnapshot] {
                let productData = products.value as? [String:AnyObject]
                let productName = productData?["name"] as! String
                let productPrice = productData?["price"] as! Double
                let productImage = productData?["image"] as! String
                let productQuantity = productData?["quantity"] as! Int
                let productSection = productData?["section"] as! String
                let productId = productData?["productId"] as! String
                let productIngredients = productData?["ingredients"] as! [String]

                for notKeto in self.vegetarianAvoid {
                    if productIngredients.contains(notKeto){
                        self.notForVegetarian.append(productName)
                    }
                }
                if !self.notForVegetarian.contains(productName) {
                    self.arrOfProducts.append(productCell(name: productName , price: productPrice , image: productImage , quantity: productQuantity , section: productSection , id: productId , ingredients: productIngredients))
                }
                
            }
           self.productsCollectionView.reloadData()
        })
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
                print(self.count)
            }
            var p = [String:Any]()
            for product in self.cartProducts {
                p = product as! [String:Any]
                self.productsID.append(p["id"] as! String)
            }
            
        }

    }
    @IBAction func productsSegmentsChanged(_ sender: Any) {
        if productsSegments.selectedSegmentIndex==1{
            arrOfCanned.removeAll()
            for product in arrOfProducts {
                if product.section == "Canned"{
                    arrOfCanned.append(product)
                }
            }
            productSection="Canned"
            productsCollectionView.reloadData()
            
        }else if productsSegments.selectedSegmentIndex==2{
            arrOfFrozen.removeAll()
            for product in arrOfProducts {
                if product.section == "Frozen"{
                    arrOfFrozen.append(product)
                }
            }
            productSection="Frozen"
            productsCollectionView.reloadData()

        }else if productsSegments.selectedSegmentIndex==3{
            arrOfFresh.removeAll()
            for product in arrOfProducts {
                if product.section == "Fresh"{
                    arrOfFresh.append(product)
                }
            }
            productSection="Fresh"
            productsCollectionView.reloadData()
        }else{
            productSection="All"
            productsCollectionView.reloadData()
            }
    }
    func addToCart(index: Int) {
        var q = 0
        var productKey : String?
        if productSection == "All"{
            productKey = arrOfProducts[index].id
        }else if productSection == "Canned"{
            productKey = arrOfCanned[index].id
        }else if productSection == "Frozen"{
            productKey = arrOfFrozen[index].id
        }else {
            productKey = arrOfFresh[index].id
        }
        let currentUser = Auth.auth().currentUser?.uid
        var productsIngredients = ""
        ref.child("Products").child(productKey!).child("ingredients").observe(.value, with: { snapshot in
            let productIngredients = snapshot.value as! NSArray
            productsIngredients = productIngredients.componentsJoined(by: ",")
        })
        Database.database().reference().child("User").child(currentUser!).child("HealtInformation").child("allergens").observe(.value) { snapshot in
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
                        
                        if self.productsID.contains(productKey!) {
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
            if self.productsID.contains(productKey!){
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
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if search == false{
            if productSection == "All"{
                return arrOfProducts.count
            }else if productSection == "Canned"{
                return arrOfCanned.count
            }else if productSection == "Frozen"{
                return arrOfFrozen.count
            }else{
                return arrOfFresh.count
            }
        }else{
            return arrOfProductsSearch.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VegetarianProductsCell", for: indexPath) as! CustomerProductCollectionViewCell
        if search == false{
            if productSection == "All"{
                let product = arrOfProducts[indexPath.row]
                cell.setProductData(productPrice: String(product.price), productName: product.name , productImage: product.image )
            }else if productSection == "Canned"{
                let product = arrOfCanned[indexPath.row]
                cell.setProductData(productPrice: String(product.price), productName: product.name , productImage: product.image )
            }else if productSection == "Frozen"{
                let product = arrOfFrozen[indexPath.row]
                cell.setProductData(productPrice: String(product.price), productName: product.name , productImage: product.image )
            }else{
                let product = arrOfFresh[indexPath.row]
                cell.setProductData(productPrice: String(product.price), productName: product.name , productImage: product.image )
            }
        }else{
            let product = arrOfProductsSearch[indexPath.row]
            cell.setProductData(productPrice: String(product.price), productName: product.name , productImage: product.image )
        }
        cell.productIndex = indexPath
        cell.delegate=self
        cell.layer.cornerCurve = .circular
        cell.layer.cornerRadius = 10
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width * 0.5, height: self.view.frame.width * 0.5)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 5)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if !searchText.isEmpty{
            search=true
            arrOfProductsSearch.removeAll()
            if productSection == "All"{
                for product in arrOfProducts{
                    if product.name.lowercased().contains(searchText.lowercased()){
                        arrOfProductsSearch.append(product)
                    }
                }
            }else if productSection == "Canned"{
                for product in arrOfCanned{
                    if product.name.lowercased().contains(searchText.lowercased()){
                        arrOfProductsSearch.append(product)
                    }
                }
            }else if productSection == "Frozen"{
                for product in arrOfFrozen{
                    if product.name.lowercased().contains(searchText.lowercased()){
                        arrOfProductsSearch.append(product)
                    }
                }
            }else{
                for product in arrOfFresh{
                    if product.name.lowercased().contains(searchText.lowercased()){
                        arrOfProductsSearch.append(product)
                    }
                }
            }

        }else{
            search=false
            arrOfProductsSearch.removeAll()
            arrOfProductsSearch=arrOfProducts
        }
        productsCollectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        search=false
        arrOfProductsSearch.removeAll()
        searchBar.text=""
        productsCollectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                
        let productIndex = indexPath.row
        if productSection == "All"{
            passDataToProductDetails(Index: productIndex, arrOfP: arrOfProducts)
        }else if productSection == "Canned"{
            passDataToProductDetails(Index: productIndex, arrOfP: arrOfCanned)

        }else if productSection == "Frozen"{
            passDataToProductDetails(Index: productIndex, arrOfP: arrOfFrozen)

        }else {
            passDataToProductDetails(Index: productIndex, arrOfP: arrOfFresh)
        }
        
     }
    func passDataToProductDetails(Index: Int , arrOfP : [productCell]) {
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
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
    


