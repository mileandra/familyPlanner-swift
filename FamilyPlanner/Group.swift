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
    
    @NSManaged var remoteID : NSNumber
    @NSManaged var ownerID : NSNumber
    @NSManaged var name : String
    
    @NSManaged var todos : [Todo]
    @NSManaged var messages : [Message]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(id: Int, name: String, ownerID: Int, context: NSManagedObjectContext) {
        
        //Core Data
        let entity = NSEntityDescription.entityForName("Group", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.remoteID = NSNumber(integer: id)
        self.ownerID = NSNumber(integer: ownerID)
        self.name = name
    }
}