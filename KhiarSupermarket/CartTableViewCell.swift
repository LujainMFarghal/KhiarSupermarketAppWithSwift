//
//  CartTableViewCell.swift
//  KhiarSupermarket
//
//  Created by Lujain Farghal on 11/09/1444 AH.
//

import UIKit
protocol tableCell{
    func quantityIncrement(index:Int)
    func quantityDecrement(index:Int)
}
class CartTableViewCell: UITableViewCell {
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productQuantity: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var stepper: UIView!
    var delegate : tableCell?
    var productIndex : IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func setCell(productQuantity:Int, productPrice:Double, productName:String, productImage:String){
        self.productQuantity.text=String(productQuantity)
        self.productPrice.text="\(String(productPrice)) RS"
        self.productName.text=productName
        self.productImage.load(url: productImage)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        stepper.layer.cornerRadius=5
        // Configure the view for the selected state
    }
    @IBAction func plus(_ sender: Any) {
        delegate?.quantityIncrement(index: (productIndex?.row)! )
    }
    @IBAction func minus(_ sender: Any) {
        delegate?.quantityDecrement(index: (productIndex?.row)! )
    }
}
