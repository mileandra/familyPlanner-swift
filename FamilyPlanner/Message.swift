//
//  Message.swift
//  FamilyPlanner
//
//  Created by Julia Will on 11.01.16.
//  Copyright © 2016 Julia Will. All rights reserved.
//

import CoreData

class Message: NSManagedObject {
    @NSManaged var remoteID: NSNumber?
    @NSManaged var message : String
    
    @NSManaged var group : Group
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(properties: NSDictionary, context: NSManagedObjectContext) {
        
        //Core Data
        let entity = NSEntityDescription.entityForName("Message", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        if properties["id"] != nil {
            remoteID = NSNumber(integer: properties["id"] as! Int)
        }
        
        message = properties["message"] as! String
    }
    
}