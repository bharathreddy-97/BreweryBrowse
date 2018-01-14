//
//  BeerImages.swift
//  BreweryBrowse
//
//  Created by Next on 01/01/18.
//  Copyright © 2018 Next. All rights reserved.
//

import Foundation
import CoreData

class BeerImages: NSManagedObject,Decodable {
    private enum CodingKeys:String,CodingKey{
        case smallImage = "icon"
        case mediumImage = "medium"
        case largeImage = "large"
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context!] as? NSManagedObjectContext else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: "BeerImages", in: context) else { fatalError() }
        
        self.init(entity: entity, insertInto: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.smallImage = (try container.decodeIfPresent(String.self, forKey: .smallImage))
        self.mediumImage = (try container.decodeIfPresent(String.self, forKey: .mediumImage))
        self.largeImage = (try container.decodeIfPresent(String.self, forKey: .largeImage))
    }

}


