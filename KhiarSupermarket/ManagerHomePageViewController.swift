//
//  ManagerHomePageViewController.swift
//  KhiarSupermarket
//
//  Created by Lujain Farghal on 13/08/1444 AH.
//

import UIKit
import FirebaseDatabase

class ManagerHomePageViewController: UIViewController , UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DataCollectionProtocol , UISearchBarDelegate{
     
    @IBOutlet weak var productSearchBar: UISearchBar!
    @IBOutlet weak var productsCollectionView: UICollectionView!
    var arrOfProducts = [productCell]()
    var arrOfProductsSearch = [productCell]()
    var search = false
    var ref : DatabaseReference?
    var handler : DatabaseHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        productSearchBar.delegate=self
        ref = Database.database().reference().child("Products")
        handler = ref?.observe(.value , with: { (snapshot) in
            for products in snapshot.children.allObjects as! [DataSnapshot] {
                let productData = products.value as? [String:AnyObject]
                let productName = productData?["name"]
                let productPrice = productData?["price"]
                let productImage = productData?["image"]
                let productQuantity = productData?["quantity"]
                let productSection = productData?["section"]
                let productId = productData?["productId"]
                let productIngredients = productData?["ingredients"] as! [String]
                self.arrOfProducts.append(productCell(name: productName as! String, price: productPrice as! Double, image: productImage as! String, quantity: productQuantity as! Int, section: productSection as! String, id: productId as! String , ingredients: productIngredients))
            }
            self.productsCollectionView.reloadData()
        })
    }
    

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if search == false{
            return arrOfProducts.count
        }else{
            return arrOfProductsSearch.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productsCell", for: indexPath) as! ManagerProductsCollectionViewCell
        if search == false{
            let product = arrOfProducts[indexPath.row]
            cell.setProductData(productPrice: String(product.price), productName: product.name , productImage: product.image )
        }else{
            let product = arrOfProductsSearch[indexPath.row]
            cell.setProductData(productPrice: String(product.price), productName: product.name , productImage: product.image )
        }
        cell.layer.cornerCurve = .circular
        cell.layer.cornerRadius = 10
        cell.productIndex = indexPath
        cell.delegate=self
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width * 0.45, height: self.view.frame.width * 0.5)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    }
    
    func deleteData(index: Int) {
        let productKey = arrOfProducts[index].id
        let fbRef = Database.database().reference().child("Products").child(productKey)
        let alert = UIAlertController(title: "Delete", message: "Are you sure that you want to delete the product?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let deletelAction = UIAlertAction(title: "Delete", style: .destructive) { action in
            fbRef.removeValue()
            self.arrOfProducts.removeAll()
            self.productsCollectionView.reloadData()
        }
        alert.addAction(deletelAction)
        self.present(alert, animated: true)
    }
    
    func passData(index: Int){
        let productKey = arrOfProducts[index].id
        let vc = storyboard?.instantiateViewController(withIdentifier: "dtailsUI") as! ModifyProductViewController
        vc.name = arrOfProducts[index].name
        vc.url=arrOfProducts[index].image
        vc.price=arrOfProducts[index].price
        vc.quantity=arrOfProducts[index].quantity
        vc.section=arrOfProducts[index].section
        vc.productId=productKey
        present(vc, animated: true)
        arrOfProducts.removeAll()
//        productsCollectionView.reloadData()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty{
            search=true
            arrOfProductsSearch.removeAll()
            for product in arrOfProducts{
                if product.name.lowercased().contains(searchText.lowercased()){
                    arrOfProductsSearch.append(product)
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
}

struct productCell{
    var name : String
    var price : Double
    var image : String
    var quantity : Int
    var section : String
    var id : String
    var ingredients : [String]
}


