//
//  UserTableViewCell.swift
//  KhiarSupermarket
//
//  Created by Lujain Farghal on 27/09/1444 AH.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var userRecipeName: UILabel!
    @IBOutlet weak var userRecipeImage: UIImageView!
    @IBOutlet weak var favImage: UIImageView!
    @IBOutlet weak var favName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCell(userRecipeName: String, userRecipeImage: String){
        self.userRecipeName.text = userRecipeName
        self.userRecipeImage.load(url: userRecipeImage)
    }
    func setFavCell(favName: String, favImage: String){
        self.favName.text = favName
        self.favImage.load(url: favImage)
    }
}
