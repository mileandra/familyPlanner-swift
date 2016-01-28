//
// Created by Julia Will on 13.12.15.
// Copyright (c) 2015 Julia Will. All rights reserved.
//

import CoreData


class User : NSManagedObject {
    @NSManaged var remoteID: NSNumber
    @NSManaged var isGroupOwner: Bool
    @NSManaged var isCurrentUser : Bool
    @NSManaged var email : String
    @NSManaged var name : String
    @NSManaged var auth_token : String?
    @NSManaged var group: Group?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(properties: NSDictionary, context: NSManagedObjectContext) {
        
        //Core Data
        let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        remoteID = NSNumber(integer: properties["id"] as! Int)
        email = properties["email"] as! String
        name = properties["name"] as! String
        auth_token = properties["auth_token"] as! String?
        isGroupOwner = false
        isCurrentUser = false
    }
    
        
}
