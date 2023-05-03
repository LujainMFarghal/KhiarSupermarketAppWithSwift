//
//  CustomerProductCollectionViewCell.swift
//  KhiarSupermarket
//
//  Created by Lujain Farghal on 26/08/1444 AH.
//

import UIKit
import FirebaseDatabase
protocol productsCV{
    func addToCart(index:Int)
}
class CustomerProductCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    var delegate : productsCV?
    var productIndex : IndexPath?
    
    @IBOutlet weak var latestPrice: UILabel!
    @IBOutlet weak var latestName: UILabel!
    @IBOutlet weak var latestImage: UIImageView!
    func setProductData(productPrice:String, productName:String , productImage:String){
        self.productName.text = productName
        self.productPrice.text = "\(productPrice) RS"
        self.productImage.load(url: productImage)
    }
    func setLatestProductData(productPrice:String, productName:String , productImage:String){
        self.latestName.text = productName
        self.latestPrice.text = "\(productPrice) RS"
        self.latestImage.load(url: productImage)
    }
    @IBAction func moreButton(_ sender: Any) {
        delegate?.addToCart(index: (productIndex?.row)! )
    }
}

