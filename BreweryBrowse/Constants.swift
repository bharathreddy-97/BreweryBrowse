//
//  Constants.swift
//  BreweryBrowse
//
//  Created by Next on 01/01/18.
//  Copyright © 2018 Next. All rights reserved.
//

import Foundation

struct Constants{
    static let API_KEY = "f77565a032f5f2c7e7e8573358ce2ca0"
    static let ABV_NO = 10
    static let DEFAULT_LOAD_ITEMS = 12
    
    struct NetworkConstants {
        static var incorrectStatusDomain = "BreweryBrowse: Incorrect response found"
        static var nullDataOrResponseDomain = "BreweryBrowse: No Data/Response found"
        static var invalidJsonErrorDomain = "BreweryBrowse: Not a valid json object"
        static var jsonToModelParseErrorDomain = "BreweryBrowse: Unable to parse Json into model"
    }
    
    struct URLConstants {
        static var fetchBeerList = "http://api.brewerydb.com/v2/beers/?key=\(Constants.API_KEY)&abv={abvNo}&p={pageNO}"
        static var fetchBeerCategories = "http://api.brewerydb.com/v2/categories/?key=\(Constants.API_KEY)"
    }
}
