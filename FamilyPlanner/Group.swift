//
//  Group.swift
//  FamilyPlanner
//
//  Created by Julia Will on 26.12.15.
//  Copyright © 2015 Julia Will. All rights reserved.
//

import Foundation
import CoreData

class Group : NSManagedObject {
    
    @NSManaged var group_id : NSNumber
    @NSManaged var name : String
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(id: Int, name: String, context: NSManagedObjectContext) {
        
        //Core Data
        let entity = NSEntityDescription.entityForName("Group", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.group_id = NSNumber(integer: id)
        self.name = name
    }
}