//
// Created by Julia Will on 13.12.15.
// Copyright (c) 2015 Julia Will. All rights reserved.
//

import CoreData


class User : NSManagedObject {
    @NSManaged var email : String
    @NSManaged var auth_token : String
    var group_id : Int?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(email: String, auth_token: String, context: NSManagedObjectContext) {
        
        //Core Data
        let entity = NSEntityDescription.entityForName("User", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.email = email
        self.auth_token = auth_token
    }
}
