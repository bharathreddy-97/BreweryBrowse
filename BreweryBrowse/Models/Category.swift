//
//  Category.swift
//  BreweryBrowse
//
//  Created by Next on 01/01/18.
//  Copyright © 2018 Next. All rights reserved.
//

import Foundation
import CoreData

class Category: NSManagedObject,Decodable {
    private enum CodingKeys:String,CodingKey{
        case name = "name"
        case createDate = "createDate"
        case description = "description"
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context!] as? NSManagedObjectContext else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: "Category", in: context) else { fatalError() }
        
        self.init(entity: entity, insertInto: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = (try container.decodeIfPresent(String.self, forKey: .name))
        self.createDate = (try container.decodeIfPresent(String.self, forKey: .createDate))
        self.categoryDescription = (try container.decodeIfPresent(String.self, forKey: .description))
    }
}
