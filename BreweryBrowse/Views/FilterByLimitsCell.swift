//
//  FilterByLimitsCell.swift
//  BreweryBrowse
//
//  Created by Next on 07/01/18.
//  Copyright © 2018 Next. All rights reserved.
//

import UIKit

class FilterByLimitsCell: UITableViewCell,UITextFieldDelegate {

    @IBOutlet weak var mFilterTitle:UILabel!
    @IBOutlet weak var mUpperLimit:UITextField!
    @IBOutlet weak var mLowerLimit:UITextField!
    
    var bitternessModel:Bitterness!
    
    func setData(title:String,lowerLimit:Int,upperLimit:Int){
        mFilterTitle.text = title
        mLowerLimit.text = "\(lowerLimit)"
        mUpperLimit.text = "\(upperLimit)"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mLowerLimit.delegate = self
        mUpperLimit.delegate = self
        mLowerLimit.addTarget(self, action: #selector(observeTextFieldChanges(_:)), for: .editingChanged)
        mUpperLimit.addTarget(self, action: #selector(observeTextFieldChanges(_:)), for: .editingChanged)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    @objc private func observeTextFieldChanges(_ sender:UITextField){
        guard let text = sender.text, let numberedText = Int(text) else {return}
        //limiting numbers range from [0,100]
        if numberedText < 0 || numberedText > 100{
            sender.text = "\(0)"
        }
        if sender == mUpperLimit{
            bitternessModel.upperLimit = numberedText
        }
        else if sender == mLowerLimit{
            bitternessModel.lowerLimit = numberedText
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
