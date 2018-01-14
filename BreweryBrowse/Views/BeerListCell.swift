//
//  BeerListCell.swift
//  BreweryBrowse
//
//  Created by Next on 05/01/18.
//  Copyright © 2018 Next. All rights reserved.
//

import UIKit
import SDWebImage

class BeerListCell: UITableViewCell {
    @IBOutlet weak var mBeerIcon: UIImageView!
    @IBOutlet weak var mBeerName: UILabel!
    @IBOutlet weak var mBeerCreateDate: UILabel!
    @IBOutlet weak var mBeerOrigin: UILabel!
    
    var beerModel:Beer!{
        didSet{
            if let beerIcon = beerModel.images?.smallImage, let beerIconUrl = URL(string: beerIcon){
                mBeerIcon.sd_setImage(with: beerIconUrl, placeholderImage: nil, options: [], completed: nil)
            }
            else{
                mBeerIcon.image = #imageLiteral(resourceName: "beerHolder")
            }
            mBeerOrigin.text = beerModel.style?.category?.name
            mBeerName.text = beerModel.nameDisplay
            if let createDate = beerModel.createDate{
                mBeerCreateDate.text = getDateString(dateString: createDate)
            }
        }
    }
    
    private func getDateString(dateString: String)->String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        if let date = formatter.date(from: dateString){
            formatter.timeZone = TimeZone.ReferenceType.local
            let correctString = formatter.string(from: date)
            return correctString.components(separatedBy: " ")[0]
        }
        return ""
    }
}
