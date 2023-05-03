//
//  RecipeCollectionViewCell.swift
//  KhiarSupermarket
//
//  Created by Lujain Farghal on 21/09/1444 AH.
//

import UIKit
protocol recipeControllerCell{
    func addToFavoriteLis(index:Int)
}
class RecipeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var recipeName: UILabel!
    @IBOutlet weak var recipeImage: UIImageView!
    var delegate : recipeControllerCell?
    var indexPath : IndexPath?
    @IBOutlet weak var heartButton: UIButton!
    func setupRecipeCell(recipeName:String,recipeImage:String){
        self.recipeName.text=recipeName
        self.recipeImage.load(url: recipeImage)
    }
    @IBAction func addToFavorite(_ sender: Any) {
        delegate?.addToFavoriteLis(index: (indexPath?.row)!)
    }
}
