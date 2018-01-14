//
//  RelatedSearchesCell.swift
//  BreweryBrowse
//
//  Created by Next on 14/01/18.
//  Copyright © 2018 Next. All rights reserved.
//

import UIKit

class RelatedBeerCell: UICollectionViewCell {
    
    @IBOutlet weak var mBeerImage:UIImageView!
    @IBOutlet weak var mBeerName:UILabel!
    @IBOutlet weak var mBeerCategory:UILabel!
    
    var beerData:Beer? = nil{
        didSet{
            guard let beerData = beerData else {return}
            setBeerImage()
            mBeerName.text = beerData.nameDisplay
            mBeerCategory.text = beerData.style?.category?.name ?? ""
        }
    }
    
    private func setBeerImage(){
        guard let images = beerData!.images else {
            mBeerImage.image = #imageLiteral(resourceName: "beerHolder")
            return
        }
        if let largeImage = images.largeImage,let url = URL.init(string: largeImage){
            mBeerImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "beerHolder"), options: [], completed: nil)
        }
        else if let mediumImage = images.mediumImage, let url = URL.init(string: mediumImage){
            mBeerImage.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "beerHolder"), options: [], completed: nil)
        }
        else{
            mBeerImage.image = #imageLiteral(resourceName: "beerHolder")
        }
    }
}
