//
//  Style.swift
//  BreweryBrowse
//
//  Created by Next on 01/01/18.
//  Copyright © 2018 Next. All rights reserved.
//

import Foundation
import CoreData

class Style: NSManagedObject,Decodable {
    private enum CodingKeys:String,CodingKey{
        case categoryId = "categoryId"
        case category = "category"
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context!] as? NSManagedObjectContext else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: "Style", in: context) else { fatalError() }
        
        self.init(entity: entity, insertInto: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.categoryId = (try container.decodeIfPresent(Int32.self, forKey: .categoryId)) ?? -1
        self.category = (try container.decodeIfPresent(Category.self, forKey: .category))
    }
}
