//
//  Beer.swift
//  BreweryBrowse
//
//  Created by Next on 01/01/18.
//  Copyright © 2018 Next. All rights reserved.
//

import Foundation
import CoreData

class Beer: NSManagedObject,Decodable {
    private enum CodingKeys:String,CodingKey{
        case name = "name"
        case nameDisplay = "nameDisplay"
        case description = "description"
        case createDate = "createDate"
        case foodPairings = "foodPairings"
        case images = "labels"
        case style = "style"
        case bitterness = "ibu"
        case organic = "isOrganic"
    }
    
    required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context!] as? NSManagedObjectContext else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: "Beer", in: context) else { fatalError() }
        
        self.init(entity: entity, insertInto: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = (try container.decodeIfPresent(String.self, forKey: .name))
        self.nameDisplay = (try container.decodeIfPresent(String.self, forKey: .nameDisplay))
        self.beerDescription = (try container.decodeIfPresent(String.self, forKey: .description))
        self.foodPairings = (try container.decodeIfPresent(String.self, forKey: .foodPairings))
        self.createDate = (try container.decodeIfPresent(String.self, forKey: .createDate))
        self.style = (try container.decodeIfPresent(Style.self, forKey: .style))
        self.images = (try container.decodeIfPresent(BeerImages.self, forKey: .images))
        self.bitterness = Int64((try container.decodeIfPresent(String.self, forKey: .bitterness)) ?? "0") ?? 0
        self.organic = (try container.decodeIfPresent(String.self, forKey: .organic))
    }
}
