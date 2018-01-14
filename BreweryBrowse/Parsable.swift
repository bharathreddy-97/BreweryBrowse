//
//  Parsable.swift
//  BreweryBrowse
//
//  Created by Next on 05/01/18.
//  Copyright © 2018 Next. All rights reserved.
//

import Foundation


protocol Parsable {
    func parseData(from data:Data,completion:@escaping ()->())
}
