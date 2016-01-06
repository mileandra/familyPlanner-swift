//
//  Todo.swift
//  FamilyPlanner
//
//  Created by Julia Will on 05.01.16.
//  Copyright © 2016 Julia Will. All rights reserved.
//

import CoreData

class Todo: NSManagedObject {
    @NSManaged var remoteID: NSNumber
    @NSManaged var title : String
    @NSManaged var completed: Bool
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(properties: NSDictionary, context: NSManagedObjectContext) {
        
        //Core Data
        let entity = NSEntityDescription.entityForName("Todo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        remoteID = NSNumber(integer: properties["id"] as! Int)
        title = properties["title"] as! String
        completed = properties["completed"] as! Bool
        
    }
}