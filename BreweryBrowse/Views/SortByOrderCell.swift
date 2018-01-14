//
//  SortByOrderCell.swift
//  BreweryBrowse
//
//  Created by Next on 07/01/18.
//  Copyright © 2018 Next. All rights reserved.
//

import UIKit

class SortByOrderCell: UITableViewCell {

    @IBOutlet weak var sortTitle:UILabel!
    @IBOutlet weak var sortParameter:UILabel!
    @IBOutlet weak var sortSwitch:UISwitch!
    
    weak var sortData:Sort?
    weak var organicData:OrganicNature?
    
    
    func setData(titleName:String, parameterName:String, isAscending:Bool){
        sortTitle.text = titleName
        sortParameter.text = parameterName
        sortSwitch.setOn(isAscending, animated: true)
    }
    
    @IBAction func switchStateChanged(_ sender: UISwitch) {
        print("on Or Off ===>",sender.isOn)
        if let data = sortData{
            data.isAscending = sender.isOn
        }
        else if let data = organicData{
            data.organicNature = sender.isOn
        }
        else{
            return
        }
    }
    
}
