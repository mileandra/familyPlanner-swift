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
    @NSManaged var synced : Bool
    @NSManaged var subject : String?
    
    @NSManaged var group : Group
    @NSManaged var parent : Message?
    @NSManaged var messages : [Message]?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(properties: NSDictionary, group : Group, context: NSManagedObjectContext) {
        
        //Core Data
        let entity = NSEntityDescription.entityForName("Message", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        if properties["id"] != nil {
            remoteID = NSNumber(integer: properties["id"] as! Int)
        }
        self.group = group
        self.message = properties["message"] as! String
        self.subject = properties["subject"] as! String?
        self.synced = Bool(false)
        
        //TODO: handle parent / child
    }
    
}