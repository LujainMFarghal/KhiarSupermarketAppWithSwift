//
//  ManagerProductsCollectionViewCell.swift
//  KhiarSupermarket
//
//  Created by Lujain Farghal on 13/08/1444 AH.
//

import UIKit

protocol DataCollectionProtocol{
    func passData(index: Int)
    func deleteData(index: Int)
}

class ManagerProductsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    
    var delegate : DataCollectionProtocol?
    var productIndex : IndexPath?
    
    func setProductData(productPrice:String, productName:String , productImage:String){
        self.productName.text = productName
        self.productPrice.text = productPrice
        self.productImage.load(url: productImage)
        
    }
    @IBAction func modifyProduct(_ sender: Any) {
        delegate?.passData(index: productIndex!.row)
    }
    @IBAction func deleteProduct(_ sender: Any) {
        delegate?.deleteData(index: productIndex!.row)
    }
}
extension UIImageView {
    func load(url: String) {
        guard let urlString = URL(string: url) else{
            return
        }
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: urlString) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
