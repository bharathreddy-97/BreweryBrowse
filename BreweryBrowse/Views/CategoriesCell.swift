//
//  CategoriesCell.swift
//  BreweryBrowse
//
//  Created by Next on 14/01/18.
//  Copyright © 2018 Next. All rights reserved.
//

import UIKit

class CategoriesCell: UICollectionViewCell {
    @IBOutlet weak var categoryName:UILabel!
    
    var categoryData:(Category,Bool)? = nil{
        didSet{
            guard let categoryData = categoryData else {return}
            categoryName.text = categoryData.0.name
        }
    }
    
    override func awakeFromNib() {
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(white: 0.4, alpha: 1).cgColor
        self.layer.cornerRadius = 5
    }
}
